{
  config,
  pkgs,
  inputs,
  ...
}: {
  # Remove unecessary preinstalled packages
  environment.defaultPackages = [];

  services.xserver.desktopManager.xterm.enable = false;
  programs.zsh.enable = true;
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  environment.systemPackages = with pkgs; [
    git
    mosh
    vim
    wget
    zsh
    unstable.tailscale
  ];

  # Nix settings, auto cleanup and enable flakes
  nix = {
    settings.auto-optimise-store = true;
    settings.allowed-users = ["mccurdyc"];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
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
    extraGroups = ["docker" "wheel"];
    shell = pkgs.zsh;
    # https://github.com/NixOS/nixpkgs/blob/8a053bc2255659c5ca52706b9e12e76a8f50dbdd/nixos/modules/config/users-groups.nix#L43
    # mkpasswd -m sha-512
    hashedPassword = "$6$IaUNMyUlY0sYKtbB$IuFPlLujAES4jpt1MmoTzcZa8QSDBTu1uRLFGk//CVXlMy6053Hsq/8hpORwtSxz.v3kDqUdIwrKPIqoydcfy.";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHsulhlLwS9YrVaO1DF3IJVB4vVMC4hZDmZ+0QZQFjfR mccurdyc@ipad"
    ];
  };

  environment.variables = {
    NIXOS_CONFIG = "$HOME/.config/nixos/configuration.nix";
    NIXOS_CONFIG_DIR = "$HOME/.config/nixos/";
    EDITOR = "nvim";
  };

  # Lots of stuff that claims doesn't work, actually works.
  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
  };

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;

  # Virtualization settings
  virtualisation.docker.enable = true;

  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [22];
      trustedInterfaces = ["tailscale0"];
      allowedUDPPorts = [config.services.tailscale.port];
      allowedUDPPortRanges = [
        {
          from = 60000;
          to = 60010;
        }
      ];
      # tailscale
      checkReversePath = "loose";
    };
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
  system.stateVersion = "22.05"; # Did you read the comment?
}
