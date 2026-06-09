{ config, ... }:
let
  cfg = "${config.home.homeDirectory}/.config/nixos-config/home-modules/shared";
in
{
  home.file.".claude/CLAUDE.md" = {
    source = config.lib.file.mkOutOfStoreSymlink "${cfg}/claude/config/CLAUDE.md";
    force = true;
  };
  home.file.".claude/PROMPT.md" = {
    source = config.lib.file.mkOutOfStoreSymlink "${cfg}/claude/config/PROMPT.md";
    force = true;
  };
  home.file.".claude/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${cfg}/claude/config/settings.json";
    force = true;
  };
  home.file.".claude/skills/github-mcp/SKILL.md" = {
    source = ../skills/github-mcp/SKILL.md;
    force = true;
  };
  home.file.".claude/skills/google-workspace/SKILL.md" = {
    source = ../skills/google-workspace/SKILL.md;
    force = true;
  };
  home.file.".claude/skills/atlassian/SKILL.md" = {
    source = ../skills/atlassian/SKILL.md;
    force = true;
  };
  home.file.".claude/skills/commit/SKILL.md" = {
    source = ../skills/commit/SKILL.md;
    force = true;
  };
  home.file.".claude/skills/review/SKILL.md" = {
    source = ../skills/review/SKILL.md;
    force = true;
  };
  home.file.".claude/skills/demo-recording/SKILL.md" = {
    source = ../skills/demo-recording/SKILL.md;
    force = true;
  };
  home.file.".claude/skills/screenshot/SKILL.md" = {
    source = ../skills/screenshot/SKILL.md;
    force = true;
  };
  home.file.".claude/skills/go-do/SKILL.md" = {
    source = ../skills/go-do/SKILL.md;
    force = true;
  };
}
