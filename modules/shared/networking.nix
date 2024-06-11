{ pkgs-unstable, ... }:

{
  services.tailscale = {
    enable = true;
    package = pkgs-unstable.tailscale;
  };

  # Why resolved?
  # It's the recommendation from Tailscale - https://tailscale.com/kb/1235/resolv-conf#how-do-i-stop-tailscaled-from-overwriting-etcresolvconf
  services.resolved = {
    enable = true;
    fallbackDns = [
      "100.100.100.100"
    ];
  };
}
