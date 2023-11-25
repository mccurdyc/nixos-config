{ pkgs-unstable, currentSystemName, ... }:

{
  networking = {
    hostName = currentSystemName;
    firewall.enable = false;
  };

  services.tailscale = {
    enable = true;
    package = pkgs-unstable.tailscale;
  };
}
