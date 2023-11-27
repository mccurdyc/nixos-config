{ config, pkgs, modulesPath, ... }:

{
  # Copied - https://github.com/NixOS/nixpkgs/blob/2b6fb7ef660f0cae356322842bca5ea4e5e12efd/nixos/modules/virtualisation/google-compute-config.nix
  imports = [
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  fileSystems."/" = {
    fsType = "ext4";
    device = "/dev/disk/by-label/nixos";
  };

  fileSystems."/boot/efi" = {
    fsType = "vfat";
    device = "/dev/disk/by-label/UEFI"; # done automatically
  };

  # Trusting google-compute-config.nix
  boot.kernelParams = [ "console=ttyS0" "panic=1" "boot.panic_on_fail" ];
  boot.initrd.kernelModules = [ "virtio_scsi" ];
  boot.kernelModules = [ "virtio_pci" "virtio_net" ];

  boot.loader.grub.enable = true;
  # boot.loader.systemd-boot.enable = true;
  boot.tmp.cleanOnBoot = true;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.timeout = 0;

  boot.loader.grub.configurationLimit = 0;

  #  # enable OS Login. This also requires setting enable-oslogin=TRUE metadata on
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

  systemd.packages = [ pkgs.google-guest-agent ];

  systemd.services.google-guest-agent = {
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ config.environment.etc."default/instance_configs.cfg".source ];
    path = pkgs.lib.optional config.users.mutableUsers pkgs.shadow;
  };
  systemd.services.google-startup-scripts.wantedBy = [ "multi-user.target" ];
  systemd.services.google-shutdown-scripts.wantedBy = [ "multi-user.target" ];

  security.sudo.extraRules = pkgs.lib.mkIf config.users.mutableUsers [
    { groups = [ "google-sudoers" ]; commands = [{ command = "ALL"; options = [ "NOPASSWD" ]; }]; }
  ];

  users.groups.google-sudoers = pkgs.lib.mkIf config.users.mutableUsers { };

  boot.extraModprobeConfig = builtins.readFile "${pkgs.google-guest-configs}/etc/modprobe.d/gce-blacklist.conf";

  environment.etc."sysctl.d/60-gce-network-security.conf".source = "${pkgs.google-guest-configs}/etc/sysctl.d/60-gce-network-security.conf";

  environment.etc."default/instance_configs.cfg".text = ''
    [Accounts]
    useradd_cmd = useradd -m -s /run/current-system/sw/bin/bash -p * {user}

    [Daemons]
    accounts_daemon = ${pkgs.lib.boolToString config.users.mutableUsers}

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
