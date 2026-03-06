{ ... }:
let
  shared_prompt = builtins.readFile ../shared/claude/config/PROMPT.md;
in
{
  imports = [
    ../shared/opencode.nix
  ];

  # https://opencode.ai/docs/config
  xdg.configFile."opencode/opencode.jsonc".text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      "autoupdate": true,
      "theme": "orng",
      "default_agent": "free",
      "share": "manual",
      "provider": {
        "opencode": {
          "options": {
            "apiKey": "{file:~/.opencode-api-key}"
          }
        }
      },
      "mcp": {
        "github": {
          "type": "remote",
          "url": "https://api.githubcopilot.com/mcp",
          "headers": {
            "Authorization": "Bearer {file:~/.github-token}"
          }
        }
      },
      "agent": {
        "build": {
          "mode": "primary",
          "model": "opencode/claude-sonnet-4-6",
          "prompt": "{file:./prompts/build.txt}",
          "tools": {
            "write": true,
            "edit": true,
            "bash": true
          }
        },
        "plan": {
          "mode": "primary",
          "model": "opencode/claude-sonnet-4-6",
          "prompt": "{file:./prompts/plan.txt}",
          "temperature": 0.1,
          "tools": {
            "write": false,
            "edit": false,
            "bash": true
          }
        },
        "free": {
          "description": "Free-tier agent using Big Pickle via OpenCode Zen",
          "mode": "primary",
          "model": "opencode/big-pickle",
          "prompt": "{file:./prompts/free.txt}",
          "tools": {
            "write": true,
            "edit": true,
            "bash": true
          }
        },
        "brainstorm": {
          "mode": "primary",
          "model": "opencode/claude-opus-4-6",
          "prompt": "{file:./prompts/brainstorm.txt}",
          "temperature": 0.8,
          "tools": {
            "webfetch": true,
            "list": true,
            "grep": true,
            "glob": true,
            "read": true,
            "write": false,
            "edit": false,
            "bash": true
          }
        }
      }
    }
  '';
  xdg.configFile."opencode/prompts/free.txt".text = ''
    ${shared_prompt}
    I encourage thoughtful feedback and creative alternatives, rather than simple acceptance.
    You are running as the Big Pickle model via OpenCode Zen. Big Pickle is a free stealth
    model with unknown capability limits. Be transparent about uncertainty when you lack
    confidence, and flag tasks that may exceed your abilities rather than producing
    low-quality output silently.
  '';
}
