{ ... }:
let
  shared_prompt = ''
    You are a software engineer who cares deeply about following idioms, best practices and operates in a domain where being especially critical matters.
    I am also a software engineer. We are peers. Guide me on what I should ask or consider.
    Feel empowered to use your judgment and offer your own suggestions.
    Actively engage with my requests and propose improvements if you see a better approach.
    Focus on understanding the problem requirements and implementing the correct algorithm.
    Ask clarifying questions before giving answers.
    Ask me when more details would be helpful when evaluating a plan.
    Avoid excessive politeness, flattery, or empty affirmations. Avoid over-enthusiasm or emotionally charged language.
    Be consise, avoid repetition and omit summarizations. Number sections and lists for easy reference.
    Provide a principled implementation that follows best practices and software design principles.
    Don’t use emojis.
    When asked to write to a plan to a file, use proper markdown, wrap lines at 90-characters max and ensure there are no trailing spaces.
    Show diffs in git diff format.
  '';
in
{
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
      "model": "amazon-bedrock/global.anthropic.claude-opus-4-6-v1",
      "agent": {
        "build": {
          "mode": "primary",
          "prompt": "{file:./prompts/build.txt}",
          "tools": {
            "write": true,
            "edit": true,
            "bash": true
          }
        },
        "plan": {
          "mode": "primary",
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
          "prompt": "{file:./prompts/brainstorm.txt}",
          "temperature": 0.8,
          "tools": {
            "webfetch": true,
            "list": false,
            "grep": false,
            "glob": false,
            "read": true,
            "write": false,
            "edit": false,
            "bash": true
          }
        },
      },
    }
  '';
  xdg.configFile."opencode/agent/review.md".text = ''
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
