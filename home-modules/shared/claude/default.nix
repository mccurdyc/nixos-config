{ ... }: {
  home.file.".claude/CLAUDE.md".source = ./config/CLAUDE.md;
  home.file.".claude/PROMPT.md".source = ./config/PROMPT.md;
  home.file.".claude/settings.json".source = ./config/settings.json;
  home.file.".claude/skills/github-mcp/SKILL.md".source =
    ./config/skills/github-mcp/SKILL.md;
  home.file.".claude/skills/commit/SKILL.md".source =
    ../skills/commit/SKILL.md;
}
