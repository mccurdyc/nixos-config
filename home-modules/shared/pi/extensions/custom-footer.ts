/**
 * Custom Footer Extension
 *
 * Shows session token usage and daily token usage in the footer.
 * - Left: session usage (↑input ↓output $cost)
 * - Right: daily usage (↑input ↓output $cost) | model (branch)
 *
 * Daily usage is computed by scanning today's session files on session_start
 * and incrementally updated as the current session progresses.
 */

import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { getAgentDir } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

interface UsageStats {
  input: number;
  output: number;
  cost: number;
}

function fmt(n: number): string {
  if (n < 1000) return `${n}`;
  if (n < 1000000) return `${(n / 1000).toFixed(1)}k`;
  return `${(n / 1000000).toFixed(1)}M`;
}

function getSessionUsage(ctx: ExtensionContext): UsageStats {
  let input = 0,
    output = 0,
    cost = 0;
  for (const e of ctx.sessionManager.getBranch()) {
    if (e.type === "message" && e.message.role === "assistant") {
      const m = e.message as AssistantMessage;
      input += m.usage.input;
      output += m.usage.output;
      cost += m.usage.cost.total;
    }
  }
  return { input, output, cost };
}

/**
 * Scan all session files created today across all projects.
 * Parse each JSONL file looking for assistant message entries with usage.
 */
function getDailyUsageFromDisk(): UsageStats {
  const sessionsDir = join(getAgentDir(), "sessions");
  const today = new Date().toISOString().slice(0, 10); // YYYY-MM-DD
  let input = 0,
    output = 0,
    cost = 0;

  let projectDirs: string[];
  try {
    projectDirs = readdirSync(sessionsDir);
  } catch {
    return { input, output, cost };
  }

  for (const projectDir of projectDirs) {
    const projectPath = join(sessionsDir, projectDir);
    let files: string[];
    try {
      files = readdirSync(projectPath);
    } catch {
      continue;
    }

    for (const file of files) {
      if (!file.endsWith(".jsonl")) continue;
      // File format: YYYY-MM-DDTHH-MM-SS-mmmZ_uuid.jsonl
      if (!file.startsWith(today)) continue;

      try {
        const content = readFileSync(join(projectPath, file), "utf-8");
        for (const line of content.split("\n")) {
          if (!line.trim()) continue;
          try {
            const entry = JSON.parse(line);
            if (
              entry.type === "message" &&
              entry.message?.role === "assistant" &&
              entry.message?.usage
            ) {
              input += entry.message.usage.input || 0;
              output += entry.message.usage.output || 0;
              cost += entry.message.usage.cost?.total || 0;
            }
          } catch {
            // skip malformed lines
          }
        }
      } catch {
        // skip unreadable files
      }
    }
  }

  return { input, output, cost };
}

export default function (pi: ExtensionAPI) {
  // Daily usage baseline from other sessions (computed once at start).
  let dailyBaseline: UsageStats = { input: 0, output: 0, cost: 0 };
  // Current session file so we can subtract it from the baseline
  // (the disk scan includes the current session).
  let sessionAtBaseline: UsageStats = { input: 0, output: 0, cost: 0 };

  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;

    // Compute daily baseline from disk (includes current session's persisted state).
    dailyBaseline = getDailyUsageFromDisk();
    sessionAtBaseline = getSessionUsage(ctx);

    ctx.ui.setFooter((tui, theme, footerData) => {
      const unsub = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose: unsub,
        invalidate() {},
        render(width: number): string[] {
          const session = getSessionUsage(ctx);

          // Daily = baseline (other sessions + current at scan time)
          //       - current at scan time (avoid double-counting)
          //       + current now
          const daily: UsageStats = {
            input: dailyBaseline.input - sessionAtBaseline.input + session.input,
            output: dailyBaseline.output - sessionAtBaseline.output + session.output,
            cost: dailyBaseline.cost - sessionAtBaseline.cost + session.cost,
          };

          const branch = footerData.getGitBranch();
          const branchStr = branch ? ` (${branch})` : "";
          const model = ctx.model?.id || "no-model";

          const left = theme.fg(
            "dim",
            `session: ↑${fmt(session.input)} ↓${fmt(session.output)} $${session.cost.toFixed(3)}`,
          );
          const right = theme.fg(
            "dim",
            `daily: ↑${fmt(daily.input)} ↓${fmt(daily.output)} $${daily.cost.toFixed(3)} │ ${model}${branchStr}`,
          );

          const pad = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(right)));
          return [truncateToWidth(left + pad + right, width)];
        },
      };
    });
  });
}
