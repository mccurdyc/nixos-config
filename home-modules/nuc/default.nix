{ ... }:

{
  imports = [
    ../nixos
    ./claude.nix
    ./opencode.nix
    ./packages.nix
    ./pi.nix
  ];
}
