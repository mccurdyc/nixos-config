import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { execSync } from "child_process";
import { writeFileSync } from "fs";
import { tmpdir } from "os";
import { join } from "path";

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "browser_diff",
    label: "Browser Diff",
    description:
      "Generate a diff HTML file using diff2html. Returns a file:// URL the user can open in their browser.",
    parameters: Type.Object({
      args: Type.Optional(
        Type.String({
          description:
            'Git diff arguments, e.g. "HEAD", "HEAD~1", "--staged", a branch name, etc.',
        })
      ),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      const args = params.args ?? "HEAD";
      const cmd = `git --no-pager diff ${args} -- . ':(exclude)*lock*' ':(exclude)*.lock'`;
      try {
        let diff = execSync(cmd, {
          cwd: ctx.cwd,
          encoding: "utf-8",
          maxBuffer: 5 * 1024 * 1024,
        });

        // Include untracked files when diffing working tree
        if (/HEAD|--cached|--staged/.test(args)) {
          try {
            const untracked = execSync(
              "git ls-files --others --exclude-standard",
              { cwd: ctx.cwd, encoding: "utf-8" }
            ).trim();
            if (untracked) {
              for (const file of untracked.split("\n")) {
                if (/lock/i.test(file)) continue;
                try {
                  execSync(
                    `git --no-pager diff --no-index /dev/null ${file}`,
                    { cwd: ctx.cwd, encoding: "utf-8", maxBuffer: 5 * 1024 * 1024 }
                  );
                } catch (diffErr: any) {
                  if (diffErr.stdout) diff += diffErr.stdout;
                }
              }
            }
          } catch (_) {
            /* ignore ls-files errors */
          }
        }

        if (!diff.trim()) {
          return { content: [{ type: "text", text: "No changes." }] };
        }

        const html = buildHtml(diff);
        const tmpFile = join(tmpdir(), "pi-diff-" + Date.now() + ".html");
        writeFileSync(tmpFile, html, "utf-8");

        return {
          content: [{ type: "text", text: "file://" + tmpFile }],
        };
      } catch (e: any) {
        return {
          content: [{ type: "text", text: "Error: " + (e as Error).message }],
        };
      }
    },
  });
}

function buildHtml(diff: string): string {
  // Escape </ sequences to prevent HTML parser from closing the script tag
  const escapedDiff = JSON.stringify(diff).replace(/<\//g, '<\\/');
  return [
    '<!DOCTYPE html>',
    '<html lang="en">',
    '<head>',
    '  <meta charset="UTF-8" />',
    '  <title>Git Diff</title>',
    '  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/diff2html/bundles/css/diff2html.min.css" />',
    '  <style>body { margin: 0; padding: 16px; font-family: -apple-system, BlinkMacSystemFont, sans-serif; }</style>',
    '</head>',
    '<body>',
    '  <div id="diff"></div>',
    '  <script src="https://cdn.jsdelivr.net/npm/diff2html/bundles/js/diff2html-ui.min.js"></script>',
    '  <script>',
    '    document.addEventListener("DOMContentLoaded", function () {',
    '      var diffString = ' + escapedDiff + ';',
    '      var targetElement = document.getElementById("diff");',
    '      var diff2htmlUi = new Diff2HtmlUI(targetElement, diffString, {',
    '        drawFileList: true,',
    '        matching: "lines",',
    '        outputFormat: "side-by-side",',
    '        highlight: true,',
    '      });',
    '      diff2htmlUi.draw();',
    '      diff2htmlUi.highlightCode();',
    '    });',
    '  </script>',
    '</body>',
    '</html>',
  ].join('\n');
}
