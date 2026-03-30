import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("quit", {
    description: "Exit pi cleanly",
    handler: async (_args, ctx) => {
      ctx.shutdown();
    },
  });
}
