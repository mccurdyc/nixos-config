{ ... }:
{
  # https://docs.anthropic.com/en/docs/claude-code/amazon-bedrock
  home.file.".claude/settings.json" = {
    force = true;
    text = builtins.toJSON {
      "$schema" = "https://json.schemastore.org/claude-code-settings.json";
      env = {
        CLAUDE_CODE_USE_BEDROCK = "1";
        AWS_REGION = "us-east-2";
        AWS_PROFILE = "bedrock";
        ANTHROPIC_DEFAULT_SONNET_MODEL = "global.anthropic.claude-opus-4-6-v1";
        ANTHROPIC_DEFAULT_OPUS_MODEL = "global.anthropic.claude-opus-4-6-v1";
        ANTHROPIC_DEFAULT_HAIKU_MODEL = "us.anthropic.claude-haiku-4-5-20251001-v1:0";
      };
      mcpServers = {
        atlassian = {
          command = "bash";
          args = [
            "-c"
            ''
              export JIRA_URL="https://fastly.atlassian.net"
              export JIRA_USERNAME="$(cat ~/.atlassian-email)"
              export JIRA_API_TOKEN="$(cat ~/.atlassian-api-token)"
              export CONFLUENCE_URL="https://fastly.atlassian.net/wiki"
              export CONFLUENCE_USERNAME="$(cat ~/.atlassian-email)"
              export CONFLUENCE_API_TOKEN="$(cat ~/.atlassian-api-token)"
              exec uvx mcp-atlassian \
                --enabled-tools jira_create_issue,jira_update_issue,jira_get_issue,jira_search,jira_get_transitions,jira_transition_issue,jira_search_fields,jira_get_field_options,confluence_search,confluence_get_page
            ''
          ];
        };
      };
      permissions = {
        allow = [];
        deny = [];
      };
    };
  };
}
