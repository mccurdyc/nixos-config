{ ... }:

{
  # Why resolved?
  # It's the recommendation from Tailscale - https://tailscale.com/kb/1235/resolv-conf#how-do-i-stop-tailscaled-from-overwriting-etcresolvconf
  # Then, make sure in Tailscale DNS settings that "Override Local DNS" is true
  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
      "8.8.8.8"
      "100.100.100.100"
    ];
  };
}
