{ pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = pkgs.lib.mkDefault false;
      PermitRootLogin = "prohibit-password";
      X11Forwarding = true;
    };
  };

  # Make sshd one of the last processes the OOM killer targets.
  # Range is -1000 (never kill) to 1000 (kill first).
  systemd.services.sshd.serviceConfig = {
    OOMScoreAdjust = -900;
  };
}
