{
  pkgs,
  pkgs-unstable,
  config,
  currentSystemName,
  ...
}: {
  networking = {
    hostName = currentSystemName;
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
    # https://man.archlinux.org/man/resolvconf.conf.5
    resolvconf.extraConfig = "name_servers=8.8.8.8";
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
