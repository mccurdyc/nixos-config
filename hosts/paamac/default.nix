{ ... }:

{
  imports = [
    ./networking.nix
  ];

  documentation.enable = false;
  system.tools.darwin-uninstaller.enable = false;
}
