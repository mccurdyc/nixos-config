{ ... }:

{
  imports = [
    ../hardware/vm-gce-x86_64.nix

    ./docker.nix
    ./networking.nix
    ./packages.nix
    ./zoekt.nix
    ./zsh.nix
  ];

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 4096; # MiB
  }];

  # Prefer reclaiming page cache over swapping. Swap is a last resort.
  boot.kernel.sysctl."vm.swappiness" = 10;
}
