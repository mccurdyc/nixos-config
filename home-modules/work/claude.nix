{ ... }:
{
  # https://docs.anthropic.com/en/docs/claude-code/amazon-bedrock
  home.file.".claude/settings.json".text = builtins.toJSON {
    "$schema" = "https://json.schemastore.org/claude-code-settings.json";
    env = {
      CLAUDE_CODE_USE_BEDROCK = "1";
      AWS_REGION = "us-east-2";
      AWS_PROFILE = "bedrock";
      ANTHROPIC_DEFAULT_SONNET_MODEL = "global.anthropic.claude-opus-4-6-v1";
      ANTHROPIC_DEFAULT_OPUS_MODEL = "global.anthropic.claude-opus-4-6-v1";
      ANTHROPIC_DEFAULT_HAIKU_MODEL = "us.anthropic.claude-haiku-4-5-20251001-v1:0";
    };
    permissions = {
      allow = [];
      deny = [];
    };
  };
}
