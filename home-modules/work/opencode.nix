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
        "amazon-bedrock": {
          "options": {
            "region": "us-east-2",
            "profile": "bedrock"
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
        },
        "atlassian": {
          "type": "local",
          "command": [
            "uvx", "mcp-atlassian",
            "--enabled-tools",
            "jira_create_issue,jira_update_issue,jira_get_issue,jira_search,jira_get_transitions,jira_transition_issue,jira_search_fields,jira_get_field_options,confluence_search,confluence_get_page"
          ],
          "environment": {
            "JIRA_URL": "https://fastly.atlassian.net",
            "JIRA_USERNAME": "{file:~/.atlassian-email}",
            "JIRA_API_TOKEN": "{file:~/.atlassian-api-token}",
            "CONFLUENCE_URL": "https://fastly.atlassian.net/wiki",
            "CONFLUENCE_USERNAME": "{file:~/.atlassian-email}",
            "CONFLUENCE_API_TOKEN": "{file:~/.atlassian-api-token}"
          }
        }
      },
      "agent": {
        "build": {
          "mode": "primary",
          "model": "amazon-bedrock/global.anthropic.claude-sonnet-4-6",
          "prompt": "{file:./prompts/build.txt}",
          "tools": {
            "write": true,
            "edit": true,
            "bash": true
          }
        },
        "plan": {
          "mode": "primary",
          "model": "amazon-bedrock/global.anthropic.claude-sonnet-4-6",
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
          "model": "amazon-bedrock/global.anthropic.claude-opus-4-6-v1",
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
          },
          "permission": {
            "edit": "deny",
            "bash": {
              "*": "deny",
              "cat *": "allow",
              "file *": "allow",
              "git branch*": "allow",
              "git diff*": "allow",
              "git log*": "allow",
              "git rev-parse*": "allow",
              "git show*": "allow",
              "git status*": "allow",
              "head *": "allow",
              "ls *": "allow",
              "man *": "allow",
              "nix build * --dry-run*": "allow",
              "nix eval*": "allow",
              "nix develop*": "allow",
              "nix flake*": "allow",
              "rg *": "allow",
              "stat *": "allow",
              "tail *": "allow",
              "tree *": "allow",
              "wc *": "allow",
              "which *": "allow"
            }
          }
        },
      }
    }
  '';
}
