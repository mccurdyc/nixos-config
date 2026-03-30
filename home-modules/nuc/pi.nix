{ ... }:
{
  imports = [
    ../shared/pi.nix
  ];

  # https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent/docs/settings.md
  home.file.".pi/agent/settings.json".text = ''
    {
      "defaultProvider": "opencode",
      "defaultModel": "claude-opus-4-6",
      "theme": "mccurdyc-minimal"
    }
  '';
}
