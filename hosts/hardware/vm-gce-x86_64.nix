{ disko, ... }:

{
  imports = [
    disko.nixosModules.disko
  ];

  disko.devices = import ./disko/single-gpt-disk-fullsize-ext4.nix "/dev/sda";

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sd_mod" ];

  networking.useDHCP = true;
  networking.interfaces."eth0".useDHCP = true;
}
