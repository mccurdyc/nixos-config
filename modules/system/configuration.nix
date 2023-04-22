{ config
, pkgs
, inputs
, ...
}: {
  # Remove unecessary preinstalled packages
  environment.defaultPackages = [ ];

  services.xserver.desktopManager.xterm.enable = false;
  programs.zsh.enable = true;
  environment.systemPackages = with pkgs; [
    direnv
    git
    keychain
    mosh
    nix-direnv
    vim
    wget
    zsh
    unstable.tailscale
  ];

  # Nix settings, auto cleanup and enable flakes
  nix = {
    settings = {
      auto-optimise-store = true;
      allowed-users = [ "mccurdyc" ];
      trusted-users = [ "root" "mccurdyc" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
      # nix options for derivations to persist garbage collection
      keep-outputs = true
      keep-derivations = true
    '';
  };

  # Boot settings: clean /tmp/, latest kernel and enable bootloader
  boot = {
    cleanTmpDir = true;
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.consoleMode = "0";
      systemd-boot.enable = true;
      systemd-boot.editor = false;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  users.mutableUsers = false;
  users.users.mccurdyc = {
    isNormalUser = true;
    home = "/home/mccurdyc";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.zsh;
    # https://github.com/NixOS/nixpkgs/blob/8a053bc2255659c5ca52706b9e12e76a8f50dbdd/nixos/modules/config/users-groups.nix#L43
    # mkpasswd -m sha-512
    hashedPassword = "$6$d5uf.fUvF9kZ8iwH$/Bm6m3Hk82rj2V4d0pba1u6vCXIh/JLURv6Icxf1ok0heX1oK6LwSIXSeIOPriBLBnpq3amOV.pWLas0oPeCw1";
  };

  environment.variables = {
    NIXOS_CONFIG = "$HOME/.config/nixos/configuration.nix";
    NIXOS_CONFIG_DIR = "$HOME/.config/nixos/";
    EDITOR = "nvim";
    # DOCKER_DEFAULT_PLATFORM needs to be set based on system.
  };

  environment.pathsToLink = [
    "/share/nix-direnv"
  ];

  # if you also want support for flakes
  nixpkgs.overlays = [
    (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; })
  ];

  # Lots of stuff that claims doesn't work, actually works.
  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;

  # Virtualization settings
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };
  };

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      allowedUDPPortRanges = [
        {
          from = 60000;
          to = 60010;
        }
      ];
      # tailscale
      checkReversePath = "loose";
    };
    # https://man.archlinux.org/man/resolvconf.conf.5
    resolvconf.extraConfig = "name_servers=8.8.8.8";
  };

  # https://fzakaria.com/2020/09/17/tailscale-is-magic-even-more-so-with-nixos.html
  # enable the tailscale daemon; this will do a variety of tasks:
  # 1. create the TUN network device
  # 2. setup some IP routes to route through the TUN
  services.tailscale = {
    enable = true;
    package = pkgs.unstable.tailscale;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
