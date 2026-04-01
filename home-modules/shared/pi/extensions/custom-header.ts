/**
 * Clean Start Screen Extension
 *
 * - Replaces the header with just session name + sandbox info
 * - Auto-names sessions after every agent turn via a standalone Haiku call
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { complete } from "@mariozechner/pi-ai";
import { homedir } from "os";
import { readFileSync, existsSync } from "fs";
import { join } from "path";
import { execSync } from "child_process";

function getGitInfo(cwd: string): { repo: string; branch: string } | null {
  try {
    const repo = execSync("basename $(git rev-parse --show-toplevel)", { cwd, encoding: "utf-8" }).trim();
    const branch = execSync("git rev-parse --abbrev-ref HEAD", { cwd, encoding: "utf-8" }).trim();
    return { repo, branch };
  } catch {
    return null;
  }
}

function shortenPath(p: string): string {
  const home = homedir();
  return p.startsWith(home) ? `~${p.slice(home.length)}` : p;
}

function getSandboxSummary(cwd: string): string | null {
  // Check project-level sandbox config first, then global
  const projectConfig = join(cwd, ".pi", "sandbox.json");
  const globalConfig = join(homedir(), ".pi", "agent", "extensions", "sandbox.json");

  let cfg: any = null;
  for (const p of [projectConfig, globalConfig]) {
    if (existsSync(p)) {
      try {
        cfg = JSON.parse(readFileSync(p, "utf-8"));
        break;
      } catch {}
    }
  }
  if (!cfg || cfg.enabled === false) return null;

  const domains = cfg.network?.allowedDomains?.length ?? 0;
  const writePaths = cfg.filesystem?.allowWrite?.length ?? 0;
  return `🔒 ${domains} domains, ${writePaths} write paths`;
}

function extractConversationText(entries: any[]): string {
  const parts: string[] = [];
  for (const entry of entries) {
    if (entry.type !== "message" || !entry.message?.role) continue;
    const role = entry.message.role;
    if (role !== "user" && role !== "assistant") continue;
    const content = entry.message.content;
    let text = "";
    if (typeof content === "string") {
      text = content;
    } else if (Array.isArray(content)) {
      text = content
        .filter((c: any) => c.type === "text" && typeof c.text === "string")
        .map((c: any) => c.text)
        .join("\n");
    }
    if (text.trim()) {
      parts.push(`${role === "user" ? "U" : "A"}: ${text.trim()}`);
    }
  }
  const joined = parts.join("\n\n");
  return joined.length > 4000 ? joined.slice(0, 4000) : joined;
}

export default function (pi: ExtensionAPI) {
  // ── /session-name command ────────────────────────────────────────
  pi.registerCommand("session-name", {
    description: "Set or show session name (usage: /session-name [new name])",
    handler: async (args, ctx) => {
      const name = args.trim();
      if (name) {
        pi.setSessionName(name);
        ctx.ui.notify(`Session named: ${name}`, "info");
      } else {
        const current = pi.getSessionName();
        ctx.ui.notify(current ? `Session: ${current}` : "No session name set", "info");
      }
    },
  });

  // ── Custom header: session name + sandbox info ───────────────────
  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;

    const sandbox = getSandboxSummary(ctx.cwd);

    ctx.ui.setHeader((_tui, theme) => ({
      render(_width: number): string[] {
        const name = pi.getSessionName();
        const sessionLine = name
          ? theme.fg("accent", theme.bold(name))
          : theme.fg("dim", "New session");

        const lines = [`  ${sessionLine}`];
        if (sandbox) {
          lines.push(`  ${theme.fg("dim", sandbox)}`);
        }
        return lines;
      },
      invalidate() {},
    }));
  });

  // ── Auto-name sessions after every agent turn ────────────────────
  pi.on("agent_end", async (_event, ctx) => {
    try {
      const branch = ctx.sessionManager.getBranch();
      const text = extractConversationText(branch);
      if (!text.trim()) return;

      const model = ctx.model;
      if (!model) return;
      const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
      if (!auth.ok || !auth.apiKey) return;

      const response = await complete(
        model,
        {
          systemPrompt:
            "Generate a short name for this conversation. " +
            "Max 40 characters. Return ONLY the name, no quotes, no trailing punctuation.",
          messages: [
            {
              role: "user" as const,
              content: [{ type: "text" as const, text }],
              timestamp: Date.now(),
            },
          ],
        },
        { apiKey: auth.apiKey, headers: auth.headers, signal: ctx.signal },
      );

      const name = response.content
        .filter((c): c is { type: "text"; text: string } => c.type === "text")
        .map((c) => c.text)
        .join("")
        .trim()
        .slice(0, 40);

      if (name) {
        const git = getGitInfo(ctx.cwd);
        const fullName = git ? `${git.repo}/${git.branch}: ${name}` : name;
        pi.setSessionName(fullName);
      }
    } catch {
      // Auto-naming is best-effort
    }
  });
}
