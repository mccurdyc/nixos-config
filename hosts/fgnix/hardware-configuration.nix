{ config, lib, pkgs, modulesPath, ... }:
with lib;
{
  # https://nixos.wiki/wiki/Flakes#NixOS
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # https://floxdev.com/docs/install-flox/
  nix.settings.extra-trusted-substituters = [ "https://cache.floxdev.com" ];
  nix.settings.extra-trusted-public-keys = [ "_FLOX_PUBLIC_KEYS()" ];

  # https://nixos.org/manual/nixos/stable/options.html

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
  boot.kernelParams = [ "console=ttyS0" "panic=1" "boot.panic_on_fail" ];
  boot.initrd.kernelModules = [ "virtio_scsi" ];
  boot.kernelModules = [ "virtio_pci" "virtio_net" ];

  # Generate a GRUB menu.
  boot.loader.grub.device = "/dev/sda";
  boot.loader.timeout = 0;

  # Don't put old configurations in the GRUB menu.  The user has no
  # way to select them anyway.
  boot.loader.grub.configurationLimit = 0;

  # enable OS Login. This also requires setting enable-oslogin=TRUE metadata on
  # instance or project level
  security.googleOsLogin.enable = true;

  # Use GCE udev rules for dynamic disk volumes
  services.udev.packages = [ pkgs.google-guest-configs ];
  services.udev.path = [ pkgs.google-guest-configs ];

  # Force getting the hostname from Google Compute.
  networking.hostName = "fgnix";

  environment.systemPackages = [
    pkgs.git
    pkgs.mosh
    pkgs.neovim
    pkgs.tailscale
    pkgs.wget
    pkgs.zsh
  ];

  # TODO: Packer doesn't use tailscale ssh, so leaving this.
  # I think it could work using tailscale ssh, just haven't spent the time yet to figure it out.
  # Allow root logins only using SSH keys
  # and disable password authentication in general
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "prohibit-password";
    PasswordAuthentication = mkDefault false;
  };

  services.tailscale.enable = true;

  # Configure default metadata hostnames
  networking.extraHosts = ''
    169.254.169.254 metadata.google.internal metadata
  '';

  networking.timeServers = [ "metadata.google.internal" ];
  networking.usePredictableInterfaceNames = false;

  # GC has 1460 MTU
  networking.interfaces.eth0.mtu = 1460;

  # Custom systemd services
  # https://nixos.org/manual/nixos/stable/options.html#opt-systemd.services._name_.enable
  # systemd.services.tailscale-up = {
  #   enable = true;
  #   # enable=true does not make a unit start by default at boot; if you want that, see wantedBy.
  #   wantedBy = [ "multi-user.target" ];
  #   script = "tailscale up --ssh=true --auth-key $TAILSCALE_AUTH_KEY";
  #   # If auth-key doesnt work this way, we could use <(cat /some/file) instead.
  # };
  #
  # systemd.services.mosh-up = {
  #   enable = true;
  #   wantedBy = [ "multi-user.target" ];
  #   script = "mosh"; # might need to be mosh-server
  # };

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
