/**
 * Custom Header Extension
 *
 * Shows session name (via /session-name) in the header.
 * Falls back to "unnamed session" when no name is set.
 * Also registers the /session-name command.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { VERSION } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  // Register /session-name command
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

  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;

    ctx.ui.setHeader((_tui, theme) => ({
      render(_width: number): string[] {
        const name = pi.getSessionName();
        const label = name
          ? theme.fg("accent", theme.bold(name))
          : theme.fg("dim", "unnamed session");
        const version = theme.fg("dim", `v${VERSION}`);
        return [`  ${label}  ${version}`];
      },
      invalidate() {},
    }));
  });
}
