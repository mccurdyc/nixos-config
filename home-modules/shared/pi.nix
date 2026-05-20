{ config, pkgs, ... }:
let
  cfg = "${config.home.homeDirectory}/.config/nixos-config/home-modules/shared";

  # Build @anthropic-ai/sandbox-runtime and its transitive deps via Nix
  # so the sandbox extension can resolve them via a co-located node_modules
  # symlink.
  sandboxDeps = pkgs.buildNpmPackage {
    pname = "pi-extension-sandbox-deps";
    version = "1.0.0";
    src = ./pi/extensions/sandbox;
    npmDepsHash = "sha256-C5OQ8v0jEGJPyXkMmtjV3IazuySGJzwM9rTilhgY0n8=";
    dontNpmBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r node_modules $out/
      runHook postInstall
    '';
  };
in
{
  # node_modules symlink so the sandbox extension's index.ts can resolve
  # @anthropic-ai/sandbox-runtime via normal Node.js module resolution.
  # Node uses the symlink path (not the Nix store realpath) for lookups.

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
  home.file.".pi/agent/skills/atlassian/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/skills/atlassian/SKILL.md";
  home.file.".pi/agent/skills/demo-recording/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/skills/demo-recording/SKILL.md";
  home.file.".pi/agent/skills/git-diff/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/skills/git-diff/SKILL.md";
  home.file.".pi/agent/skills/diff-here/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/skills/diff-here/SKILL.md";
  home.file.".pi/agent/skills/interactive-questionnaire/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/skills/interactive-questionnaire/SKILL.md";
  home.file.".pi/agent/skills/screenshot/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/skills/screenshot/SKILL.md";
  home.file.".pi/agent/skills/web-search/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/skills/web-search/SKILL.md";
  home.file.".pi/agent/skills/headless-web/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/skills/headless-web/SKILL.md";
  home.file.".pi/agent/skills/headless-web/scripts".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/skills/headless-web/scripts";

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
  # Sandbox extension: index.ts is symlinked for live editing; npm deps
  # are resolved via a co-located node_modules symlink.
  home.file.".pi/agent/extensions/sandbox/index.ts".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/sandbox/index.ts";
  home.file.".pi/agent/extensions/sandbox/node_modules" = {
    source = config.lib.file.mkOutOfStoreSymlink "${sandboxDeps}/node_modules";
    force = true;
  };
  home.file.".pi/agent/extensions/sandbox.json".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/sandbox.json";
  home.file.".pi/agent/extensions/browser-diff.ts".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/browser-diff.ts";
  home.file.".pi/agent/extensions/collapse-tools.ts".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/extensions/collapse-tools.ts";

  # Custom theme derived from the neovim colorscheme.
  home.file.".pi/agent/themes/mccurdyc-minimal.json".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/pi/themes/mccurdyc-minimal.json";
}
