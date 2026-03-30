{ config, ... }:
let
  cfg = "${config.home.homeDirectory}/.config/nixos-config/home-modules/shared";
in
{
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/claude/config/CLAUDE.md";
  home.file.".claude/PROMPT.md".source =
    config.lib.file.mkOutOfStoreSymlink "${cfg}/claude/config/PROMPT.md";
  home.file.".claude/skills/github-mcp/SKILL.md".source =
    ../skills/github-mcp/SKILL.md;
  home.file.".claude/skills/google-workspace/SKILL.md".source =
    ../skills/google-workspace/SKILL.md;
  home.file.".claude/skills/commit/SKILL.md".source =
    ../skills/commit/SKILL.md;
  home.file.".claude/skills/review/SKILL.md".source =
    ../skills/review/SKILL.md;
}
