{ config, ... }:
{
  # https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent
  # pi is installed via Nix (see pkgs/pi-coding-agent/)
  # Config dir: ~/.pi/agent/

  # Global agents file for opencode (~/.config/opencode/AGENTS.md).
  # Also symlinked for pi (~/.pi/agent/AGENTS.md).
  home.file."${config.xdg.configHome}/opencode/AGENTS.md".source = ./AGENTS.md;
  home.file.".pi/agent/AGENTS.md".source = ./AGENTS.md;

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
