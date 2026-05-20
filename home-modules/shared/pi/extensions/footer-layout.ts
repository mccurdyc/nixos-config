/**
 * Footer Layout Extension
 *
 * Takes over pi's footer via ctx.ui.setFooter() and renders the extension-
 * status line (line 3 of the footer) with configurable zones and separator.
 * Lines 1-2 (pwd + token stats + model) are reproduced faithfully from
 * pi's default footer so you don't lose any information.
 *
 * Config file: ~/.pi/footer-layout.json
 *
 *   {
 *     "separator": " │ ",
 *     "left":  ["safe-mode", "*"],
 *     "right": ["*", "pi-metrics"],
 *     "hide":  []
 *   }
 *
 * Semantics:
 *   - `left` / `right`: ordered lists of status keys. Keys render in the
 *     given order within each zone.
 *   - `"*"` is a wildcard meaning "every other registered status, sorted
 *     alphabetically." Place it where unknown/new keys should land. If a
 *     zone has no "*", unknown keys simply don't appear there.
 *   - If both zones contain "*", the LEFT wildcard wins (absorbs unknowns)
 *     and the RIGHT "*" is treated as empty. Keep this in mind.
 *   - `hide`: keys to drop from the footer entirely.
 *   - `separator`: literal string inserted between segments within a zone.
 *     Rendered in dim color so it recedes visually.
 *
 * Commands:
 *   /footer-layout keys              List currently-registered status keys
 *   /footer-layout show              Print current config
 *   /footer-layout left <keys...>    Set left zone order
 *   /footer-layout right <keys...>   Set right zone order
 *   /footer-layout sep <string>      Set separator (supports surrounding quotes)
 *   /footer-layout hide <key>        Hide a key
 *   /footer-layout unhide <key>      Stop hiding a key
 *   /footer-layout reset             Delete config, restore defaults
 *   /footer-layout off               Temporarily restore pi's default footer
 *   /footer-layout on                Re-enable custom footer
 *   /footer-layout drift-check       Compare installed pi version/footer hash
 *                                    to the values this extension was tested
 *                                    against — warns if lines 1-2 may have
 *                                    drifted from pi's default.
 */

import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";
import { createHash } from "node:crypto";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { homedir } from "node:os";
import { dirname, join } from "node:path";

const CONFIG_FILE = join(homedir(), ".pi", "footer-layout.json");

// --- Drift detection ------------------------------------------------------
//
// Lines 1-2 of our footer are a port of pi's internal footer.js. If pi
// changes that file, we drift silently. These pinned values let us detect it.
//
// To refresh after verifying compatibility with a newer pi:
//   1. Run `/footer-layout drift-check` to see the new version + hash.
//   2. Update the two constants below.
const TESTED_PI_VERSION = "0.70.2";
const TESTED_FOOTER_HASH = "afe5778684cca53273d0223b178facd2d0edf4c87050dff99db839f56a939618";

type Config = {
	separator: string;
	left: string[];
	right: string[];
	hide: string[];
};

const DEFAULT_CONFIG: Config = {
	separator: " │ ",
	left: ["safe-mode", "*"],
	right: ["*", "pi-metrics"],
	hide: [],
};

function loadConfig(): Config {
	try {
		if (existsSync(CONFIG_FILE)) {
			const raw = JSON.parse(readFileSync(CONFIG_FILE, "utf8"));
			return {
				separator: typeof raw.separator === "string" ? raw.separator : DEFAULT_CONFIG.separator,
				left: Array.isArray(raw.left) ? raw.left.filter((x: unknown) => typeof x === "string") : DEFAULT_CONFIG.left,
				right: Array.isArray(raw.right) ? raw.right.filter((x: unknown) => typeof x === "string") : DEFAULT_CONFIG.right,
				hide: Array.isArray(raw.hide) ? raw.hide.filter((x: unknown) => typeof x === "string") : DEFAULT_CONFIG.hide,
			};
		}
	} catch {
		// fall through
	}
	return { ...DEFAULT_CONFIG };
}

function saveConfig(cfg: Config): void {
	try {
		mkdirSync(dirname(CONFIG_FILE), { recursive: true });
		writeFileSync(CONFIG_FILE, JSON.stringify(cfg, null, 2));
	} catch {
		// best effort
	}
}

// --- Formatting helpers (ported from pi's default footer) -----------------

function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1000000) return `${Math.round(count / 1000)}k`;
	if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
	return `${Math.round(count / 1000000)}M`;
}

function sanitizeStatusText(text: string): string {
	return text.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim();
}

// --- Zone resolution ------------------------------------------------------

/**
 * Resolve which keys go where.
 *
 * Rules:
 *   - hidden keys: dropped
 *   - explicit key in left: goes to left at that position
 *   - explicit key in right: goes to right at that position (left wins on dup)
 *   - unknown keys (not explicit in either zone): absorbed by the first zone
 *     that has "*" — left has priority over right
 */
function resolveZones(
	statuses: ReadonlyMap<string, string>,
	cfg: Config,
): { leftKeys: string[]; rightKeys: string[] } {
	const hidden = new Set(cfg.hide);
	const explicitLeft = new Set(cfg.left.filter((k) => k !== "*"));
	const explicitRight = new Set(cfg.right.filter((k) => k !== "*"));

	const all = Array.from(statuses.keys()).filter((k) => !hidden.has(k));
	const unknown = all.filter((k) => !explicitLeft.has(k) && !explicitRight.has(k)).sort();

	const leftHasStar = cfg.left.includes("*");
	const rightHasStar = cfg.right.includes("*");

	const expand = (list: string[], isLeft: boolean): string[] => {
		const result: string[] = [];
		for (const token of list) {
			if (token === "*") {
				// Left's wildcard wins if both zones have one.
				if (isLeft && leftHasStar) {
					for (const k of unknown) result.push(k);
				} else if (!isLeft && rightHasStar && !leftHasStar) {
					for (const k of unknown) result.push(k);
				}
			} else {
				// Only include if the key is actually registered (and not duplicated in the other zone)
				if (statuses.has(token) && !hidden.has(token)) {
					// If the same explicit key appears in both zones, left wins.
					if (!isLeft && explicitLeft.has(token)) continue;
					result.push(token);
				}
			}
		}
		return result;
	};

	return {
		leftKeys: expand(cfg.left, true),
		rightKeys: expand(cfg.right, false),
	};
}

// --- Extension ------------------------------------------------------------

// Returns the pi version + footer.js hash currently installed, or null if
// anything fails (e.g. pi was installed in an unexpected layout).
function probePi(): { version: string; hash: string; footerPath: string } | null {
	// Try multiple base paths for createRequire because extensions are loaded
	// from outside pi's package dir, so resolving relative to the extension
	// file fails. pi's entry point (process.argv[1]) is the reliable anchor.
	const candidateBases = [
		process.argv[1],
		typeof require !== "undefined" ? __filename : undefined,
		import.meta.url,
	].filter((x): x is string => typeof x === "string" && x.length > 0);

	const resolvePiPkg = (): string | null => {
		for (const base of candidateBases) {
			try {
				const req = createRequire(base);
				return req.resolve("@mariozechner/pi-coding-agent/package.json");
			} catch {
				// try next
			}
		}
		// Last-ditch: check well-known install locations.
		const guesses = [
			join(homedir(), ".bun/install/global/node_modules/@mariozechner/pi-coding-agent/package.json"),
			"/usr/local/lib/node_modules/@mariozechner/pi-coding-agent/package.json",
			"/opt/homebrew/lib/node_modules/@mariozechner/pi-coding-agent/package.json",
		];
		for (const g of guesses) if (existsSync(g)) return g;
		return null;
	};

	try {
		const pkgPath = resolvePiPkg();
		if (!pkgPath) return null;
		const pkg = JSON.parse(readFileSync(pkgPath, "utf8"));
		const footerPath = join(
			dirname(pkgPath),
			"dist",
			"modes",
			"interactive",
			"components",
			"footer.js",
		);
		if (!existsSync(footerPath)) return null;
		const src = readFileSync(footerPath);
		const hash = createHash("sha256").update(src).digest("hex");
		return { version: pkg.version ?? "unknown", hash, footerPath };
	} catch {
		return null;
	}
}

export default function (pi: ExtensionAPI) {
	let cfg = loadConfig();
	let enabled = true;
	// Capture tui so we can request re-renders after config changes.
	let tuiRef: { requestRender: () => void } | null = null;
	// Live snapshot of the status keys seen in the most recent render, so
	// `/footer-layout keys` can report what's actually registered right now.
	let lastSeenKeys: string[] = [];
	// Warn about pi drift only once per session.
	let driftWarned = false;

	function requestRender(): void {
		if (tuiRef) tuiRef.requestRender();
	}

	function checkDrift(ctx: { ui: { notify: (msg: string, level: string) => void } }): void {
		if (driftWarned) return;
		driftWarned = true;
		const probe = probePi();
		if (!probe) return; // fail silent; nothing actionable
		if (probe.version !== TESTED_PI_VERSION || probe.hash !== TESTED_FOOTER_HASH) {
			ctx.ui.notify(
				`footer-layout: pi version/footer mismatch — ` +
				`tested with ${TESTED_PI_VERSION}, running ${probe.version}. ` +
				`Lines 1-2 of the footer may have drifted from pi's default. ` +
				`Run /footer-layout drift-check for details.`,
				"warning",
			);
		}
	}

	function install(ctx: {
		ui: {
			setFooter: (f: unknown) => void;
			theme?: unknown;
		};
		cwd: string;
		model: unknown;
		sessionManager: {
			getCwd: () => string;
			getSessionName: () => string | undefined;
			getBranch: () => unknown[];
			getEntries: () => unknown[];
		};
		modelRegistry: unknown;
		getContextUsage: () => unknown;
	}): void {
		type Theme = {
			fg: (color: string, text: string) => string;
			bold?: (text: string) => string;
		};
		type FooterData = {
			getGitBranch: () => string | null;
			getExtensionStatuses: () => ReadonlyMap<string, string>;
			getAvailableProviderCount: () => number;
			onBranchChange: (cb: () => void) => () => void;
		};
		type TUI = { requestRender: () => void };

		ctx.ui.setFooter((tui: TUI, theme: Theme, footerData: FooterData) => {
			tuiRef = tui;
			const unsub = footerData.onBranchChange(() => tui.requestRender());
			return {
				dispose: () => {
					unsub();
					if (tuiRef === tui) tuiRef = null;
				},
				invalidate() {},
				render(width: number): string[] {
					return renderFooter(width, ctx, theme, footerData);
				},
			};
		});
	}

	// Walk session entries to find the current thinking level. This mirrors
	// pi's internal behavior: the latest `thinking_level_change` entry wins,
	// default "off" if none. We look across all entries (not just the active
	// branch) because thinking-level changes are global session events.
	function currentThinkingLevel(entries: unknown[]): string {
		let level = "off";
		for (const e of entries as Array<{ type: string; thinkingLevel?: string }>) {
			if (e.type === "thinking_level_change" && typeof e.thinkingLevel === "string") {
				level = e.thinkingLevel;
			}
		}
		return level;
	}

	function renderFooter(
		width: number,
		ctx: {
			cwd: string;
			model: unknown;
			sessionManager: {
				getCwd: () => string;
				getSessionName: () => string | undefined;
				getBranch: () => unknown[];
				getEntries: () => unknown[];
			};
			modelRegistry: unknown;
			getContextUsage: () => unknown;
		},
		theme: { fg: (c: string, t: string) => string; bold?: (t: string) => string },
		footerData: {
			getGitBranch: () => string | null;
			getExtensionStatuses: () => ReadonlyMap<string, string>;
			getAvailableProviderCount: () => number;
		},
	): string[] {
		// --- Totals from session (same logic as default footer) ---
		let totalInput = 0, totalOutput = 0, totalCacheRead = 0, totalCacheWrite = 0, totalCost = 0;
		for (const entry of ctx.sessionManager.getEntries() as Array<
			{ type: string; message?: { role: string; usage: AssistantMessage["usage"] } }
		>) {
			if (entry.type === "message" && entry.message?.role === "assistant" && entry.message.usage) {
				totalInput += entry.message.usage.input;
				totalOutput += entry.message.usage.output;
				totalCacheRead += entry.message.usage.cacheRead;
				totalCacheWrite += entry.message.usage.cacheWrite;
				totalCost += entry.message.usage.cost.total;
			}
		}

		// --- Context usage ---
		const contextUsage = ctx.getContextUsage() as
			| { contextWindow: number; percent: number | null }
			| undefined;
		const model = ctx.model as {
			id?: string;
			contextWindow?: number;
			provider?: string;
			reasoning?: boolean;
		} | undefined;
		const contextWindow = contextUsage?.contextWindow ?? model?.contextWindow ?? 0;
		const contextPercentValue = contextUsage?.percent ?? 0;
		const contextPercent = contextUsage?.percent != null ? contextPercentValue.toFixed(1) : "?";

		// --- Line 1: pwd + git branch + session name ---
		let pwd = ctx.sessionManager.getCwd();
		const home = process.env.HOME || process.env.USERPROFILE;
		if (home && pwd.startsWith(home)) pwd = `~${pwd.slice(home.length)}`;
		const branch = footerData.getGitBranch();
		if (branch) pwd = `${pwd} (${branch})`;
		const sessionName = ctx.sessionManager.getSessionName();
		if (sessionName) pwd = `${pwd} • ${sessionName}`;
		const pwdLine = truncateToWidth(theme.fg("dim", pwd), width, theme.fg("dim", "..."));

		// --- Line 2: token stats on the left, model on the right ---
		const statsParts: string[] = [];
		if (totalInput) statsParts.push(`↑${formatTokens(totalInput)}`);
		if (totalOutput) statsParts.push(`↓${formatTokens(totalOutput)}`);
		if (totalCacheRead) statsParts.push(`R${formatTokens(totalCacheRead)}`);
		if (totalCacheWrite) statsParts.push(`W${formatTokens(totalCacheWrite)}`);
		if (totalCost > 0) statsParts.push(`$${totalCost.toFixed(3)}`);
		const contextDisplay = contextPercent === "?"
			? `?/${formatTokens(contextWindow)}`
			: `${contextPercent}%/${formatTokens(contextWindow)}`;
		let contextStr = contextDisplay;
		if (contextPercentValue > 90) contextStr = theme.fg("error", contextDisplay);
		else if (contextPercentValue > 70) contextStr = theme.fg("warning", contextDisplay);
		statsParts.push(contextStr);

		let statsLeft = statsParts.join(" ");
		let statsLeftWidth = visibleWidth(statsLeft);
		if (statsLeftWidth > width) {
			statsLeft = truncateToWidth(statsLeft, width, "...");
			statsLeftWidth = visibleWidth(statsLeft);
		}
		const modelName = model?.id || "no-model";
		// Append thinking-level indicator for reasoning-capable models, same as
		// pi's default footer: "<model> • thinking off" or "<model> • <level>".
		let rightSideWithoutProvider = modelName;
		if (model?.reasoning) {
			const level = currentThinkingLevel(ctx.sessionManager.getEntries());
			rightSideWithoutProvider =
				level === "off" ? `${modelName} • thinking off` : `${modelName} • ${level}`;
		}
		let rightSide = rightSideWithoutProvider;
		if (footerData.getAvailableProviderCount() > 1 && model?.provider) {
			const withProv = `(${model.provider}) ${rightSideWithoutProvider}`;
			if (statsLeftWidth + 2 + visibleWidth(withProv) <= width) rightSide = withProv;
		}
		const rightWidth = visibleWidth(rightSide);
		let statsLine: string;
		if (statsLeftWidth + 2 + rightWidth <= width) {
			statsLine = statsLeft + " ".repeat(width - statsLeftWidth - rightWidth) + rightSide;
		} else {
			const avail = width - statsLeftWidth - 2;
			if (avail > 0) {
				const trunc = truncateToWidth(rightSide, avail, "");
				const pad = " ".repeat(Math.max(0, width - statsLeftWidth - visibleWidth(trunc)));
				statsLine = statsLeft + pad + trunc;
			} else {
				statsLine = statsLeft;
			}
		}
		const dimStatsLeft = theme.fg("dim", statsLeft);
		const remainder = statsLine.slice(statsLeft.length);
		const dimRemainder = theme.fg("dim", remainder);

		const lines = [pwdLine, dimStatsLeft + dimRemainder];

		// --- Line 3: zoned extension statuses ---
		const statuses = footerData.getExtensionStatuses();
		// Snapshot live keys for `/footer-layout keys`.
		lastSeenKeys = Array.from(statuses.keys()).sort();
		if (statuses.size > 0) {
			const { leftKeys, rightKeys } = resolveZones(statuses, cfg);
			const sep = theme.fg("dim", cfg.separator);

			const render = (keys: string[]): string => {
				const segs: string[] = [];
				for (const k of keys) {
					const raw = statuses.get(k);
					if (!raw) continue;
					const clean = sanitizeStatusText(raw);
					if (clean) segs.push(clean);
				}
				return segs.join(sep);
			};

			const leftText = render(leftKeys);
			const rightText = render(rightKeys);
			const leftW = visibleWidth(leftText);
			const rightW = visibleWidth(rightText);

			let line: string;
			if (leftText && rightText) {
				const gap = width - leftW - rightW;
				if (gap >= 1) {
					line = leftText + " ".repeat(gap) + rightText;
				} else {
					// Too narrow: truncate left so right stays intact
					const avail = Math.max(0, width - rightW - 1);
					const truncLeft = truncateToWidth(leftText, avail, theme.fg("dim", "…"));
					const gap2 = Math.max(1, width - visibleWidth(truncLeft) - rightW);
					line = truncLeft + " ".repeat(gap2) + rightText;
				}
			} else {
				line = truncateToWidth(leftText || rightText, width, theme.fg("dim", "…"));
			}
			lines.push(line);
		}

		return lines;
	}

	pi.on("session_start", async (_event, ctx) => {
		if (enabled) install(ctx as Parameters<typeof install>[0]);
		checkDrift(ctx);
	});

	pi.registerCommand("footer-layout", {
		description: "Customize the extension-status line in the footer",
		getArgumentCompletions: (prefix: string) => {
			const opts = ["keys", "show", "left", "right", "sep", "hide", "unhide", "reset", "on", "off", "drift-check"];
			const items = opts.filter((o) => o.startsWith(prefix)).map((o) => ({ value: o, label: o }));
			return items.length > 0 ? items : null;
		},
		handler: async (args, ctx) => {
			const trimmed = (args ?? "").trim();

			// No args — show an interactive menu if we have a UI, else fall
			// through to printing the current config.
			if (trimmed === "" && ctx.hasUI) {
				type MenuItem = { label: string; value: string };
				const menu: MenuItem[] = [
					{ label: "show — print current config",                 value: "show" },
					{ label: "keys — list live status keys",                value: "keys" },
					{ label: "left — set left zone order",                  value: "left" },
					{ label: "right — set right zone order",                value: "right" },
					{ label: "sep — set separator",                         value: "sep" },
					{ label: "hide — hide a key",                           value: "hide" },
					{ label: "unhide — stop hiding a key",                  value: "unhide" },
					{ label: "reset — restore defaults",                    value: "reset" },
					{ label: "on — enable custom footer",                   value: "on" },
					{ label: "off — restore pi's default footer",           value: "off" },
					{ label: "drift-check — compare to tested pi version",   value: "drift-check" },
				];
				const picked = await ctx.ui.select(
					"footer-layout",
					menu.map((m) => m.label),
				);
				if (!picked) return;
				const chosen = menu.find((m) => m.label === picked)?.value;
				if (!chosen) return;

				// For subcommands that need extra input, prompt now.
				let extra = "";
				if (chosen === "left" || chosen === "right") {
					const current = chosen === "left" ? cfg.left : cfg.right;
					const reply = await ctx.ui.input(
						`${chosen} zone (space-separated keys; use * for wildcard)`,
						current.join(" "),
					);
					if (reply === undefined) return;
					extra = reply;
				} else if (chosen === "sep") {
					const reply = await ctx.ui.input(
						`separator string (quote to preserve spaces, e.g. \" │ \")`,
						JSON.stringify(cfg.separator),
					);
					if (reply === undefined) return;
					extra = reply;
				} else if (chosen === "hide") {
					const reply = await ctx.ui.input(
						`key to hide (or space-separated keys)`,
					);
					if (reply === undefined || reply.trim() === "") return;
					extra = reply;
				} else if (chosen === "unhide") {
					if (cfg.hide.length === 0) {
						ctx.ui.notify("No keys are currently hidden.", "info");
						return;
					}
					const reply = await ctx.ui.select(
						"key to unhide",
						cfg.hide,
					);
					if (!reply) return;
					extra = reply;
				}

				// Recurse through the same handler with a synthesized args string.
				return handleSubcommand(chosen, extra, ctx);
			}

			const tokens = tokenize(trimmed);
			const sub = (tokens[0] ?? "").toLowerCase();
			const restStr = trimmed.replace(/^\S+\s*/, "");
			return handleSubcommand(sub, restStr, ctx);
		},
	});

	// Shared subcommand executor used by both the menu path and the direct
	// `/footer-layout <sub> ...` path.
	// Shared subcommand executor used by both the menu path and the direct
	// `/footer-layout <sub> ...` path. ctx is typed loosely because it must
	// accept ExtensionCommandContext (for install()) and also provide ui.input
	// / ui.select which are on the narrower command UI surface.
	async function handleSubcommand(sub: string, restStr: string, ctx: any): Promise<void> {
		const rest = tokenize(restStr);

		switch (sub) {
			case "":
			case "show": {
				ctx.ui.notify(
					`Footer layout:\n` +
					`  separator: ${JSON.stringify(cfg.separator)}\n` +
					`  left:  [${cfg.left.join(", ")}]\n` +
					`  right: [${cfg.right.join(", ")}]\n` +
					`  hide:  [${cfg.hide.join(", ")}]\n` +
					`  status: ${enabled ? "on (custom footer active)" : "off (pi default footer)"}`,
					"info",
				);
				return;
			}

			case "keys": {
				const live = lastSeenKeys.length > 0
					? lastSeenKeys.map((k) => `  ${k}`).join("\n")
					: "  (none yet — render hasn't happened or no extensions call setStatus)";
				const configured = [...new Set([...cfg.left, ...cfg.right, ...cfg.hide])]
					.filter((k) => k !== "*");
				const unknown = lastSeenKeys.filter((k) => !configured.includes(k));
				ctx.ui.notify(
					`Live status keys:\n${live}\n\n` +
					`Referenced in config: ${configured.join(", ") || "(none)"}\n` +
					`Live but unreferenced: ${unknown.join(", ") || "(none)"}`,
					"info",
				);
				return;
			}

			case "drift-check": {
				const probe = probePi();
				if (!probe) {
					ctx.ui.notify("drift-check: could not locate pi's footer.js", "warning");
					return;
				}
				const vOk = probe.version === TESTED_PI_VERSION;
				const hOk = probe.hash === TESTED_FOOTER_HASH;
				ctx.ui.notify(
					`Drift check:\n` +
					`  pi version: ${probe.version} ${vOk ? "✓ matches tested" : `✗ tested with ${TESTED_PI_VERSION}`}\n` +
					`  footer hash: ${probe.hash.slice(0, 12)}… ${hOk ? "✓ matches tested" : "✗ differs from tested"}\n` +
					`  footer path: ${probe.footerPath}\n` +
					(vOk && hOk
						? "Footer layout should match pi's default."
						: "Lines 1-2 of the custom footer may have drifted from pi's default. Diff the files, then update TESTED_PI_VERSION and TESTED_FOOTER_HASH in footer-layout.ts."),
					vOk && hOk ? "success" : "warning",
				);
				return;
			}

			case "left": {
				cfg.left = rest.length > 0 ? rest : DEFAULT_CONFIG.left;
				break;
			}

			case "right": {
				cfg.right = rest.length > 0 ? rest : DEFAULT_CONFIG.right;
				break;
			}

			case "sep": {
				// restStr is the raw remainder after the subcommand, preserved
				// with internal whitespace so quoted separators like " │ " work.
				cfg.separator = unquote(restStr) || DEFAULT_CONFIG.separator;
				break;
			}

			case "hide": {
				if (rest.length === 0) {
					ctx.ui.notify("Usage: /footer-layout hide <key>", "warning");
					return;
				}
				for (const k of rest) if (!cfg.hide.includes(k)) cfg.hide.push(k);
				break;
			}

			case "unhide": {
				if (rest.length === 0) {
					ctx.ui.notify("Usage: /footer-layout unhide <key>", "warning");
					return;
				}
				cfg.hide = cfg.hide.filter((k) => !rest.includes(k));
				break;
			}

			case "reset": {
				cfg = { ...DEFAULT_CONFIG };
				break;
			}

			case "on": {
				enabled = true;
				install(ctx);
				ctx.ui.notify("Custom footer enabled", "success");
				return;
			}

			case "off": {
				enabled = false;
				ctx.ui.setFooter(undefined);
				tuiRef = null;
				ctx.ui.notify("Custom footer disabled (pi default restored)", "info");
				return;
			}

			default:
				ctx.ui.notify(
					`Unknown subcommand "${sub}". Try: keys | show | left | right | sep | hide | unhide | reset | on | off | drift-check`,
					"warning",
				);
				return;
		}

		saveConfig(cfg);
		requestRender();
		ctx.ui.notify("Footer layout updated", "success");
	}
}

// --- Helpers --------------------------------------------------------------

function tokenize(s: string): string[] {
	const out: string[] = [];
	let cur = "";
	let quote: '"' | "'" | null = null;
	for (const ch of s) {
		if (quote) {
			if (ch === quote) quote = null;
			else cur += ch;
		} else if (ch === '"' || ch === "'") {
			quote = ch;
		} else if (ch === " " || ch === "\t") {
			if (cur) { out.push(cur); cur = ""; }
		} else {
			cur += ch;
		}
	}
	if (cur) out.push(cur);
	return out;
}

function unquote(s: string): string {
	const t = s.trim();
	if (t.length >= 2 && ((t[0] === '"' && t[t.length - 1] === '"') || (t[0] === "'" && t[t.length - 1] === "'"))) {
		return t.slice(1, -1);
	}
	return t;
}
