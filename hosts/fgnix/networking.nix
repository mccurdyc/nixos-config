{ config, ... }:

{
  networking.hostName = "fgnix";

  programs.mosh.enable = true;
  services.openssh.enable = true;
  services.tailscale.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    allowedUDPPortRanges = [{ from = 60000; to = 61000; }];
    checkReversePath = "loose";
  };
}
