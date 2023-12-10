{ ... }:

{
  imports = [
    ../hardware/x86_64.nix

    ./networking.nix
    ./packages.nix
  ];
}
