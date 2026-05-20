/**
 * Config loading, preset resolution, and model-capability checks.
 *
 * Pure functions with only fs / os / path dependencies (and pi-ai type
 * imports). Unit-testable in isolation.
 */

import * as fs from "node:fs";
import { homedir } from "node:os";
import * as path from "node:path";
import type { Api, Model } from "@mariozechner/pi-ai";
import { supportsXhigh } from "@mariozechner/pi-ai";

export const CONFIG_PATH = path.join(homedir(), ".pi", "tmux-workers.yaml");

// Thinking levels accepted by `pi --thinking`. `off` is pi-CLI-only (pi-ai's
// ThinkingLevel type excludes it). `xhigh` is only supported by a subset of
// models — guarded via `supportsXhigh(model)` at wizard time.
export const THINKING_LEVELS = ["off", "minimal", "low", "medium", "high", "xhigh"] as const;
export type ThinkingLevel = typeof THINKING_LEVELS[number];
export const DEFAULT_THINKING_LEVEL: ThinkingLevel = "medium";

export function isThinkingLevel(s: string): s is ThinkingLevel {
	return (THINKING_LEVELS as readonly string[]).includes(s);
}

/** Split a model string like "provider/id:level" into its parts. */
export function parseModelString(s: string): { model: string; thinking?: ThinkingLevel } {
	const m = s.match(/^(.+):([a-z]+)$/);
	if (m && isThinkingLevel(m[2])) {
		return { model: m[1], thinking: m[2] as ThinkingLevel };
	}
	return { model: s };
}

export interface WorkersConfig {
	"model-presets": Record<string, string>;
	"default-worker-model": string;
}

/**
 * Read + parse the tmux-workers yaml config. Returns defaults on missing
 * or malformed files.
 *
 * The parser is intentionally minimal and only understands the shape this
 * package writes itself:
 *
 *   model-presets:
 *     fast: "provider/id:level"
 *     default: "provider/id:level"
 *     heavy: "provider/id:level"
 *
 *   default-worker-model: "default"
 *
 * An optional `configPath` argument is accepted so tests can point at a
 * fixture without setting HOME.
 */
export function loadConfig(configPath: string = CONFIG_PATH): WorkersConfig {
	const defaults: WorkersConfig = {
		"model-presets": {},
		"default-worker-model": "",
	};
	try {
		if (!fs.existsSync(configPath)) return defaults;
		const raw = fs.readFileSync(configPath, "utf-8");
		const lines = raw.split("\n");
		let inPresets = false;
		const presets: Record<string, string> = {};
		let defaultModel = "";
		for (const line of lines) {
			const trimmed = line.trim();
			if (trimmed.startsWith("#") || trimmed === "") continue;
			if (trimmed === "model-presets:") {
				inPresets = true;
				continue;
			}
			if (trimmed.startsWith("default-worker-model:")) {
				inPresets = false;
				defaultModel = trimmed.split(":").slice(1).join(":").trim().replace(/^"|"$/g, "");
				continue;
			}
			if (inPresets && line.startsWith("  ")) {
				const match = trimmed.match(/^([\w-]+):\s*"?([^"]+)"?$/);
				if (match) presets[match[1]] = match[2];
			} else {
				inPresets = false;
			}
		}
		return { "model-presets": presets, "default-worker-model": defaultModel };
	} catch {
		return defaults;
	}
}

/** Check if config exists. */
export function hasConfig(): boolean {
	return fs.existsSync(CONFIG_PATH);
}

/**
 * Write config file from user selections. Each preset string is written
 * as-is; callers should include any `:<level>` suffix they want persisted.
 */
export function writeConfig(fast: string, def: string, heavy: string): void {
	const yaml = [
		"# Tmux Workers Configuration",
		"#",
		"# Model presets for worker agents. Use preset names",
		"# in tmux-delegate's model parameter, or pass a raw",
		"# model pattern directly. Thinking level may be",
		"# appended to any preset as ':<level>' — e.g.",
		"# 'anthropic/claude-sonnet-4-5:medium'.",
		"#",
		"# Valid thinking levels: off, minimal, low, medium, high, xhigh",
		"",
		"model-presets:",
		`  fast: "${fast}"`,
		`  default: "${def}"`,
		`  heavy: "${heavy}"`,
		"",
		'default-worker-model: "default"',
		"",
	].join("\n");
	fs.writeFileSync(CONFIG_PATH, yaml, "utf-8");
}

/**
 * Resolve a model input to its components: raw model ID plus optional
 * thinking level. Handles preset lookup, `:<level>` suffixes on the input,
 * and explicit thinking overrides.
 *
 * Resolution precedence for the thinking level:
 *   1. explicit `thinkingInput`
 *   2. `:<level>` suffix embedded in the input
 *   3. `:<level>` suffix embedded in the resolved preset value
 *   4. undefined (pi falls back to its own default)
 *
 * `configPath` is forwarded to `loadConfig` for test fixtures.
 */
export function resolveModelAndThinking(
	modelInput: string | undefined,
	thinkingInput: string | undefined,
	configPath: string = CONFIG_PATH,
): { model: string; thinking?: ThinkingLevel } {
	const config = loadConfig(configPath);
	const presets = config["model-presets"];
	const defaultPreset = config["default-worker-model"];

	// Pick the raw string we'll parse (from preset, input, or default preset).
	let resolvedStr = "";
	if (!modelInput || modelInput === "") {
		if (defaultPreset && presets[defaultPreset]) resolvedStr = presets[defaultPreset];
	} else if (presets[modelInput]) {
		resolvedStr = presets[modelInput];
	} else {
		resolvedStr = modelInput;
	}

	if (!resolvedStr) return { model: "" };

	const parsed = parseModelString(resolvedStr);

	// Explicit `thinkingInput` always wins over anything in the string.
	if (thinkingInput && isThinkingLevel(thinkingInput)) {
		parsed.thinking = thinkingInput;
	}

	return parsed;
}

/**
 * Enforce model-capability rules on a resolved (model, thinking) pair.
 *
 * * If the resolved model has `reasoning === false`, drop thinking.
 * * If thinking is "xhigh" but the model doesn't support xhigh,
 *   downgrade to "high".
 * * Unknown models (not in the registry) pass through unchanged — pi
 *   will handle / reject as needed.
 *
 * Returns the possibly-adjusted pair and an optional human-readable
 * warning.
 */
export function applyCapabilityCheck(
	resolved: { model: string; thinking?: ThinkingLevel },
	modelRegistry: { find(provider: string, id: string): Model<Api> | undefined } | undefined,
): { model: string; thinking?: ThinkingLevel; warning?: string } {
	if (!resolved.thinking || !modelRegistry || !resolved.model) return resolved;

	const slash = resolved.model.indexOf("/");
	if (slash === -1) return resolved;
	const provider = resolved.model.slice(0, slash);
	const id = resolved.model.slice(slash + 1);

	const model = modelRegistry.find(provider, id);
	if (!model) return resolved; // unknown model — let pi decide

	if (!model.reasoning) {
		return {
			model: resolved.model,
			warning: `Model "${resolved.model}" does not support thinking; --thinking dropped.`,
		};
	}
	if (resolved.thinking === "xhigh" && !supportsXhigh(model)) {
		return {
			model: resolved.model,
			thinking: "high",
			warning: `Model "${resolved.model}" does not support thinking level "xhigh"; downgraded to "high".`,
		};
	}
	return resolved;
}
