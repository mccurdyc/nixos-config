{ disko, ... }:

{
  imports = [
    disko.nixosModules.disko
  ];

  disko.devices = import ./disko/single-gpt-disk-fullsize-ext4.nix "/dev/sda";

  boot.loader.grub = {
    copyKernels = true;
    devices = [ "/dev/sda" ];
    efiInstallAsRemovable = true;
    efiSupport = true;
    enable = true;
    fsIdentifier = "label";
  };

  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.initrd.enable = false;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sd_mod" ];

  networking.useDHCP = true;
  networking.interfaces."eth0".useDHCP = true;
}
