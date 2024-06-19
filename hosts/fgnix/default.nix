{ ... }:

{
  imports = [
    ../hardware/vm-gce-x86_64.nix

    ./networking.nix
    ./packages.nix
    ./zoekt.nix
  ];
}
