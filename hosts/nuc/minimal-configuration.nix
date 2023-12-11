{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nuc";

  time.timeZone = "America/New_York";

  users.mutableUsers = false;

  users.users.mccurdyc = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$5CjBgjlXBsYF3FYnTP9wQ.$hl8uCypIgOcrh3OrhcJA600Fgv5T9l0U85InRwmRdy5";
    extraGroups = [ "wheel" ];
    home = "/home/mccurdyc";
    packages = with pkgs; [
      _1password
    ];
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "1password-cli"
  ];

  environment.systemPackages = with pkgs; [
    tailscale
    neovim
    git
    curl
    wget
    mosh
    zsh
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;
  services.tailscale.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    allowedUDPPortRanges = [{ from = 60000; to = 60010; }];
    checkReversePath = "loose";
  };

  system.stateVersion = "23.11";
}
