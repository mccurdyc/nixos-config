{ ... }:
{
  imports = [
    ../shared/pi.nix
  ];

  # https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent/docs/settings.md
  # The pi wrapper in packages.nix refreshes SSO, then exports concrete
  # AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_SESSION_TOKEN and
  # AWS_REGION=us-east-2 so that subagents (which bypass the wrapper via
  # process.execPath) inherit usable credentials from the parent env.
  home.file.".pi/agent/settings.json".text = ''
    {
      "defaultProvider": "amazon-bedrock",
      "defaultModel": "global.anthropic.claude-opus-4-6-v1",
      "theme": "mccurdyc-minimal",
      "hideThinkingBlock": true
    }
  '';
}
