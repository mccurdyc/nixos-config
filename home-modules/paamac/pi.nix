{ ... }:
{
  imports = [
    ../shared/pi.nix
  ];

  # https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent/docs/settings.md
  home.file.".pi/agent/settings.json".text = ''
    {
      "defaultProvider": "openrouter",
      "defaultModel": "moonshotai/kimi-latest",
      "theme": "mccurdyc-minimal",
      "hideThinkingBlock": true,
      "quietStartup": true,
      "followUpMode": "all"
    }
  '';
}
