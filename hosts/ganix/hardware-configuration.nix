# Copied from my GCE, packer-built nixos image.
# Which mostly just takes from here - https://github.com/NixOS/nixpkgs/blob/nixos-22.11/nixos/modules/virtualisation/google-compute-config.nix

{ config, lib, pkgs, modulesPath, ... }:
with lib;
{
  imports = [
    # https://github.com/NixOS/nixpkgs/blob/bebe0f71df8ce8b7912db1853a3fd1d866b38d39/lib/modules.nix#L192
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  fileSystems."/" = {
    fsType = "ext4";
    device = "/dev/disk/by-label/nixos"; # done above
    autoResize = true;
  };

  fileSystems."/boot" = {
    fsType = "vfat";
    device = "/dev/disk/by-label/UEFI"; # done automatically
  };

  # This allows an instance to be created with a bigger root filesystem
  # than provided by the machine image.
  boot.growPartition = true;

  # Trusting google-compute-config.nix
  boot.initrd.availableKernelModules = [ "nvme" ];
  boot.initrd.kernelModules = [ "virtio_scsi" ];
  boot.kernelParams = [ "console=ttyS0" "panic=1" "boot.panic_on_fail" ];
  boot.kernelModules = [ "virtio_pci" "virtio_net" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 1;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  # enable OS Login. This also requires setting enable-oslogin=TRUE metadata on
  # instance or project level
  security.googleOsLogin.enable = true;
  # Use GCE udev rules for dynamic disk volumes
  services.udev.packages = [ pkgs.google-guest-configs ];
  services.udev.path = [ pkgs.google-guest-configs ];

  environment.systemPackages = [
    pkgs.git
    pkgs.mosh
    pkgs.neovim
    pkgs.tailscale
    pkgs.wget
    pkgs.zsh
  ];

  # At this point, we are past packer, so we can just rely on tailscale.
  services.openssh.enable = false;
  services.openssh.permitRootLogin = "prohibit-password";
  services.openssh.passwordAuthentication = mkDefault false;

  services.tailscale.enable = true;

  # Configure default metadata hostnames
  networking.extraHosts = ''
    169.254.169.254 metadata.google.internal metadata
  '';

  networking.timeServers = [ "metadata.google.internal" ];
  networking.usePredictableInterfaceNames = false;

  # GC has 1460 MTU
  networking.interfaces.eth0.mtu = 1460;

  systemd.packages = [ pkgs.google-guest-agent ];

  systemd.services.google-guest-agent = {
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ config.environment.etc."default/instance_configs.cfg".source ];
    path = lib.optional config.users.mutableUsers pkgs.shadow;
  };

  systemd.services.google-startup-scripts.wantedBy = [ "multi-user.target" ];
  systemd.services.google-shutdown-scripts.wantedBy = [ "multi-user.target" ];

  security.sudo.extraRules = mkIf config.users.mutableUsers [
    { groups = [ "google-sudoers" ]; commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }]; }
  ];

  users.groups.google-sudoers = mkIf config.users.mutableUsers { };

  boot.extraModprobeConfig = lib.readFile "${pkgs.google-guest-configs}/etc/modprobe.d/gce-blacklist.conf";

  environment.etc."sysctl.d/60-gce-network-security.conf".source = "${pkgs.google-guest-configs}/etc/sysctl.d/60-gce-network-security.conf";
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
}
