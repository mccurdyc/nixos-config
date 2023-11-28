{ config, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  fileSystems."/" = {
    fsType = "ext4";
    device = "/dev/disk/by-label/cloudimg-rootfs"; # done automatically
  };

  fileSystems."/boot" = {
    fsType = "ext4";
    device = "/dev/disk/by-label/BOOT"; # done automatically
  };

  fileSystems."/boot/efi" = {
    fsType = "vfat";
    device = "/dev/disk/by-label/UEFI"; # done automatically
  };

  boot.initrd.availableKernelModules = [ "virtio_scsi" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.loader.timeout = 0;

  # enable OS Login. This also requires setting enable-oslogin=TRUE metadata on
  # instance or project level
  security.googleOsLogin.enable = true;

  # Configure default metadata hostnames
  networking.extraHosts = ''
    169.254.169.254 metadata.google.internal metadata
  '';

  networking.usePredictableInterfaceNames = false;

  # GC has 1460 MTU
  networking.interfaces.eth0.mtu = 1460;

  systemd.services.google-startup-scripts.wantedBy = [ "multi-user.target" ];

  users.groups.google-sudoers = pkgs.lib.mkIf config.users.mutableUsers { };

  system.stateVersion = "22.11";
}
