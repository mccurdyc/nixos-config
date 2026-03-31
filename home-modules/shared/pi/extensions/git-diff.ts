import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Text } from "@mariozechner/pi-tui";
import { Type } from "@sinclair/typebox";
import { execSync } from "child_process";

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "git_diff",
    label: "Git Diff",
    description: "Show a full git diff. Use to see exactly what changed in the working tree or between commits.",
    parameters: Type.Object({
      args: Type.Optional(Type.String({ description: 'Git diff arguments, e.g. "HEAD", "HEAD~1", "--staged", a branch name, etc.' })),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      const args = params.args ?? "HEAD";
      const cmd = `git --no-pager diff ${args} -- . ':(exclude)*lock*' ':(exclude)*.lock'`;
      try {
        let output = execSync(cmd, { cwd: ctx.cwd, encoding: "utf-8", maxBuffer: 1024 * 1024 });

        // Include untracked files when diffing working tree (HEAD or --cached)
        if (/HEAD|--cached|--staged/.test(args)) {
          try {
            const untracked = execSync("git ls-files --others --exclude-standard", { cwd: ctx.cwd, encoding: "utf-8" }).trim();
            if (untracked) {
              for (const file of untracked.split("\n")) {
                if (/lock/i.test(file)) continue;
                try {
                  execSync(`git --no-pager diff --no-index /dev/null ${file}`, { cwd: ctx.cwd, encoding: "utf-8", maxBuffer: 1024 * 1024 });
                } catch (diffErr: any) {
                  // --no-index exits 1 when there are differences (always for new files)
                  if (diffErr.stdout) output += diffErr.stdout;
                }
              }
            }
          } catch (_) { /* ignore ls-files errors */ }
        }

        return {
          content: [{ type: "text", text: output || "No changes." }],
          details: { diff: output, args },
        };
      } catch (e: any) {
        return {
          content: [{ type: "text", text: `Error: ${e.message}` }],
          details: { error: e.message },
        };
      }
    },
    renderResult(result, _options, theme, _context) {
      const details = result.details;
      if (details?.error) {
        return new Text(theme.fg("error", details.error), 0, 0);
      }
      const diff = details?.diff;
      if (!diff) return new Text(theme.fg("muted", "No changes."), 0, 0);
      const lines = diff.split("\n");
      const colored = lines.map((line: string) => {
        if (line.startsWith("diff --git")) {
          return theme.fg("muted", line);
        }
        if (line.startsWith("---") || line.startsWith("+++")) {
          return theme.fg("muted", line);
        }
        if (line.startsWith("@@")) {
          return theme.fg("toolDiffContext", line);
        }
        if (line.startsWith("+")) {
          return theme.fg("toolDiffAdded", line);
        }
        if (line.startsWith("-")) {
          return theme.fg("toolDiffRemoved", line);
        }
        return line;
      });
      return new Text(colored.join("\n"), 0, 0);
    },
  });
}
