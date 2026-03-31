import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Text } from "@mariozechner/pi-tui";
import { Type } from "@sinclair/typebox";
import { execSync } from "child_process";

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "git_diffstat",
    label: "Git Diffstat",
    description: "Show a colored git diff --stat summary. Use for a quick overview of what files changed and how much.",
    parameters: Type.Object({
      args: Type.Optional(Type.String({ description: 'Git diff arguments, e.g. "HEAD", "HEAD~1", "--staged", a branch name, etc.' })),
    }),

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      const args = params.args ?? "HEAD";
      const cmd = `git --no-pager diff --stat ${args} -- . ':(exclude)*lock*' ':(exclude)*.lock'`;
      try {
        const output = execSync(cmd, { cwd: ctx.cwd, encoding: "utf-8", maxBuffer: 1024 * 1024 });
        return {
          content: [{ type: "text", text: output || "No changes." }],
          details: { stat: output, args },
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
      const stat = details?.stat;
      if (!stat) return new Text(theme.fg("muted", "No changes."), 0, 0);

      const lines = stat.split("\n");
      const colored = lines.map((line: string) => {
        // Summary line: " 2 files changed, 36 insertions(+), 19 deletions(-)"
        if (line.includes("changed")) {
          return line
            .replace(/(\d+ insertion[s]?\(\+\))/, theme.fg("toolDiffAdded", "$1"))
            .replace(/(\d+ deletion[s]?\(-\))/, theme.fg("toolDiffRemoved", "$1"));
        }
        // File stat line: " file.nix | 22 ++++++++++++---------"
        const match = line.match(/^(.+\|\s*\d+\s*)([\+]*)([-]*)(\s*)$/);
        if (match) {
          return theme.fg("muted", match[1])
            + theme.fg("toolDiffAdded", match[2])
            + theme.fg("toolDiffRemoved", match[3])
            + match[4];
        }
        return theme.fg("muted", line);
      });
      return new Text(colored.join("\n"), 0, 0);
    },
  });
}
