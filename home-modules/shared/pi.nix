{ ... }:
let
  shared_prompt = builtins.readFile ./claude/config/PROMPT.md;
in
{
  # https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent
  # pi is installed outside Nix: npm install -g @mariozechner/pi-coding-agent
  # Config dir: ~/.pi/agent/

  # Global system prompt loaded at startup from ~/.pi/agent/AGENTS.md.
  # Equivalent to the shared_prompt used across opencode agents.
  home.file.".pi/agent/AGENTS.md".text = ''
    ${shared_prompt}
    I encourage thoughtful feedback and creative alternatives, rather than simple acceptance.
  '';

  # Prompt templates: type /review in pi to expand.
  home.file.".pi/agent/prompts/review.md".text = ''
    You are in code review mode. Focus on:

    - Code quality and best practices
    - Potential bugs and edge cases
    - Performance implications
    - Security considerations

    Provide constructive feedback without making direct changes.
  '';
}
