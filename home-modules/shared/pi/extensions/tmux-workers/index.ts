/**
 * Tmux Workers Extension
 *
 * Spawns interactive worker pi sessions in a shared tmux session — one tmux
 * window per worker — so everything stays organized and visible in one place.
 *
 * Tools (LLM-callable):
 *   - tmux-delegate       Spawn a worker in a new tmux window
 *   - tmux-check-worker   Check if a single worker finished and retrieve its result
 *   - tmux-check-workers  Check the status of all workers in a session at once
 *   - tmux-list-workers   List all windows in the coordinator tmux session
 *
 * Slash commands (user-callable):
 *   - /tmux-workers-delegate <task>          Delegate a task from the keyboard
 *   - /tmux-workers-check-worker <workerId>  Check a single worker by ID
 *   - /tmux-workers-check-workers [session]  Check all workers in a session
 *   - /tmux-workers-list [session]           List all workers in a session
 */

import { execFileSync } from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import type { Api, Model } from "@mariozechner/pi-ai";

import type { ExtensionAPI, ExtensionUIContext, Theme, ThemeColor } from "@mariozechner/pi-coding-agent";
import { getAgentDir } from "@mariozechner/pi-coding-agent";
import { CURSOR_MARKER, type Component, type Focusable, matchesKey, Text, visibleWidth } from "@mariozechner/pi-tui";
import { fuzzyFilter } from "@mariozechner/pi-tui";
import { Type } from "@sinclair/typebox";

import {
	applyCapabilityCheck,
	CONFIG_PATH,
	DEFAULT_THINKING_LEVEL,
	hasConfig,
	isThinkingLevel,
	parseModelString,
	resolveModelAndThinking,
	THINKING_LEVELS,
	ThinkingLevel,
	writeConfig,
	type WorkersConfig,
} from "./lib/config.js";
import { LAUNCHER_CONTENT } from "./lib/launcher-source.js";
import {
	deriveWorkerState,
	formatState,
	getLiveWindowsForSession,
	HEARTBEAT_STALE_MS,
	type LauncherStatus,
	sessionExists,
	type WorkerLifecycleState,
	type WorkerStateInfo,
} from "./lib/state.js";
import { buildWorkerTask } from "./lib/task.js";

// ─── Constants ───────────────────────────────────────────────────────────────

// Place tmux-workers alongside the agent dir (e.g. ~/.pi/tmux-workers)
// by going one level up from getAgentDir() (e.g. ~/.pi/agent).
const WORKERS_DIR = path.join(path.dirname(getAgentDir()), "tmux-workers");
const LAUNCHER_PATH = path.join(WORKERS_DIR, ".bin", "launcher.mjs");

// Unique ID for this pi session — used to scope worker lookups so
// tmux-check-workers only returns workers spawned by *this* coordinator.
const PI_SESSION_ID = `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 6)}`;

// Shared tmux session name — set on first delegate call and reused for all
// subsequent calls so multiple workers land in the same tmux session.
let sharedTmuxSession: string | null = null;

// In-session widget polling interval — started on first delegate,
// cleared when all workers are done.
let widgetInterval: ReturnType<typeof setInterval> | null = null;

// Worker IDs belonging to the current active display batch. Populated by
// coreDelegate and cleared by stopWidgetPolling so stale workers from a
// previous batch never reappear in the widget.
const activeWorkerIds = new Set<string>();

// Spinner frames for the in-session widget
const SPINNER = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
// Baseline-aligned spinner for the footer status bar (braille glyphs float above baseline,
// block elements sink below it). Geometric circle-halves render at cell center, level with text.
const FOOTER_SPINNER = ["◐", "◓", "◑", "◒"];
let spinnerTick = 0;

// Reference to the UI context — captured from session_start so the
// widget polling function can update the TUI.
let ui: ExtensionUIContext | null = null;

// ─── Shared interfaces ────────────────────────────────────────────────────────

interface WorkerMeta {
	workerId: string;
	windowName: string;
	sessionName: string;
	startedAt: string;
	piSessionId?: string;
}

interface WorkerStatus extends WorkerMeta {
	done: boolean;
	result: string | null;
	elapsedMs: number;
	state: WorkerLifecycleState;
	heartbeatAgeMs: number | null;
	exitCode?: number;
	errorExcerpt?: string;
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

/** Single-quote escape a string for safe use in a POSIX shell command. */
function shellEscape(str: string): string {
	return "'" + str.replace(/'/g, "'\\''") + "'";
}

/**
 * Return the name of the tmux session this process is running inside, or
 * `null` when not inside tmux at all.  The `TMUX` environment variable is set
 * by tmux itself for every child process in a session.
 */
function getCurrentTmuxSession(): string | null {
	if (!process.env["TMUX"]) return null;
	try {
		const name = execFileSync("tmux", ["display-message", "-p", "#S"], { encoding: "utf-8" }).trim();
		return name || null;
	} catch {
		return null;
	}
}

/** Write the launcher script to disk if it isn't there yet. */
function ensureScripts(): void {
	fs.mkdirSync(path.dirname(LAUNCHER_PATH), { recursive: true });
	fs.writeFileSync(LAUNCHER_PATH, LAUNCHER_CONTENT, { encoding: "utf-8", mode: 0o755 });
}

/** Generate a short unique ID for a worker. */
function makeWorkerId(): string {
	return `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 6)}`;
}

/** Generate a random tmux session name like "pi-a3b7f2". */
function makeSessionName(): string {
	return `pi-${Math.random().toString(36).slice(2, 8)}`;
}

/** Format a millisecond duration as a compact human-readable string. */
function formatElapsed(ms: number): string {
	const totalSecs = Math.floor(ms / 1000);
	const h = Math.floor(totalSecs / 3600);
	const m = Math.floor((totalSecs % 3600) / 60);
	const s = totalSecs % 60;
	if (h > 0) return `${h}h ${m}m`;
	if (m > 0) return `${m}m ${s}s`;
	return `${s}s`;
}

// Maximum visible width of the workers panel (fits most terminals).
const WIDGET_MAX_WIDTH = 68;
// Fixed column width reserved for the elapsed-time display.
const WIDGET_ELAPSED_COL = 7;

/** Maps a worker lifecycle state to the widget's icon + theme color pick. */
export interface WidgetIconChoice {
	icon: string;
	iconColor: ThemeColor;
	nameColor: ThemeColor;
}
export function widgetIconForState(state: WorkerLifecycleState, frame: string): WidgetIconChoice {
	switch (state) {
		case "done":
			return { icon: "✓", iconColor: "success", nameColor: "muted" };
		case "running":
			return { icon: frame, iconColor: "accent", nameColor: "text" };
		case "hung":
			return { icon: "⚠", iconColor: "warning", nameColor: "text" };
		case "dead":
			return { icon: "⊘", iconColor: "error", nameColor: "muted" };
		case "exited-no-result":
			return { icon: "✗", iconColor: "error", nameColor: "muted" };
		case "awaiting-confirmation":
			return { icon: "⚠️", iconColor: "warning", nameColor: "text" };
	}
}

/** True when the worker is in a terminal state — nothing more will change. */
export function isTerminal(state: WorkerLifecycleState): boolean {
	return state === "done" || state === "dead" || state === "exited-no-result";
}

/**
 * Build the bordered-panel lines for the workers widget.
 *
 * Layout (example, innerW = 66):
 *   ╭─ Workers: 2/4 ─────────────────────────────────────────────────╮
 *   │  ✓  wrk-fast-task                                    1m 23s   │
 *   │  ⠋  wrk-slow-task                                    2m 10s   │
 *   ╰────────────────────────────────────────────────────────────────╯
 */
export function buildWidgetLines(
	workers: Array<WorkerMeta & { state: WorkerLifecycleState; elapsedMs: number }>,
	frame: string,
	theme: Theme,
): string[] {
	const maxW = WIDGET_MAX_WIDTH;
	const innerW = maxW - 2; // subtract left + right border chars

	// Prefix visible chars inside each row: "  <icon>  " = 5
	const prefixVisible = 5;
	// Suffix visible chars inside each row: "  <elapsed>  " = ELAPSED_COL + 4
	const suffixVisible = WIDGET_ELAPSED_COL + 4;
	const nameColW = Math.max(4, innerW - prefixVisible - suffixVisible);

	const doneCount = workers.filter((w) => w.state === "done").length;
	const total = workers.length;
	const allDone = doneCount === total;

	// ── Header ────────────────────────────────────────────────────────────
	const titleText = ` Workers: ${doneCount}/${total} `;
	const titleLen = titleText.length; // no ANSI yet → safe to use .length
	const rightBorderLen = Math.max(0, innerW - 1 - titleLen);
	const titleStyled = allDone
		? theme.fg("success", titleText)
		: theme.fg("warning", titleText);
	const header =
		theme.fg("border", "╭─") +
		titleStyled +
		theme.fg("border", "─".repeat(rightBorderLen) + "╮");

	// ── Worker rows ───────────────────────────────────────────────────────
	const rows = workers.map((w) => {
		const { icon, iconColor, nameColor } = widgetIconForState(w.state, frame);
		const elapsed = formatElapsed(w.elapsedMs);

		// Right-align elapsed in its fixed-width column.
		const elapsedPadded = elapsed.padStart(WIDGET_ELAPSED_COL);

		// Truncate / pad the name to fit the name column.
		const rawName = w.windowName;
		const nameTrunc =
			rawName.length > nameColW
				? rawName.slice(0, nameColW - 1) + "…"
				: rawName;
		const namePadded = nameTrunc.padEnd(nameColW);

		const iconStyled = theme.fg(iconColor, icon);
		const nameStyled = theme.fg(nameColor, namePadded);
		const elapsedStyled = theme.fg("dim", elapsedPadded);

		return (
			theme.fg("border", "│") +
			"  " + iconStyled + "  " +
			nameStyled +
			"  " + elapsedStyled + "  " +
			theme.fg("border", "│")
		);
	});

	// ── Footer ────────────────────────────────────────────────────────────
	const footer = theme.fg("border", "╰" + "─".repeat(innerW) + "╯");

	return [header, ...rows, footer];
}

/** Update the in-session widget and status bar with current worker state. */
function updateWidget(): void {
	if (!ui) return;

	interface ActiveWorker extends WorkerMeta {
		state: WorkerLifecycleState;
		elapsedMs: number;
	}

	const rawMetas: WorkerMeta[] = [];
	let readOk = false;
	try {
		const entries = fs.readdirSync(WORKERS_DIR, { withFileTypes: true });
		for (const entry of entries) {
			if (!entry.isDirectory() || entry.name === ".bin") continue;
			const metaFile = path.join(WORKERS_DIR, entry.name, "meta.json");
			if (!fs.existsSync(metaFile)) continue;
			const meta: WorkerMeta = JSON.parse(fs.readFileSync(metaFile, "utf-8"));
			if (meta.piSessionId !== PI_SESSION_ID) continue;
			if (!activeWorkerIds.has(meta.workerId)) continue;
			rawMetas.push(meta);
		}
		readOk = true;
	} catch {
		// Filesystem blip — skip this tick and retry next second.
		return;
	}

	// Batch-fetch live tmux windows per session so we call `tmux list-windows`
	// once per distinct session per tick instead of once per worker.
	const liveWindowsBySession = new Map<string, Set<string>>();
	for (const meta of rawMetas) {
		if (!liveWindowsBySession.has(meta.sessionName)) {
			liveWindowsBySession.set(meta.sessionName, getLiveWindowsForSession(meta.sessionName));
		}
	}

	const workers: ActiveWorker[] = rawMetas.map((meta) => {
		const workerDir = path.join(WORKERS_DIR, meta.workerId);
		const liveWindows = liveWindowsBySession.get(meta.sessionName) ?? new Set<string>();
		const info = deriveWorkerState(workerDir, meta.windowName, liveWindows);
		const elapsedMs = Date.now() - new Date(meta.startedAt).getTime();
		return { ...meta, state: info.state, elapsedMs };
	});

	// Only stop polling when the read succeeded and there are genuinely no workers.
	if (readOk && workers.length === 0) {
		stopWidgetPolling();
		return;
	}

	// Newest first — most recently launched appears at the top.
	workers.sort((a, b) => b.startedAt.localeCompare(a.startedAt));

	const doneCount = workers.filter((w) => w.state === "done").length;
	const total = workers.length;
	// All workers have reached a terminal state (done / dead / exited-no-result).
	// This is when we can safely stop polling — nothing more will change.
	const allTerminal = workers.every((w) => isTerminal(w.state));

	const frame = SPINNER[spinnerTick % SPINNER.length]!;
	spinnerTick++;

	const theme = ui.theme;
	const lines = buildWidgetLines(workers, frame, theme);
	ui.setWidget("tmux-workers", lines);

	const statusText = allTerminal
		? theme.fg("success", `√ Workers: ${doneCount}/${total}`)
		: theme.fg("warning", `${FOOTER_SPINNER[spinnerTick % FOOTER_SPINNER.length]!} Workers: ${doneCount}/${total}`);
	ui.setStatus("tmux-workers", statusText);

	if (allTerminal) {
		setTimeout(() => {
			stopWidgetPolling();
		}, 5000);
	}
}

/** Start polling the widget if not already running. */
function startWidgetPolling(): void {
	if (widgetInterval) return;
	updateWidget();
	widgetInterval = setInterval(() => updateWidget(), 1000);
}

/** Stop polling. Clears the widget, footer status, and active worker set. */
function stopWidgetPolling(): void {
	if (widgetInterval) {
		clearInterval(widgetInterval);
		widgetInterval = null;
	}
	activeWorkerIds.clear();
	if (ui) {
		ui.setWidget("tmux-workers", undefined);
		ui.setStatus("tmux-workers", undefined);
	}
}

/**
 * Look up the prefix key configured for a tmux session and return it in a
 * human-readable form (e.g. "Ctrl+B", "Ctrl+A").  Falls back to "Ctrl+B" if
 * the session doesn't exist or the query fails.
 */
function getTmuxPrefix(session: string): string {
	/** Parse "prefix C-b" style output → "C-b", or null if not matched. */
	function parseRaw(out: string): string | null {
		const m = out.trim().match(/^prefix\s+(.+)$/);
		return m ? m[1].trim() : null;
	}

	/** Format a raw tmux key string (e.g. "C-Space", "C-b") → "Ctrl+Space", "Ctrl+B". */
	function formatKey(raw: string): string {
		// Capitalize first letter, lowercase the rest — gives "Space", "B", "A", etc.
		const cap = (s: string) => s.charAt(0).toUpperCase() + s.slice(1).toLowerCase();
		const ctrlMatch = raw.match(/^C-(.+)$/i);
		if (ctrlMatch) return `Ctrl+${cap(ctrlMatch[1])}`;
		const altMatch = raw.match(/^M-(.+)$/i);
		if (altMatch) return `Alt+${cap(altMatch[1])}`;
		return raw; // pass through exotic values unchanged
	}

	try {
		// Try session-level first (option may be overridden per-session).
		// NOTE: -v strips the key name but returns empty for inherited globals;
		// use plain show-options and parse "prefix <value>" instead.
		try {
			const out = execFileSync("tmux", ["show-options", "-t", session, "prefix"], { encoding: "utf-8" });
			const raw = parseRaw(out);
			if (raw) return formatKey(raw);
		} catch {
			// Session may not exist yet — fall through to global lookup.
		}

		// Fall back to the global option.
		const out = execFileSync("tmux", ["show-options", "-g", "prefix"], { encoding: "utf-8" });
		const raw = parseRaw(out);
		if (raw) return formatKey(raw);

		return "Ctrl+B";
	} catch {
		return "Ctrl+B";
	}
}

// ─── Core logic (shared between tools and slash commands) ─────────────────────

/** Delegate a task to a new worker window. Returns text summary and details. */
function coreDelegate(
	task: string,
	options: {
		session?: string;
		workerName?: string;
		cwd: string;
		model?: string;
		thinking?: string;
		modelRegistry?: { find(provider: string, id: string): Model<Api> | undefined };
	},
	pi: ExtensionAPI,
): { text: string; details: Record<string, string> } {
	ensureScripts();

	const sessionName = options.session ?? getCurrentTmuxSession() ?? sharedTmuxSession ?? makeSessionName();
	// Remember the session for subsequent calls in this pi session.
	if (!sharedTmuxSession) sharedTmuxSession = sessionName;
	const workerId = makeWorkerId();
	const windowName = options.workerName ?? `wrk-${workerId.slice(0, 6)}`;
	const workerCwd = options.cwd;

	const workerDir = path.join(WORKERS_DIR, workerId);
	fs.mkdirSync(workerDir, { recursive: true });

	const taskFile = path.join(workerDir, "task.txt");
	const resultFile = path.join(workerDir, "result.md");

	const fullTask = buildWorkerTask(task, resultFile, workerDir);

	fs.writeFileSync(taskFile, fullTask, "utf-8");

	const metaFile = path.join(workerDir, "meta.json");
	fs.writeFileSync(
		metaFile,
		JSON.stringify(
			{ workerId, windowName, sessionName, startedAt: new Date().toISOString(), piSessionId: PI_SESSION_ID },
			null,
			2,
		),
		"utf-8",
	);

	if (!sessionExists(sessionName)) {
		execFileSync("tmux", ["new-session", "-d", "-s", sessionName, "-n", windowName]);
	} else {
		// -d keeps the current window focused
		execFileSync("tmux", ["new-window", "-d", "-t", sessionName, "-n", windowName]);
	}

	// Pipe the pane's output to pane.log so the launcher can salvage diagnostics
	// when pi exits without writing result.md. Set this up BEFORE send-keys so
	// nothing printed by the launcher is lost. Wrapped in try/catch because a
	// pipe-pane failure should not prevent the worker from starting.
	const paneLog = path.join(workerDir, "pane.log");
	try {
		execFileSync("tmux", [
			"pipe-pane",
			"-o",
			"-t",
			`${sessionName}:${windowName}`,
			`cat >> ${shellEscape(paneLog)}`,
		]);
	} catch {
		// Pane capture is best-effort; worker will still run without it.
	}

	// After the pi process exits (success or failure), kill the worker window automatically.
	const killCmd = `tmux kill-window -t ${shellEscape(`${sessionName}:${windowName}`)}`;
	// Forward select environment variables into the worker window so credentials
	// and config set in the coordinator's shell (e.g. via aliases) are available.
	const envForward = ["AWS_PROFILE", "AWS_REGION", "AWS_DEFAULT_REGION"]
		.filter((k) => process.env[k])
		.map((k) => `${k}=${shellEscape(process.env[k]!)}`);

	const resolved = applyCapabilityCheck(
		resolveModelAndThinking(options.model, options.thinking),
		options.modelRegistry,
	);
	const resolvedModel = resolved.model;
	const resolvedThinking = resolved.thinking;

	const launcherArgs = [
		"node",
		shellEscape(LAUNCHER_PATH),
		shellEscape(taskFile),
		shellEscape(workerCwd),
	];
	// Always pass positional model slot (empty string if unresolved); thinking
	// follows only when both are set so argv indices stay predictable.
	if (resolvedModel || resolvedThinking) {
		launcherArgs.push(shellEscape(resolvedModel));
		if (resolvedThinking) launcherArgs.push(shellEscape(resolvedThinking));
	}

	const shellCmd = [
		...envForward,
		...launcherArgs,
	].join(" ") + `; ${killCmd}`;

	execFileSync("tmux", ["send-keys", "-t", `${sessionName}:${windowName}`, shellCmd, "Enter"]);

	// Watch for the done sentinel file written by the launcher after pi exits,
	// so result.md is guaranteed to be fully written.
	const watcher = fs.watch(workerDir, (eventType, filename) => {
		if (filename === "done") {
			watcher.close();
			let result = "(no output)";
			try {
				result = fs.readFileSync(resultFile, "utf-8");
			} catch {
				// Ignore read errors
			}
			pi.sendMessage(
				{
					customType: "tmux-workers",
					content: `Worker "${windowName}" (${workerId}) finished:\n\n${result}`,
					display: true,
					details: { workerId, windowName, result },
				},
				{ triggerTurn: true, deliverAs: "followUp" },
			);
		}
	});

	const attachHint = `tmux attach -t ${sessionName}`;
	const prefix = getTmuxPrefix(sessionName);

	const lines = [
		`Worker "${windowName}" started in tmux session "${sessionName}".`,
		`Worker ID : ${workerId}`,
	];
	if (resolvedModel) {
		const thinkingTag = resolvedThinking ? ` (thinking: ${resolvedThinking})` : "";
		lines.push(`Model     : ${resolvedModel}${thinkingTag}`);
	}
	if (resolved.warning) lines.push(`Note      : ${resolved.warning}`);
	lines.push(
		`Result    : ${resultFile}`,
		`Attach    : ${attachHint}`,
		`Switch    : ${prefix}, then pick window "${windowName}"`,
	);

	const text = lines.join("\n");

	// Register this worker in the current active display batch.
	activeWorkerIds.add(workerId);

	return { text, details: { workerId, windowName, sessionName, resultFile, taskFile } };
}

/** Check a single worker by ID. */
function coreCheckWorker(workerId: string): {
	text: string;
	done: boolean;
	found: boolean;
	result?: string;
	state?: WorkerLifecycleState;
	exitCode?: number;
	errorExcerpt?: string;
} {
	const workerDir = path.join(WORKERS_DIR, workerId);
	const resultFile = path.join(workerDir, "result.md");
	const metaFile = path.join(workerDir, "meta.json");

	if (!fs.existsSync(workerDir)) {
		return { text: `Unknown worker ID: ${workerId}`, done: false, found: false };
	}

	if (fs.existsSync(resultFile)) {
		const result = fs.readFileSync(resultFile, "utf-8");
		return { text: result, done: true, found: true, result, state: "done" };
	}

	// Derive richer state from status.json + heartbeat + live tmux windows.
	let windowName = "";
	let sessionName = "";
	try {
		const meta = JSON.parse(fs.readFileSync(metaFile, "utf-8")) as WorkerMeta;
		windowName = meta.windowName;
		sessionName = meta.sessionName;
	} catch {
		// meta.json unreadable — fall through with best-effort empty state.
	}
	const liveWindows = sessionName ? getLiveWindowsForSession(sessionName) : new Set<string>();
	const info = deriveWorkerState(workerDir, windowName, liveWindows);

	let text: string;
	switch (info.state) {
		case "running": {
			const age = info.heartbeatAgeMs;
			const beat = age !== null ? ` (last heartbeat ${Math.round(age / 1000)}s ago)` : "";
			text = `Worker is still running — no result file yet${beat}.`;
			break;
		}
		case "hung": {
			const age = info.heartbeatAgeMs;
			const beat = age !== null ? `${Math.round(age / 1000)}s` : "unknown";
			text = `Worker heartbeat is stale (${beat} since last beat). The launcher may be hung or stopped.`;
			break;
		}
		case "dead":
			text =
				"Worker window is gone without a clean exit. Something killed the tmux window; no result was written.";
			break;
		case "exited-no-result": {
			const codeTxt = info.exitCode !== undefined ? ` (exit code ${info.exitCode})` : "";
			const excerpt = info.errorExcerpt ? `\n\n--- error.log (last 20 lines) ---\n${info.errorExcerpt}` : "";
			text = `Worker exited without writing a result${codeTxt}.${excerpt}`;
			break;
		}
		case "done":
			// Handled above; keep a safe default.
			text = "Worker completed.";
			break;
	}

	return {
		text,
		done: false,
		found: true,
		state: info.state,
		exitCode: info.exitCode,
		errorExcerpt: info.errorExcerpt,
	};
}

/**
 * Check workers, scoped to this pi session by default.
 * When `sessionName` is provided, filters by tmux session name instead.
 */
function coreCheckWorkers(sessionName: string | null): {
	text: string;
	workers: WorkerStatus[];
	doneCount: number;
	totalCount: number;
} {
	const workers: WorkerStatus[] = [];
	const rawMetas: WorkerMeta[] = [];
	try {
		const entries = fs.readdirSync(WORKERS_DIR, { withFileTypes: true });
		for (const entry of entries) {
			if (!entry.isDirectory() || entry.name === ".bin") continue;
			const metaFile = path.join(WORKERS_DIR, entry.name, "meta.json");
			if (!fs.existsSync(metaFile)) continue;
			const meta: WorkerMeta = JSON.parse(fs.readFileSync(metaFile, "utf-8"));
			if (sessionName !== null) {
				if (meta.sessionName !== sessionName) continue;
			} else {
				if (meta.piSessionId !== PI_SESSION_ID) continue;
			}
			rawMetas.push(meta);
		}
	} catch {
		// Ignore filesystem errors
	}

	// Build a map of sessionName -> live-window Set so we only call
	// `tmux list-windows` once per distinct session.
	const liveWindowsBySession = new Map<string, Set<string>>();
	for (const meta of rawMetas) {
		if (!liveWindowsBySession.has(meta.sessionName)) {
			liveWindowsBySession.set(meta.sessionName, getLiveWindowsForSession(meta.sessionName));
		}
	}

	for (const meta of rawMetas) {
		const workerDir = path.join(WORKERS_DIR, meta.workerId);
		const resultFile = path.join(workerDir, "result.md");
		const liveWindows = liveWindowsBySession.get(meta.sessionName) ?? new Set<string>();
		const info = deriveWorkerState(workerDir, meta.windowName, liveWindows);
		const done = info.state === "done";
		const result = done && fs.existsSync(resultFile) ? fs.readFileSync(resultFile, "utf-8") : null;
		const elapsedMs = Date.now() - new Date(meta.startedAt).getTime();
		workers.push({
			...meta,
			done,
			result,
			elapsedMs,
			state: info.state,
			heartbeatAgeMs: info.heartbeatAgeMs,
			exitCode: info.exitCode,
			errorExcerpt: info.errorExcerpt,
		});
	}

	workers.sort((a, b) => a.startedAt.localeCompare(b.startedAt));

	const scopeLabel = sessionName !== null ? `session "${sessionName}"` : "this pi session";

	if (workers.length === 0) {
		return { text: `No workers found for ${scopeLabel}.`, workers: [], doneCount: 0, totalCount: 0 };
	}

	const doneCount = workers.filter((w) => w.done).length;
	const lines: string[] = [`Workers: ${doneCount}/${workers.length} done`, ""];

	for (const w of workers) {
		const elapsed = formatElapsed(w.elapsedMs);
		const sessionTag = sessionName === null ? `  [session: ${w.sessionName}]` : "";
		switch (w.state) {
			case "done": {
				lines.push(`✓ ${w.windowName}  [id: ${w.workerId}]${sessionTag}  completed in ${elapsed}`);
				lines.push("--- result ---");
				lines.push(w.result ?? "");
				lines.push("");
				break;
			}
			case "running": {
				lines.push(`· ${w.windowName}  [id: ${w.workerId}]${sessionTag}  running for ${elapsed}`);
				lines.push("");
				break;
			}
			case "hung": {
				const age = w.heartbeatAgeMs !== null ? `${Math.round(w.heartbeatAgeMs / 1000)}s` : "unknown";
				lines.push(
					`⚠ ${w.windowName}  [id: ${w.workerId}]${sessionTag}  hung — heartbeat stale ${age}`,
				);
				lines.push("");
				break;
			}
			case "dead": {
				lines.push(
					`✗ ${w.windowName}  [id: ${w.workerId}]${sessionTag}  dead — window gone after ${elapsed}`,
				);
				lines.push("");
				break;
			}
			case "exited-no-result": {
				const codeTxt = w.exitCode !== undefined ? ` (exit ${w.exitCode})` : "";
				lines.push(
					`✗ ${w.windowName}  [id: ${w.workerId}]${sessionTag}  exited without result${codeTxt} after ${elapsed}`,
				);
				if (w.errorExcerpt) {
					lines.push("--- error.log (last 20 lines) ---");
					lines.push(w.errorExcerpt);
				}
				lines.push("");
				break;
			}
		}
	}

	return { text: lines.join("\n"), workers, doneCount, totalCount: workers.length };
}

/**
 * List workers, scoped to this pi session by default.
 * When `sessionName` is provided, filters by tmux session name instead.
 */
function coreListWorkers(sessionName: string | null): {
	text: string;
	workers: Array<WorkerMeta & { done: boolean }>;
} {
	const knownWorkers: Array<WorkerMeta & { done: boolean }> = [];
	try {
		const entries = fs.readdirSync(WORKERS_DIR, { withFileTypes: true });
		for (const entry of entries) {
			if (!entry.isDirectory() || entry.name === ".bin") continue;
			const metaFile = path.join(WORKERS_DIR, entry.name, "meta.json");
			if (!fs.existsSync(metaFile)) continue;
			const meta: WorkerMeta = JSON.parse(fs.readFileSync(metaFile, "utf-8"));
			if (sessionName !== null) {
				if (meta.sessionName !== sessionName) continue;
			} else {
				if (meta.piSessionId !== PI_SESSION_ID) continue;
			}
			const resultFile = path.join(WORKERS_DIR, entry.name, "result.md");
			knownWorkers.push({ ...meta, done: fs.existsSync(resultFile) });
		}
	} catch {
		// Ignore filesystem errors
	}

	knownWorkers.sort((a, b) => a.startedAt.localeCompare(b.startedAt));

	// Get live tmux windows for a specific session, or the shared session
	let tmuxWindows: string[] = [];
	const tmuxSessionToList = sessionName ?? sharedTmuxSession;
	if (tmuxSessionToList && sessionExists(tmuxSessionToList)) {
		try {
			const raw = execFileSync(
				"tmux",
				["list-windows", "-t", tmuxSessionToList, "-F", "#{window_index}: #{window_name}#{?window_active, (active),}"],
				{ encoding: "utf-8" },
			).trim();
			tmuxWindows = raw.split("\n").filter(Boolean);
		} catch {
			// Ignore
		}
	}

	// Build a lifecycle-state map by session so we can annotate each worker
	// with its real state (running / done / hung / dead / exited-no-result).
	const liveWindowsBySession = new Map<string, Set<string>>();
	for (const w of knownWorkers) {
		if (!liveWindowsBySession.has(w.sessionName)) {
			liveWindowsBySession.set(w.sessionName, getLiveWindowsForSession(w.sessionName));
		}
	}
	const stateByWorkerId = new Map<string, WorkerLifecycleState>();
	for (const w of knownWorkers) {
		const workerDir = path.join(WORKERS_DIR, w.workerId);
		const liveWindows = liveWindowsBySession.get(w.sessionName) ?? new Set<string>();
		const info = deriveWorkerState(workerDir, w.windowName, liveWindows);
		stateByWorkerId.set(w.workerId, info.state);
	}

	const scopeLabel = sessionName !== null ? `session "${sessionName}"` : "this pi session";

	if (knownWorkers.length === 0 && tmuxWindows.length === 0) {
		return {
			text: `No workers found for ${scopeLabel}. Use tmux-delegate to start your first worker.`,
			workers: [],
		};
	}

	const lines: string[] = [];

	if (tmuxWindows.length > 0) {
		const windowsHeader = `Tmux windows in "${tmuxSessionToList}":`;
		lines.push(windowsHeader);
		for (const w of tmuxWindows) lines.push(`  ${w}`);
		lines.push("");
	}

	if (knownWorkers.length > 0) {
		lines.push("Known workers:");
		for (const w of knownWorkers) {
			const state = stateByWorkerId.get(w.workerId) ?? (w.done ? "done" : "running");
			const started = new Date(w.startedAt).toLocaleTimeString();
			const sessionTag = sessionName === null ? "" : `  [session: ${w.sessionName}]`;
			lines.push(
				`  ${formatState(state)} ${w.windowName}  [id: ${w.workerId}]${sessionTag}  started ${started}`,
			);
		}
	}

	return { text: lines.join("\n"), workers: knownWorkers };
}

// ─── Extension ───────────────────────────────────────────────────────────────

// ─── Fuzzy model picker overlay ─────────────────────────────────────────────

interface ModelItem {
	id: string;
	provider: string;
	display: string;
}

class ModelPickerComponent implements Focusable {
	readonly width = 60;
	focused = false;

	private query = "";
	private cursor = 0;
	private selected = 0;
	private filtered: ModelItem[];
	private maxVisible = 12;
	private scrollOffset = 0;

	constructor(
		private title: string,
		private items: ModelItem[],
		private theme: Theme,
		private done: (result: string | undefined) => void,
	) {
		this.filtered = [...items];
	}

	handleInput(data: string): void {
		if (matchesKey(data, "escape")) {
			this.done(undefined);
			return;
		}

		if (matchesKey(data, "return")) {
			const item = this.filtered[this.selected];
			this.done(item ? `${item.provider}/${item.id}` : undefined);
			return;
		}

		if (matchesKey(data, "up") || matchesKey(data, "ctrl+p")) {
			this.selected = Math.max(0, this.selected - 1);
			if (this.selected < this.scrollOffset) this.scrollOffset = this.selected;
		} else if (matchesKey(data, "down") || matchesKey(data, "ctrl+n")) {
			this.selected = Math.min(this.filtered.length - 1, this.selected + 1);
			if (this.selected >= this.scrollOffset + this.maxVisible) {
				this.scrollOffset = this.selected - this.maxVisible + 1;
			}
		} else if (matchesKey(data, "backspace")) {
			if (this.cursor > 0) {
				this.query = this.query.slice(0, this.cursor - 1) + this.query.slice(this.cursor);
				this.cursor--;
				this.updateFilter();
			}
		} else if (data.length === 1 && data.charCodeAt(0) >= 32) {
			this.query = this.query.slice(0, this.cursor) + data + this.query.slice(this.cursor);
			this.cursor++;
			this.updateFilter();
		}
	}

	private updateFilter(): void {
		if (this.query === "") {
			this.filtered = [...this.items];
		} else {
			this.filtered = fuzzyFilter(this.items, this.query, (item) => item.display);
		}
		this.selected = 0;
		this.scrollOffset = 0;
	}

	invalidate(): void {}

	render(): string[] {
		const lines: string[] = [];
		const t = this.theme;

		lines.push(t.bold(this.title));
		lines.push("");

		// Search input with cursor
		const beforeCursor = this.query.slice(0, this.cursor);
		const afterCursor = this.query.slice(this.cursor);
		const inputLine = t.fg("dim", "> ") + beforeCursor + CURSOR_MARKER + afterCursor;
		lines.push(inputLine);
		lines.push("");

		// Filtered list
		const visible = this.filtered.slice(this.scrollOffset, this.scrollOffset + this.maxVisible);
		for (let i = 0; i < visible.length; i++) {
			const item = visible[i];
			const idx = this.scrollOffset + i;
			const isSelected = idx === this.selected;
			const pointer = isSelected ? t.fg("accent", "> ") : "  ";
			const name = isSelected ? t.bold(item.id) : item.id;
			const provider = item.provider ? t.fg("dim", ` [${item.provider}]`) : "";
			lines.push(pointer + name + provider);
		}

		if (this.filtered.length === 0) {
			lines.push(t.fg("dim", "  No matching models"));
		}

		if (this.filtered.length > this.maxVisible) {
			lines.push("");
			lines.push(t.fg("dim", `  ${this.filtered.length} models (↑/↓ or Ctrl+P/N to scroll)`));
		}

		return lines;
	}
}

// ─── Thinking-level picker ──────────────────────────────────────

const THINKING_DESCRIPTIONS: Record<ThinkingLevel, string> = {
	off: "no reasoning",
	minimal: "minimal reasoning budget",
	low: "low reasoning budget",
	medium: "balanced (recommended default)",
	high: "high reasoning budget",
	xhigh: "maximum reasoning budget",
};

/** Simple fixed-list picker for thinking levels (no fuzzy search). */
class ThinkingPickerComponent implements Focusable {
	readonly width = 60;
	focused = false;

	private selected: number;

	constructor(
		private title: string,
		private levels: ThinkingLevel[],
		private theme: Theme,
		private done: (result: ThinkingLevel | undefined) => void,
		initialLevel: ThinkingLevel = DEFAULT_THINKING_LEVEL,
	) {
		const idx = levels.indexOf(initialLevel);
		this.selected = idx >= 0 ? idx : 0;
	}

	handleInput(data: string): void {
		if (matchesKey(data, "escape")) {
			this.done(undefined);
			return;
		}
		if (matchesKey(data, "return")) {
			this.done(this.levels[this.selected]);
			return;
		}
		if (matchesKey(data, "up") || matchesKey(data, "ctrl+p")) {
			this.selected = Math.max(0, this.selected - 1);
		} else if (matchesKey(data, "down") || matchesKey(data, "ctrl+n")) {
			this.selected = Math.min(this.levels.length - 1, this.selected + 1);
		}
	}

	invalidate(): void {}

	render(): string[] {
		const t = this.theme;
		const lines: string[] = [t.bold(this.title), ""];
		for (let i = 0; i < this.levels.length; i++) {
			const lvl = this.levels[i];
			const isSelected = i === this.selected;
			const pointer = isSelected ? t.fg("accent", "> ") : "  ";
			const name = isSelected ? t.bold(lvl) : lvl;
			const desc = t.fg("dim", `  — ${THINKING_DESCRIPTIONS[lvl]}`);
			lines.push(pointer + name + desc);
		}
		return lines;
	}
}

// ─── Setup wizard ────────────────────────────────────────────────────────────

interface SetupResult {
	fast: string;
	default: string;
	heavy: string;
}

type PresetIdx = 0 | 1 | 2;

type WizardPhase =
	| { kind: "model"; preset: PresetIdx }
	| { kind: "thinking"; preset: PresetIdx }
	| { kind: "confirm" };

const PRESET_LABELS: Record<PresetIdx, string> = { 0: "Fast", 1: "Default", 2: "Heavy" };
const PRESET_HINTS: Record<PresetIdx, string> = {
	0: "simple / quick tasks",
	1: "most tasks",
	2: "complex tasks",
};

class SetupWizardComponent implements Component, Focusable {
	readonly width = 100;
	focused = false;

	private modelItems: ModelItem[];
	private selectedModels: (Model<Api> | undefined)[] = [undefined, undefined, undefined];
	private selectedThinking: (ThinkingLevel | undefined)[] = [undefined, undefined, undefined];
	private phase: WizardPhase = { kind: "model", preset: 0 };
	private history: WizardPhase[] = [];
	private currentPicker: ModelPickerComponent | ThinkingPickerComponent | null = null;
	private cachedLines: string[] | undefined;

	constructor(
		private models: Model<Api>[],
		private theme: Theme,
		private done: (result: SetupResult | null) => void,
	) {
		this.modelItems = models.map((m) => ({
			id: m.id,
			provider: m.provider,
			display: `${m.id} ${m.provider}`,
		}));
		this.currentPicker = this.buildPicker();
	}

	private buildPicker(): ModelPickerComponent | ThinkingPickerComponent | null {
		if (this.phase.kind === "model") {
			const preset = this.phase.preset;
			return new ModelPickerComponent(
				`${PRESET_LABELS[preset]} model \u2014 ${PRESET_HINTS[preset]}`,
				this.modelItems,
				this.theme,
				(r) => this.onModelPick(r),
			);
		}
		if (this.phase.kind === "thinking") {
			const preset = this.phase.preset;
			const m = this.selectedModels[preset]!;
			const levels = (THINKING_LEVELS as readonly ThinkingLevel[]).filter(
				(l) => l !== "xhigh" || (m.thinkingLevelMap != null && "xhigh" in m.thinkingLevelMap && m.thinkingLevelMap["xhigh"] != null),
			);
			const initial = this.selectedThinking[preset] ?? DEFAULT_THINKING_LEVEL;
			return new ThinkingPickerComponent(
				`${PRESET_LABELS[preset]} thinking level \u2014 ${m.provider}/${m.id}`,
				levels,
				this.theme,
				(r) => this.onThinkingPick(r),
				initial,
			);
		}
		return null;
	}

	private advanceTo(next: WizardPhase): void {
		this.history.push(this.phase);
		this.phase = next;
		this.currentPicker = this.buildPicker();
		this.invalidate();
	}

	private gotoNextFromModel(preset: PresetIdx): void {
		const m = this.selectedModels[preset]!;
		if (m.reasoning) {
			this.advanceTo({ kind: "thinking", preset });
		} else if (preset < 2) {
			this.advanceTo({ kind: "model", preset: (preset + 1) as PresetIdx });
		} else {
			this.advanceTo({ kind: "confirm" });
		}
	}

	private gotoNextFromThinking(preset: PresetIdx): void {
		if (preset < 2) {
			this.advanceTo({ kind: "model", preset: (preset + 1) as PresetIdx });
		} else {
			this.advanceTo({ kind: "confirm" });
		}
	}

	private retreat(): void {
		if (this.history.length === 0) {
			this.done(null);
			return;
		}
		this.phase = this.history.pop()!;
		this.currentPicker = this.buildPicker();
		this.invalidate();
	}

	private onModelPick(r: string | undefined): void {
		if (r === undefined) { this.retreat(); return; }
		if (this.phase.kind !== "model") return;
		const slash = r.indexOf("/");
		if (slash === -1) { this.retreat(); return; }
		const provider = r.slice(0, slash);
		const id = r.slice(slash + 1);
		const m = this.models.find((x) => x.provider === provider && x.id === id);
		if (!m) { this.retreat(); return; }
		const preset = this.phase.preset;
		this.selectedModels[preset] = m;
		// New model — previous thinking selection may be invalid; clear it.
		this.selectedThinking[preset] = undefined;
		this.gotoNextFromModel(preset);
	}

	private onThinkingPick(r: ThinkingLevel | undefined): void {
		if (r === undefined) { this.retreat(); return; }
		if (this.phase.kind !== "thinking") return;
		const preset = this.phase.preset;
		this.selectedThinking[preset] = r;
		this.gotoNextFromThinking(preset);
	}

	private buildPresetString(i: PresetIdx): string {
		const m = this.selectedModels[i];
		if (!m) return "";
		const lvl = this.selectedThinking[i];
		return lvl ? `${m.provider}/${m.id}:${lvl}` : `${m.provider}/${m.id}`;
	}

	private writeAndFinish(): void {
		this.done({
			fast: this.buildPresetString(0),
			default: this.buildPresetString(1),
			heavy: this.buildPresetString(2),
		});
	}

	invalidate(): void {
		this.cachedLines = undefined;
	}

	handleInput(data: string): void {
		if (this.phase.kind === "confirm") {
			if (matchesKey(data, "return")) {
				this.writeAndFinish();
			} else if (matchesKey(data, "escape")) {
				this.retreat();
			}
			return;
		}
		if (this.currentPicker) {
			this.currentPicker.handleInput(data);
			this.invalidate();
		}
	}

	private phaseLabel(): string {
		if (this.phase.kind === "confirm") return "Confirm";
		const kindLabel = this.phase.kind === "model" ? "model" : "thinking";
		return `${PRESET_LABELS[this.phase.preset]} ${kindLabel}`;
	}

	render(_width: number): string[] {
		if (this.cachedLines) return this.cachedLines;

		const t = this.theme;
		const innerW = this.width - 2;
		const pad = (s: string, n: number) => s + " ".repeat(Math.max(0, n - visibleWidth(s)));
		const row = (content: string) =>
			t.fg("border", "\u2502") + pad(content, innerW) + t.fg("border", "\u2502");

		const titleStyled =
			" " + t.bold("tmux-workers-setup") +
			t.fg("muted", "  Step: ") +
			t.fg("text", this.phaseLabel()) + " ";
		const fillLen = Math.max(0, innerW - visibleWidth(titleStyled));
		const leftFill = Math.floor(fillLen / 2);
		const rightFill = fillLen - leftFill;

		const lines: string[] = [
			t.fg("border", "\u256d" + "\u2500".repeat(leftFill)) +
			titleStyled +
			t.fg("border", "\u2500".repeat(rightFill) + "\u256e"),
			row(""),
		];

		const content: string[] = this.phase.kind === "confirm"
			? this.renderConfirmStep(innerW)
			: (this.currentPicker ? this.currentPicker.render() : []);
		for (const l of content) lines.push(row(" " + l));

		const escHint = this.history.length === 0 ? "Esc to cancel" : "Esc to go back";
		const hintRaw = `${escHint} \u2022 Enter to confirm`;
		const gap = Math.max(1, innerW - 1 - visibleWidth(hintRaw));
		lines.push(
			row(""),
			row(" " + t.fg("dim", hintRaw) + " ".repeat(gap)),
			t.fg("border", "\u2570" + "\u2500".repeat(innerW) + "\u256f"),
		);

		this.cachedLines = lines;
		return lines;
	}

	private renderConfirmStep(innerW: number): string[] {
		const t = this.theme;
		// Each row is wrapped by row(" " + l) in render(), which prepends 1
		// space. The content itself starts with "  " + 16-char label. Compute
		// the remaining budget for model + thinking text so we can truncate
		// long IDs rather than overflowing the right border.
		const leadVisible = 1 /* row wrapper space */ + 2 /* rowFor "  " */ + 16 /* label column */;
		const ellipsize = (s: string, max: number): string =>
			s.length <= max ? s : (max >= 1 ? s.slice(0, Math.max(0, max - 1)) + "\u2026" : "");

		const rowFor = (label: string, i: PresetIdx): string => {
			const labelCol = t.fg("muted", (label + ":").padEnd(16));
			const m = this.selectedModels[i];
			if (!m) {
				return "  " + labelCol + t.fg("warning", "(not set)");
			}
			const lvl = this.selectedThinking[i];
			const modelRaw = `${m.provider}/${m.id}`;
			const thinkingRaw = lvl
				? `  :${lvl}`
				: m.reasoning
					? "  (no thinking level)"
					: "  (model has no reasoning)";
			const budget = Math.max(10, innerW - leadVisible - thinkingRaw.length);
			const modelTrunc = ellipsize(modelRaw, budget);
			const modelText = t.fg("text", modelTrunc);
			const thinkingText = lvl ? t.fg("accent", thinkingRaw) : t.fg("dim", thinkingRaw);
			return "  " + labelCol + modelText + thinkingText;
		};
		return [
			"  " + t.bold("Review configuration:"),
			"",
			rowFor("fast", 0),
			rowFor("default", 1),
			rowFor("heavy", 2),
			"",
			"  " + t.fg("success", "Press Enter to write config."),
		];
	}
}

export default function (pi: ExtensionAPI) {
	// Capture UI reference for widget updates
	pi.on("session_start", async (_event, ctx) => {
		ui = ctx.ui;
	});

	pi.on("session_shutdown", async () => {
		stopWidgetPolling();
	});

	// ── tmux-delegate (tool) ─────────────────────────────────────────────────

	if (process.env["PI_TMUX_WORKER"]) {
		// Running inside a worker — skip registering tmux-delegate to prevent
		// unintended nested delegation.
	} else
	pi.registerTool({
		name: "tmux-delegate",
		label: "Tmux Delegate",
		description: [
			"Spawn an interactive worker pi session in a new tmux window.",
			"If already running inside a tmux session, that session is used by default.",
			"Otherwise a new session is created with a random name like 'pi-a3b7f2'.",
			"The worker receives the task as its first message and is instructed to",
			"write its final output to a result file when done.",
			"Returns a workerId to check results later with tmux-check-worker.",
		].join(" "),
		promptSnippet: "Spawn a worker pi session in a new tmux window and return a workerId",
		promptGuidelines: [
			"Always use tmux-delegate when delegating or parallelizing independent tasks across multiple workers. Prefer tmux-delegate over any other delegation method.",
			"After delegating, DO NOT poll with tmux-check-worker or tmux-check-workers in a loop. Workers send a follow-up message automatically when done — just wait for those messages to arrive. Only use tmux-check-workers once if you need a single status snapshot, never repeatedly.",
			"NEVER use sleep, bash waits, or repeated tmux-check-workers calls to poll for worker completion. Each worker delivers its result as a follow-up message when finished. Continue with other independent work or simply wait.",
			"When delegating sub-tasks, include the specific output format and structure you expect in the task description. Workers must not load skills to derive format — tell them exactly what to produce.",
			"Workers are constrained to write only in their dedicated worker directory. They cannot write to shared paths like ~/agt/reviews/ or ~/agt/plans/. You (the coordinator) are responsible for assembling worker outputs into the final deliverable.",
		],
		parameters: Type.Object({
			task: Type.String({ description: "The task to delegate to the worker" }),
			workerName: Type.Optional(
				Type.String({ description: "Name for the worker. Defaults to wrk-<id>." }),
			),
			session: Type.Optional(
				Type.String({
					description:
						"Tmux session name. Defaults to the current tmux session if inside one, otherwise a new randomly-named session is created.",
				}),
			),
			cwd: Type.Optional(
				Type.String({
					description: "Working directory for the worker. Defaults to the current project directory.",
				}),
			),
			model: Type.Optional(
				Type.String({
					description: "Model preset (fast, default, heavy) or raw model ID for the worker. May include a ':<level>' thinking suffix, e.g. 'default:high' or 'anthropic/claude-sonnet-4-5:medium'.",
				}),
			),
			thinking: Type.Optional(
				Type.Union(
					[
						Type.Literal("off"),
						Type.Literal("minimal"),
						Type.Literal("low"),
						Type.Literal("medium"),
						Type.Literal("high"),
						Type.Literal("xhigh"),
					],
					{
						description:
							"Thinking level for the worker. Overrides any level in the model string or preset. Ignored (with a warning) when the resolved model does not support reasoning.",
					},
				),
			),
		}),

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			try {
				execFileSync("tmux", ["-V"], { stdio: "ignore" });
			} catch {
				throw new Error("tmux is not installed or not in PATH.");
			}
			if (!hasConfig()) {
				throw new Error("No tmux-workers config found. Run /tmux-workers-setup to pick worker models.");
			}
			const r = coreDelegate(params.task, {
				session: params.session,
				workerName: params.workerName,
				cwd: params.cwd ?? ctx.cwd,
				model: params.model,
				thinking: params.thinking,
				modelRegistry: ctx.modelRegistry,
			}, pi);
			startWidgetPolling();
			return { content: [{ type: "text", text: r.text }], details: r.details };
		},

		renderCall(args, theme) {
			const name = args.workerName ?? "auto";
			const session = (args.session as string | undefined) ?? getCurrentTmuxSession() ?? "auto";
			const preview = args.task
				? args.task.length > 60
					? `${args.task.slice(0, 60)}…`
					: args.task
				: "…";
			return new Text(
				theme.fg("toolTitle", theme.bold("tmux-delegate ")) +
					theme.fg("accent", name) +
					theme.fg("muted", ` → ${session}`) +
					"\n  " +
					theme.fg("dim", preview),
				0,
				0,
			);
		},

		renderResult(result, _options, theme) {
			const d = result.details as Record<string, string> | undefined;
			if (!d?.workerId) {
				const t = result.content[0];
				return new Text(t?.type === "text" ? t.text : "(no output)", 0, 0);
			}
			return new Text(
				theme.fg("success", "✓ ") +
					theme.fg("toolTitle", theme.bold(d.windowName)) +
					theme.fg("muted", ` in ${d.sessionName}`) +
					"\n  " +
					theme.fg("dim", `id: ${d.workerId}`) +
					"\n  " +
					theme.fg("dim", `tmux attach -t ${d.sessionName}`),
				0,
				0,
			);
		},
	});

	// ── tmux-check-worker (tool) ─────────────────────────────────────────────

	pi.registerTool({
		name: "tmux-check-worker",
		label: "Check Worker",
		description:
			"Check whether a tmux worker has finished. Returns done status and the result if the worker wrote its result file.",
		promptSnippet: "Check if a single tmux worker has finished and retrieve its result",
		parameters: Type.Object({
			workerId: Type.String({ description: "The worker ID returned by tmux-delegate" }),
		}),

		async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
			const r = coreCheckWorker(params.workerId);
			if (!r.found) {
				throw new Error(`Unknown worker ID: ${params.workerId}`);
			}
			return {
				content: [{ type: "text", text: r.text }],
				details: { done: r.done, found: r.found, result: r.result },
			};
		},

		renderResult(result, _options, theme) {
			const d = result.details as Record<string, unknown> | undefined;
			if (d?.found === false) {
				return new Text(theme.fg("error", "✗ Worker not found"), 0, 0);
			}
			if (d?.done) {
				return new Text(
					theme.fg("success", "✓ Worker complete") + "\n" + theme.fg("toolOutput", String(d.result ?? "")),
					0,
					0,
				);
			}
			return new Text(theme.fg("warning", "· Still running…"), 0, 0);
		},
	});

	// ── tmux-check-workers (tool) ────────────────────────────────────────────

	pi.registerTool({
		name: "tmux-check-workers",
		label: "Check All Workers",
		description: [
			"Check the status of all workers in a tmux session at once.",
			"Returns done/running status for every worker, elapsed time, and the full result",
			"for any that have completed.",
			"Useful for polling multiple delegated tasks without calling tmux-check-worker individually.",
			"If already running inside a tmux session, that session is used by default.",
			"If no session can be determined, checks all sessions.",
		].join(" "),
		promptSnippet: "Check status of all workers in a tmux session at once",
		parameters: Type.Object({
			session: Type.Optional(
				Type.String({
					description:
						"Tmux session name. Defaults to the current tmux session if inside one, otherwise checks all sessions.",
				}),
			),
		}),

		async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
			const sessionName: string | null = params.session ?? null;
			const r = coreCheckWorkers(sessionName);
			return {
				content: [{ type: "text", text: r.text }],
				details: { session: sessionName, workers: r.workers, doneCount: r.doneCount, totalCount: r.totalCount },
			};
		},

		renderResult(result, _options, theme) {
			const d = result.details as { doneCount?: number; totalCount?: number } | undefined;
			const t = result.content[0];
			const text = t?.type === "text" ? t.text : "(no output)";
			if (d?.totalCount !== undefined && d.totalCount > 0) {
				const allDone = d.doneCount === d.totalCount;
				const icon = allDone ? "✓" : "·";
				const color = allDone ? ("success" as const) : ("warning" as const);
				return new Text(
					theme.fg(color, `${icon} ${d.doneCount}/${d.totalCount} workers done`) +
						"\n" +
						theme.fg("toolOutput", text),
					0,
					0,
				);
			}
			return new Text(theme.fg("toolOutput", text), 0, 0);
		},
	});

	// ── tmux-list-workers (tool) ─────────────────────────────────────────────

	pi.registerTool({
		name: "tmux-list-workers",
		label: "List Workers",
		description:
			"List all workers in the current pi session so you can see active and completed workers. " +
			"By default only shows workers spawned in this pi session. " +
			"Pass a session name to filter by tmux session instead.",
		promptSnippet: "List all workers in the current pi session to see active workers",
		parameters: Type.Object({
			session: Type.Optional(
				Type.String({
					description:
						"Tmux session name to filter by. When omitted, shows only workers from this pi session.",
				}),
			),
		}),

		async execute(_toolCallId, params, _signal, _onUpdate, _ctx) {
			const sessionName: string | null = params.session ?? null;
			const r = coreListWorkers(sessionName);
			return {
				content: [{ type: "text", text: r.text }],
				details: { session: sessionName, workers: r.workers },
			};
		},

		renderResult(result, _options, theme) {
			const t = result.content[0];
			return new Text(t?.type === "text" ? theme.fg("toolOutput", t.text) : "(no output)", 0, 0);
		},
	});

	// ── Slash commands ────────────────────────────────────────────────────────

	pi.registerCommand("tmux-workers-delegate", {
		description: "Delegate a task to a new worker tmux window",
		handler: async (args, ctx) => {
			const task = args.trim();
			if (!task) {
				ctx.ui.notify("Usage: /tmux-workers-delegate <task description>", "error");
				return;
			}
			try {
				execFileSync("tmux", ["-V"], { stdio: "ignore" });
			} catch {
				ctx.ui.notify("tmux is not installed or not in PATH.", "error");
				return;
			}
			const configured = hasConfig();
			if (!configured) {
				ctx.ui.notify("No tmux-workers config found. Run /tmux-workers-setup to pick worker models.", "error");
				return;
			}
			try {
				const r = coreDelegate(task, { cwd: ctx.cwd, modelRegistry: ctx.modelRegistry }, pi);
				startWidgetPolling();
				ctx.ui.notify(r.text, "info");
			} catch (err) {
				ctx.ui.notify(`Failed to delegate: ${String(err)}`, "error");
			}
		},
	});

	pi.registerCommand("tmux-workers-check-worker", {
		description: "Check a single worker's status by ID",
		getArgumentCompletions: (prefix) => {
			try {
				const entries = fs.readdirSync(WORKERS_DIR, { withFileTypes: true });
				return entries
					.filter((e) => e.isDirectory() && e.name !== ".bin" && e.name.startsWith(prefix))
					.map((e) => ({ value: e.name, label: e.name }));
			} catch {
				return null;
			}
		},
		handler: async (args, ctx) => {
			const workerId = args.trim();
			if (!workerId) {
				ctx.ui.notify("Usage: /tmux-workers-check-worker <workerId>", "error");
				return;
			}
			const r = coreCheckWorker(workerId);
			if (!r.found) {
				ctx.ui.notify(`Unknown worker ID: ${workerId}`, "error");
				return;
			}
			if (r.done) {
				pi.sendMessage({ customType: "tmux-workers", content: r.text, display: true, details: {} });
			} else {
				ctx.ui.notify("· Worker is still running — no result file yet.", "info");
			}
		},
	});

	pi.registerCommand("tmux-workers-check-workers", {
		description: "Check all workers' statuses (this pi session by default)",
		handler: async (args, _ctx) => {
			const session = args.trim();
			const sessionName: string | null = session.length > 0 ? session : null;
			const r = coreCheckWorkers(sessionName);
			pi.sendMessage({ customType: "tmux-workers", content: r.text, display: true, details: {} });
		},
	});

	pi.registerCommand("tmux-workers-list", {
		description: "List all workers (this pi session by default)",
		handler: async (args, _ctx) => {
			const session = args.trim();
			const sessionName: string | null = session.length > 0 ? session : null;
			const r = coreListWorkers(sessionName);
			pi.sendMessage({ customType: "tmux-workers", content: r.text, display: true, details: {} });
		},
	});

	pi.registerCommand("tmux-workers-setup", {
		description: "Pick models for tmux worker agents (fast/default/heavy)",
		handler: async (_args, ctx) => {
			const models = ctx.modelRegistry.getAvailable();
			if (models.length === 0) {
				ctx.ui.notify("No models available. Check your API keys.", "error");
				return;
			}

			const result = await ctx.ui.custom<SetupResult | null>(
				(_tui, theme, _kb, done) => new SetupWizardComponent(models, theme, done),
				{ overlay: true },
			);
			if (!result) { ctx.ui.notify("Setup cancelled.", "info"); return; }

			writeConfig(result.fast, result.default, result.heavy);
			ctx.ui.notify(`Config written to ~/.pi/tmux-workers.yaml`, "info");
		},
	});

	pi.registerCommand("tmux-workers-clean", {
		description: "Remove completed worker dirs and kill dead tmux sessions",
		handler: async (_args, ctx) => {
			let removed = 0;
			let kept = 0;
			try {
				const entries = fs.readdirSync(WORKERS_DIR, { withFileTypes: true });
				for (const entry of entries) {
					if (!entry.isDirectory() || entry.name === ".bin") continue;
					const workerDir = path.join(WORKERS_DIR, entry.name);
					const doneFile = path.join(workerDir, "done");
					if (fs.existsSync(doneFile)) {
						fs.rmSync(workerDir, { recursive: true, force: true });
						removed++;
					} else {
						kept++;
					}
				}
			} catch {
				// Ignore filesystem errors
			}

			const parts: string[] = [];
			if (removed > 0) parts.push(`removed ${removed} completed worker dir${removed === 1 ? "" : "s"}`);
			if (kept > 0) parts.push(`${kept} still running`);
			if (parts.length === 0) parts.push("nothing to clean up");

			ctx.ui.notify(`🧹 ${parts.join(", ")}`, "info");
		},
	});
}
