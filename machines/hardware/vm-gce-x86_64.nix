{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
with lib; {
  boot.growPartition = true;
  boot.kernelParams = ["console=ttyS0" "panic=1" "boot.panic_on_fail"];
  boot.initrd.kernelModules = ["virtio_scsi"];
  boot.kernelModules = ["virtio_pci" "virtio_net"];

  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.configurationLimit = 0;

  fileSystems."/" = {
    fsType = "ext4";
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
  };

  fileSystems."/boot" = {
    fsType = "vfat";
    device = "/dev/disk/by-label/UEFI";
  };

  # enable OS Login. This also requires setting enable-oslogin=TRUE metadata on
  # instance or project level
  security.googleOsLogin.enable = true;

  # Use GCE udev rules for dynamic disk volumes
  services.udev.packages = [pkgs.google-guest-configs];
  services.udev.path = [pkgs.google-guest-configs];

  # Configure default metadata hostnames
  networking.extraHosts = ''
    169.254.169.254 metadata.google.internal metadata
  '';

  networking.timeServers = ["metadata.google.internal"];
  networking.usePredictableInterfaceNames = false;

  # GC has 1460 MTU
  networking.interfaces.eth0.mtu = 1460;

  systemd.packages = [pkgs.google-guest-agent];

  systemd.services.google-guest-agent = {
    wantedBy = ["multi-user.target"];
    restartTriggers = [config.environment.etc."default/instance_configs.cfg".source];
    path = lib.optional config.users.mutableUsers pkgs.shadow;
  };

  systemd.services.google-startup-scripts.wantedBy = ["multi-user.target"];
  systemd.services.google-shutdown-scripts.wantedBy = ["multi-user.target"];

  users.groups.google-sudoers = mkIf config.users.mutableUsers {};

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
