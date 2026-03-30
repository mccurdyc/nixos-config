{ ... }:
{
  imports = [
    ../shared/pi.nix
  ];

  # https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent/docs/settings.md
  # AWS credentials (profile bedrock, region us-east-2) are injected at runtime
  # via the pi wrapper in packages.nix, same as the opencode wrapper.
  home.file.".pi/agent/settings.json".text = ''
    {
      "defaultProvider": "amazon-bedrock",
      "defaultModel": "global.anthropic.claude-opus-4-6",
      "theme": "dark"
    }
  '';
}
