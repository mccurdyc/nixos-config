{ ... }:
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
      "default_agent": "brainstorm",
      "share": "manual",
      "provider": {
        "openrouter": {
          "options": {
            "apiKey": "{file:~/.openrouter-api-key}"
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
          "model": "openrouter/anthropic/claude-sonnet-4.6",
          "prompt": "{file:./prompts/build.txt}",
          "tools": {
            "write": true,
            "edit": true,
            "bash": true
          }
        },
        "plan": {
          "mode": "primary",
          "model": "openrouter/anthropic/claude-sonnet-4.6",
          "prompt": "{file:./prompts/plan.txt}",
          "temperature": 0.1,
          "tools": {
            "write": false,
            "edit": false,
            "bash": true
          }
        },
        "brainstorm": {
          "mode": "primary",
          "model": "openrouter/anthropic/claude-opus-4.6",
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
}
