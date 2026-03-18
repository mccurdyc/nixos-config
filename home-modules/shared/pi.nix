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

  # Prompt templates: type /review in pi to expand.
  home.file.".pi/agent/prompts/review.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/skills/review/SKILL.md";
}
