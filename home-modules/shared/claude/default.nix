{ config, ... }:
let
  cfg = "${config.home.homeDirectory}/.config/nixos-config/home-modules/shared";
in
{
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/claude/config/CLAUDE.md";
  home.file.".claude/PROMPT.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/claude/config/PROMPT.md";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/claude/config/settings.json";
  home.file.".claude/skills/github-mcp/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/claude/config/skills/github-mcp/SKILL.md";
  home.file.".claude/skills/commit/SKILL.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/skills/commit/SKILL.md";
}
