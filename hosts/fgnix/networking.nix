{ config, ... }:

{
  networking.hostName = "fgnix";

  programs.mosh.enable = true;
  services.sshd.enable = true;
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings.PermitRootLogin = "prohibit-password";
  };

  services.tailscale.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    allowedUDPPortRanges = [{ from = 60000; to = 61000; }];
    checkReversePath = "loose";
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
