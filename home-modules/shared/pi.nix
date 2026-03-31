{ config, ... }:
let
  cfg = "${config.home.homeDirectory}/.config/nixos-config/home-modules/shared";
in
{
  # https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent
  # pi is installed via Nix (see pkgs/pi-coding-agent/)
  # Config dir: ~/.pi/agent/

  # Global agents file for opencode (~/.config/opencode/AGENTS.md).
  # Also symlinked for pi (~/.pi/agent/AGENTS.md).
  home.file.".pi/agent/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/AGENTS.md";
  home.file.".pi/agent/skills/commit/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/skills/commit/SKILL.md";
  home.file.".pi/agent/skills/google-workspace/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/skills/google-workspace/SKILL.md";

  # Prompt templates: type /review in pi to expand.
  home.file.".pi/agent/prompts/review.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/skills/review/SKILL.md";

  # Subagent workflow prompts.
  home.file.".pi/agent/prompts/implement.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/subagent/prompts/implement.md";
  home.file.".pi/agent/prompts/scout-and-plan.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/subagent/prompts/scout-and-plan.md";
  home.file.".pi/agent/prompts/implement-and-review.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/subagent/prompts/implement-and-review.md";

  # Subagent definitions.
  home.file.".pi/agent/agents/scout.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/subagent/agents/scout.md";
  home.file.".pi/agent/agents/planner.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/subagent/agents/planner.md";
  home.file.".pi/agent/agents/reviewer.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/subagent/agents/reviewer.md";
  home.file.".pi/agent/agents/worker.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/subagent/agents/worker.md";

  # Presets (plan/implement modes).
  home.file.".pi/agent/presets.json".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/presets.json";

  # Extensions
  home.file.".pi/agent/extensions/preset.ts".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/preset.ts";
  home.file.".pi/agent/extensions/minimal-mode.ts".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/minimal-mode.ts";
  home.file.".pi/agent/extensions/qna.ts".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/qna.ts";
  home.file.".pi/agent/extensions/subagent/index.ts".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/subagent/index.ts";
  home.file.".pi/agent/extensions/subagent/agents.ts".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/subagent/agents.ts";
  home.file.".pi/agent/extensions/handoff.ts".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/handoff.ts";
  home.file.".pi/agent/extensions/status-line.ts".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/status-line.ts";
  home.file.".pi/agent/extensions/custom-header.ts".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/custom-header.ts";
  home.file.".pi/agent/extensions/custom-footer.ts".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/custom-footer.ts";
  # Sandbox requires `npm install` in ~/.pi/agent/extensions/sandbox/
  home.file.".pi/agent/extensions/sandbox/index.ts".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/sandbox/index.ts";
  home.file.".pi/agent/extensions/sandbox/package.json".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/sandbox/package.json";
  home.file.".pi/agent/extensions/sandbox/package-lock.json".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/sandbox/package-lock.json";
  home.file.".pi/agent/extensions/git-diffstat.ts".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/git-diffstat.ts";
  home.file.".pi/agent/extensions/git-diff.ts".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/git-diff.ts";

  # Custom theme derived from the neovim colorscheme.
  home.file.".pi/agent/themes/mccurdyc-minimal.json".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/themes/mccurdyc-minimal.json";
}
