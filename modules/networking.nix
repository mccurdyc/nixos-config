{ pkgs-unstable, config, currentSystemName, ... }: {
  networking = {
    hostName = currentSystemName;
    firewall.enable = false; # Use cloud firewall rules
  };

  # https://fzakaria.com/2020/09/17/tailscale-is-magic-even-more-so-with-nixos.html
  # enable the tailscale daemon; this will do a variety of tasks:
  # 1. create the TUN network device
  # 2. setup some IP routes to route through the TUN
  services.tailscale = {
    enable = true;
    package = pkgs-unstable.tailscale;
  };
}
