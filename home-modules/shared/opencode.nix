{ ... }:
let
  shared_prompt = builtins.readFile ./claude/config/PROMPT.md;
in
{
  xdg.configFile."opencode/AGENTS.md".source = ./AGENTS.md;
  # https://opencode.ai/docs/config
  xdg.configFile."opencode/agents/review.md".source =
    ./skills/review/SKILL.md;
  xdg.configFile."opencode/prompts/brainstorm.txt".text = ''
    ${shared_prompt}
  '';
  xdg.configFile."opencode/prompts/plan.txt".text = ''
    ${shared_prompt}
    I encourage thoughtful feedback and creative alternatives, rather than simple acceptance.
  '';
  xdg.configFile."opencode/prompts/build.txt".text = ''
    ${shared_prompt}
    I encourage thoughtful feedback and creative alternatives, rather than simple acceptance.
  '';
  # /commit command - references shared skill file; opencode ignores unknown
  # frontmatter fields (disable-model-invocation, allowed-tools) harmlessly.
  xdg.configFile."opencode/commands/commit.md".source = ./skills/commit/SKILL.md;
}
