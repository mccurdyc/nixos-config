{pkgs, ...}: {
  # Boot settings: clean /tmp/, latest kernel and enable bootloader
  boot.tmp.cleanOnBoot = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
