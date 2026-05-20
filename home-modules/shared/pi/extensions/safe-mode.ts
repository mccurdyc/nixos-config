/**
 * Safe Mode Extension
 *
 * Three-mode "ask-before-dangerous-action" guardrail.
 *
 * Modes:
 *   strict   Allowlist only. Hard-block everything else (no Y/N prompt).
 *            Only a small set of read-only bash commands is allowed.
 *            All writes/edits are blocked.
 *   on       Blocklist (default). Prompts Y/N before known-dangerous
 *            bash commands and writes to sensitive paths.
 *   off      YOLO. Everything passes through.
 *
 * Toggle with:   /safe-mode            (on <-> off toggle)
 *                /safe-mode on
 *                /safe-mode off
 *                /safe-mode strict
 *                /safe-mode status
 *
 * State persists across pi restarts in ~/.pi/safe-mode.json.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, isAbsolute, join, resolve } from "node:path";

const STATE_FILE = join(homedir(), ".pi", "safe-mode.json");

type Mode = "off" | "on" | "strict";
type State = { mode: Mode };

function loadState(): State {
	try {
		if (existsSync(STATE_FILE)) {
			const raw = JSON.parse(readFileSync(STATE_FILE, "utf8"));
			if (raw.mode === "off" || raw.mode === "on" || raw.mode === "strict") {
				return { mode: raw.mode };
			}
			// Back-compat with { enabled: boolean }
			if (typeof raw.enabled === "boolean") {
				return { mode: raw.enabled ? "on" : "off" };
			}
		}
	} catch {
		// fall through to default
	}
	return { mode: "on" }; // blocklist ON by default
}

function saveState(state: State): void {
	try {
		mkdirSync(dirname(STATE_FILE), { recursive: true });
		writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
	} catch {
		// best effort
	}
}

// --- Danger heuristics (blocklist, used in "on" mode) ----------------------

const dangerousBashPatterns: { pattern: RegExp; why: string }[] = [
	{ pattern: /\brm\s+(-[a-z]*r[a-z]*f?|-[a-z]*f[a-z]*r?|--recursive|--force)/i, why: "recursive/forced rm" },
	{ pattern: /\bsudo\b/i, why: "sudo" },
	{ pattern: /\b(chmod|chown)\b[^\n]*\b777\b/i, why: "chmod/chown 777" },
	{ pattern: /\bmkfs(\.[a-z0-9]+)?\b/i, why: "mkfs (formats filesystem)" },
	{ pattern: /\bdd\b[^\n]*\bof=/i, why: "dd with of= (raw disk write)" },
	{ pattern: /\|\s*(sudo\s+)?(sh|bash|zsh)\b/i, why: "piping into a shell" },
	{ pattern: /\bcurl\b[^\n|]*\|\s*(sudo\s+)?(sh|bash|zsh)\b/i, why: "curl | sh" },
	{ pattern: /\bwget\b[^\n|]*\|\s*(sudo\s+)?(sh|bash|zsh)\b/i, why: "wget | sh" },
	{ pattern: /\bgit\s+push\b[^\n]*\s(--force|-f)\b/i, why: "git push --force" },
	{ pattern: /\bgit\s+reset\s+--hard\b/i, why: "git reset --hard" },
	{ pattern: /\bgit\s+clean\s+-[a-z]*[fd]/i, why: "git clean -fd" },
	{ pattern: /\bnpm\s+publish\b/i, why: "npm publish" },
	{ pattern: /\s>\s*\/(etc|usr|bin|sbin|var|System)\//i, why: "redirect into system path" },
	{ pattern: /\brm\s+[^\n]*\s\/(\s|$)/i, why: "rm on /" },
];

const sensitivePathPatterns: { pattern: RegExp; why: string }[] = [
	{ pattern: /(^|\/)\.env($|\.)/, why: ".env file" },
	{ pattern: /(^|\/)\.ssh(\/|$)/, why: "SSH config/keys" },
	{ pattern: /(^|\/)\.aws(\/|$)/, why: "AWS credentials" },
	{ pattern: /(^|\/)\.gnupg(\/|$)/, why: "GPG keys" },
	{ pattern: /(^|\/)\.(zshrc|bashrc|bash_profile|zprofile|profile)$/, why: "shell rc file" },
	{ pattern: /(^|\/)\.netrc$/, why: ".netrc" },
	{ pattern: /(^|\/)id_(rsa|ed25519|ecdsa|dsa)(\.pub)?$/, why: "SSH private key" },
];

function checkBashDanger(command: string): string | null {
	for (const { pattern, why } of dangerousBashPatterns) {
		if (pattern.test(command)) return why;
	}
	return null;
}

function checkPathDanger(path: string, cwd: string): string | null {
	for (const { pattern, why } of sensitivePathPatterns) {
		if (pattern.test(path)) return why;
	}
	// Writing outside the project directory
	const absolute = isAbsolute(path) ? resolve(path) : resolve(cwd, path);
	const projectRoot = resolve(cwd);
	if (!absolute.startsWith(projectRoot + "/") && absolute !== projectRoot) {
		return `outside project directory (${absolute})`;
	}
	return null;
}

// --- Strict allowlist ------------------------------------------------------

// Single read-only commands. First token of the bash invocation must be here.
const STRICT_ALLOWED_COMMANDS = new Set<string>([
	// navigation / inspection
	"ls", "pwd", "stat", "file", "which", "type", "tree", "realpath", "readlink",
	"basename", "dirname",
	// reading
	"cat", "head", "tail", "less", "more", "wc", "nl",
	// search
	"rg", "grep", "fd", "find",
	// text / data
	"echo", "printf", "sort", "uniq", "cut", "awk", "sed", "jq", "yq",
	"diff", "tr", "column", "xmllint",
	// env / info
	"env", "date", "whoami", "hostname", "uname", "id", "pwd",
	// git (subcommand checked separately)
	"git",
]);

// Any of these characters/operators in the command → reject.
// We refuse to parse anything with pipes, redirects, substitutions, or chaining.
const SHELL_METACHAR_RE = /[|;&<>`$()\\]|\n|\r/;

// Subcommand rules for `git`.
const GIT_READONLY_SUBCOMMANDS = new Set<string>([
	"status", "log", "diff", "show", "blame", "remote", "rev-parse",
	"ls-files", "ls-tree", "describe", "shortlog", "cat-file", "grep",
	"reflog", "config",
]);
// Subcommands that are read-only by default but have destructive flags.
const GIT_CONDITIONAL_SUBCOMMANDS = new Set<string>(["branch", "tag", "stash", "worktree"]);
const GIT_DESTRUCTIVE_FLAGS = /^(-d|-D|--delete|-m|-M|--move|--force|-f|--prune|--remove)$/;

// Per-command forbidden flags.
const FORBIDDEN_FLAGS: Record<string, RegExp> = {
	sed: /^(-i|--in-place)(=.*)?$/,
	find: /^(-delete|-exec|-execdir|-ok|-okdir)$/,
	rg: /^--?pre$|^--search-zip$/, // external-program flags
};

function checkBashStrict(command: string): string | null {
	const trimmed = command.trim();
	if (!trimmed) return "empty command";

	if (SHELL_METACHAR_RE.test(trimmed)) {
		return "shell operators not allowed in strict mode (no pipes, redirects, substitutions, chaining)";
	}

	// Naive tokenization is OK because we've banned all metacharacters.
	// Still handle simple single/double quoted tokens for string args.
	const tokens = tokenize(trimmed);
	if (tokens.length === 0) return "empty command";

	const cmd = tokens[0];
	if (!STRICT_ALLOWED_COMMANDS.has(cmd)) {
		return `command "${cmd}" not in strict allowlist`;
	}

	// git-specific rules
	if (cmd === "git") {
		const sub = tokens[1];
		if (!sub) return null; // bare `git` just prints help — safe
		if (GIT_READONLY_SUBCOMMANDS.has(sub)) return null;
		if (GIT_CONDITIONAL_SUBCOMMANDS.has(sub)) {
			if (sub === "stash") {
				const action = tokens[2];
				if (action === "list" || action === "show" || action === undefined) return null;
				return `git stash ${action ?? ""} not allowed in strict mode`;
			}
			for (const t of tokens.slice(2)) {
				if (GIT_DESTRUCTIVE_FLAGS.test(t)) {
					return `git ${sub} ${t} not allowed in strict mode`;
				}
			}
			return null;
		}
		return `git subcommand "${sub}" not in strict allowlist`;
	}

	// Forbidden-flag check for other commands
	const flagRe = FORBIDDEN_FLAGS[cmd];
	if (flagRe) {
		for (const t of tokens.slice(1)) {
			if (flagRe.test(t)) {
				return `${cmd} ${t} not allowed in strict mode`;
			}
		}
	}

	return null;
}

// Minimal tokenizer: splits on whitespace, respects single/double quotes.
// We've already rejected backticks, $(), \, etc., so this is safe-ish.
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

// --- Extension -------------------------------------------------------------

export default function (pi: ExtensionAPI) {
	const state = loadState();

	function footerLabel(theme: { fg: (color: string, text: string) => string; bold: (text: string) => string }): string {
		// STRICT → bold green, SAFE → green, YOLO → bold red.
		// Spacing between footer segments is handled by the footer-layout
		// extension; no leading padding needed here.
		switch (state.mode) {
			case "strict": return theme.fg("success", theme.bold("STRICT"));
			case "on":     return theme.fg("success", "SAFE");
			case "off":    return theme.fg("error",   theme.bold("YOLO"));
		}
	}

	function updateFooter(ctx?: { ui: { theme: { fg: (color: string, text: string) => string; bold: (text: string) => string }; setStatus: (id: string, text: string) => void } }) {
		if (ctx) ctx.ui.setStatus("safe-mode", footerLabel(ctx.ui.theme));
	}

	pi.on("session_start", async (_event, ctx) => {
		updateFooter(ctx);
	});

	pi.registerCommand("safe-mode", {
		description: "Safe mode: strict (allowlist) | on (blocklist) | off (YOLO)",
		getArgumentCompletions: (prefix: string) => {
			const opts = ["strict", "on", "off", "toggle", "status"];
			const items = opts
				.filter((o) => o.startsWith(prefix))
				.map((o) => ({ value: o, label: o }));
			return items.length > 0 ? items : null;
		},
		handler: async (args, ctx) => {
			const arg = (args ?? "").trim().toLowerCase();
			switch (arg) {
				case "":
				case "toggle":
					// Toggle between on and off only; strict must be set explicitly.
					state.mode = state.mode === "off" ? "on" : "off";
					break;
				case "on":
				case "enable":
					state.mode = "on";
					break;
				case "off":
				case "disable":
					state.mode = "off";
					break;
				case "strict":
				case "paranoid":
					state.mode = "strict";
					break;
				case "status": {
					const msg =
						state.mode === "strict" ? "Safe mode: STRICT (allowlist; everything else hard-blocked)" :
						state.mode === "on"     ? "Safe mode: ON (blocklist; prompts before dangerous actions)" :
						                          "Safe mode: OFF (YOLO)";
					ctx.ui.notify(msg, "info");
					return;
				}
				default:
					ctx.ui.notify(
						`Unknown argument "${arg}". Use: strict | on | off | toggle | status`,
						"warning",
					);
					return;
			}
			saveState(state);
			updateFooter(ctx);
			const msg =
				state.mode === "strict"
					? "Safe mode → STRICT — allowlist only, hard-blocks everything else"
					: state.mode === "on"
					? "Safe mode → ON — will ask before dangerous actions"
					: "Safe mode → OFF — YOLO mode";
			ctx.ui.notify(msg, state.mode === "off" ? "warning" : "success");
		},
	});

	pi.on("tool_call", async (event, ctx) => {
		if (state.mode === "off") return undefined;

		// --- STRICT MODE: allowlist, hard-block ---
		if (state.mode === "strict") {
			if (event.toolName === "bash") {
				const command = (event.input as { command?: string }).command ?? "";
				const reason = checkBashStrict(command);
				if (reason) {
					const msg = `Blocked by STRICT safe mode: ${reason}`;
					if (ctx.hasUI) ctx.ui.notify(msg, "warning");
					return { block: true, reason: msg };
				}
				return undefined;
			}
			if (event.toolName === "write" || event.toolName === "edit") {
				const msg = `Blocked by STRICT safe mode: ${event.toolName} is not allowed`;
				if (ctx.hasUI) ctx.ui.notify(msg, "warning");
				return { block: true, reason: msg };
			}
			return undefined;
		}

		// --- ON MODE: blocklist, prompt to allow ---
		let reason: string | null = null;
		let detail = "";

		if (event.toolName === "bash") {
			const command = (event.input as { command?: string }).command ?? "";
			reason = checkBashDanger(command);
			if (reason) detail = command;
		} else if (event.toolName === "write" || event.toolName === "edit") {
			const path = (event.input as { path?: string }).path ?? "";
			reason = checkPathDanger(path, ctx.cwd);
			if (reason) detail = `${event.toolName} ${path}`;
		}

		if (!reason) return undefined;

		if (!ctx.hasUI) {
			return { block: true, reason: `Safe mode blocked: ${reason} (no UI to confirm)` };
		}

		const choice = await ctx.ui.select(
			`Safe mode — ${reason}\n\n  ${detail}\n\nAllow?`,
			["No, block it", "Yes, allow once"],
		);

		if (choice !== "Yes, allow once") {
			ctx.ui.notify(`Blocked by safe mode (${reason})`, "warning");
			return { block: true, reason: `Blocked by safe mode: ${reason}` };
		}
		return undefined;
	});
}
