{ config, lib, pkgs, modulesPath, ... }:

with lib;
{
  imports = [
    <nixpkgs/nixos/modules/profiles/headless.nix>
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
  ];

  fileSystems."/" = {
    fsType = "ext4";

    # mccurdyc@cmccurdy-packer-build:~$ sudo lsblk -f
    # NAME    FSTYPE FSVER LABEL           UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
    # ├─sda1  ext4   1.0   cloudimg-rootfs f03b8bd5-16d1-49c5-9cef-adb5020ff900   43.5G     8% /snap
    device = "/dev/disk/by-label/cloudimg-rootfs"; # done above
  };

  fileSystems."/boot/efi" = {
    fsType = "vfat";
    device = "/dev/disk/by-label/UEFI"; # done automatically
  };

  # Trusting google-compute-config.nix
  boot.kernelParams = [ "console=ttyS0" "panic=1" "boot.panic_on_fail" ];
  boot.initrd.kernelModules = [ "virtio_scsi" ];
  boot.kernelModules = [ "virtio_pci" "virtio_net" "kvm" ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.timeout = 0;

  # enable OS Login. This also requires setting enable-oslogin=TRUE metadata on
  # instance or project level
  security.googleOsLogin.enable = true;

  # Use GCE udev rules for dynamic disk volumes
  services.udev.packages = [ pkgs.google-guest-configs ];
  services.udev.path = [ pkgs.google-guest-configs ];

  # Configure default metadata hostnames
  networking.extraHosts = ''
    169.254.169.254 metadata.google.internal metadata
  '';

  networking.timeServers = [ "metadata.google.internal" ];
  networking.usePredictableInterfaceNames = false;

  # GC has 1460 MTU
  networking.interfaces.eth0.mtu = 1460;

  systemd.services.google-startup-scripts.wantedBy = [ "multi-user.target" ];

  users.groups.google-sudoers = mkIf config.users.mutableUsers { };

  environment.etc."default/instance_configs.cfg".text = ''
    [Accounts]
    useradd_cmd = useradd -m -s /run/current-system/sw/bin/bash -p * {user}
    [Daemons]
    accounts_daemon = ${boolToString config.users.mutableUsers}
    [InstanceSetup]
    # Make sure GCE image does not replace host key that NixOps sets.
    set_host_keys = false
    [MetadataScripts]
    default_shell = ${pkgs.stdenv.shell}
    [NetworkInterfaces]
    dhclient_script = ${pkgs.google-guest-configs}/bin/google-dhclient-script
    # We set up network interfaces declaratively.
    setup = false
  '';

  system.stateVersion = "23.11";
}
