{ ... }:
let
  shared_prompt = builtins.readFile ./claude/config/PROMPT.md;
in
{
  # https://opencode.ai/docs/config
  xdg.configFile."opencode/agents/review.md".text = ''
    You are in code review mode. Focus on:

    - Code quality and best practices
    - Potential bugs and edge cases
    - Performance implications
    - Security considerations

    Provide constructive feedback without making direct changes.
  '';
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
}
