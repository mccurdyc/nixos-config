{ pkgs-unstable, ... }:

{
  services.tailscale = {
    enable = true;
    package = pkgs-unstable.tailscale;
  };

  # Protect tailscaled from the OOM killer.
  systemd.services.tailscaled.serviceConfig = {
    OOMScoreAdjust = -900;
  };
}
