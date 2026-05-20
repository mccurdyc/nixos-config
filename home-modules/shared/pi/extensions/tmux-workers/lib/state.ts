/**
 * Worker lifecycle state derivation.
 *
 * Pure functions with only fs / child_process dependencies. Unit-testable
 * in isolation by constructing fake worker dirs and passing in a synthetic
 * `liveWindows` Set.
 */

import { execFileSync } from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";

/**
 * Observed lifecycle state of a worker, derived from files in the worker
 * dir plus live tmux window presence.
 *
 * * `done`             — result.md present; clean completion.
 * * `running`          — launcher reports running, heartbeat is fresh,
 *                        tmux window is alive.
 * * `hung`             — launcher reports running but heartbeat is stale
 *                        beyond `HEARTBEAT_STALE_MS`; the launcher may be
 *                        blocked or stopped.
 * * `exited-no-result` — launcher reports exited and no result.md was
 *                        written (pi crashed, bad args, etc.).
 * * `dead`             — tmux window is gone without a clean `exited`
 *                        status being written; something killed the
 *                        window out from under the launcher.
 */
export type WorkerLifecycleState = "running" | "done" | "exited-no-result" | "dead" | "hung" | "awaiting-confirmation";

/** Heartbeat is considered stale after this age. Launcher touches every 2s. */
export const HEARTBEAT_STALE_MS = 10_000;

/** Structured shape of status.json as written by the launcher. */
export interface LauncherStatus {
	state?: "running" | "exited";
	/** Node launcher's own PID. This drives the heartbeat interval. */
	pid?: number;
	/** Pi child process PID. Captured at spawn time. */
	childPid?: number;
	startedAt?: string;
	exitedAt?: string;
	exitCode?: number;
	resultWritten?: boolean;
}

/** Shape returned by `deriveWorkerState`. */
export interface WorkerStateInfo {
	state: WorkerLifecycleState;
	heartbeatAgeMs: number | null;
	exitCode?: number;
	errorExcerpt?: string;
}

/** Check whether a named tmux session exists. */
export function sessionExists(session: string): boolean {
	try {
		execFileSync("tmux", ["has-session", "-t", session], { stdio: "ignore" });
		return true;
	} catch {
		return false;
	}
}

/**
 * Read the list of live window names for a tmux session. Returns an empty
 * set when the session does not exist or tmux is unavailable.
 */
export function getLiveWindowsForSession(sessionName: string): Set<string> {
	if (!sessionExists(sessionName)) return new Set();
	try {
		const raw = execFileSync(
			"tmux",
			["list-windows", "-t", sessionName, "-F", "#{window_name}"],
			{ encoding: "utf-8" },
		).trim();
		return new Set(raw.split("\n").filter(Boolean));
	} catch {
		return new Set();
	}
}

/**
 * Derive a worker's lifecycle state from files in its directory plus the
 * set of live tmux windows for its session.
 *
 * Accepts `now` as a clock injection for deterministic tests.
 */
export function deriveWorkerState(
	workerDir: string,
	windowName: string,
	liveWindows: Set<string>,
	now: number = Date.now(),
): WorkerStateInfo {
	const resultFile = path.join(workerDir, "result.md");
	const statusFile = path.join(workerDir, "status.json");
	const heartbeatFile = path.join(workerDir, "heartbeat");
	const errorLogFile = path.join(workerDir, "error.log");

	if (fs.existsSync(resultFile)) {
		return { state: "done", heartbeatAgeMs: null };
	}

	let status: LauncherStatus | null = null;
	try {
		if (fs.existsSync(statusFile)) {
			status = JSON.parse(fs.readFileSync(statusFile, "utf-8")) as LauncherStatus;
		}
	} catch {
		status = null;
	}

	const readErrorExcerpt = (): string | undefined => {
		try {
			if (!fs.existsSync(errorLogFile)) return undefined;
			const raw = fs.readFileSync(errorLogFile, "utf-8").trim();
			if (!raw) return undefined;
			const lines = raw.split("\n");
			return lines.slice(Math.max(0, lines.length - 20)).join("\n");
		} catch {
			return undefined;
		}
	};

	if (status?.state === "exited") {
		return {
			state: "exited-no-result",
			heartbeatAgeMs: null,
			exitCode: status.exitCode,
			errorExcerpt: readErrorExcerpt(),
		};
	}

	let heartbeatAgeMs: number | null = null;
	try {
		if (fs.existsSync(heartbeatFile)) {
			heartbeatAgeMs = now - fs.statSync(heartbeatFile).mtimeMs;
		}
	} catch {
		heartbeatAgeMs = null;
	}

	const windowAlive = liveWindows.has(windowName);

	if (status?.state === "running") {
		// Order matters: if the tmux window is gone, the launcher cannot be
		// alive — report `dead` even when the heartbeat is also stale (a
		// dead window always leaves a stale heartbeat shortly after).
		if (!windowAlive) {
			return { state: "dead", heartbeatAgeMs };
		}
		if (heartbeatAgeMs !== null && heartbeatAgeMs > HEARTBEAT_STALE_MS) {
			return { state: "hung", heartbeatAgeMs };
		}
		const awaitingFile = path.join(workerDir, "awaiting-confirmation");
		if (fs.existsSync(awaitingFile)) {
			return { state: "awaiting-confirmation", heartbeatAgeMs };
		}
		return { state: "running", heartbeatAgeMs };
	}

	// No status.json at all — very fresh worker (launcher hasn't written it
	// yet) or something died before the launcher ran.
	if (!windowAlive) return { state: "dead", heartbeatAgeMs };
	const awaitingFile2 = path.join(workerDir, "awaiting-confirmation");
	if (fs.existsSync(awaitingFile2)) {
		return { state: "awaiting-confirmation", heartbeatAgeMs };
	}
	return { state: "running", heartbeatAgeMs };
}

/** Format a state for one-line display. */
export function formatState(state: WorkerLifecycleState): string {
	switch (state) {
		case "done":
			return "✓ done";
		case "running":
			return "· running";
		case "hung":
			return "⚠ hung";
		case "dead":
			return "⊘ dead";
		case "exited-no-result":
			return "✗ exited (no result)";
		case "awaiting-confirmation":
			return "⚠️ awaiting confirmation";
	}
}
