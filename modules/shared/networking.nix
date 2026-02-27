{ pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    package = pkgs.tailscale;
  };

  # Protect tailscaled from the OOM killer.
  systemd.services.tailscaled.serviceConfig = {
    OOMScoreAdjust = -900;
  };
}
