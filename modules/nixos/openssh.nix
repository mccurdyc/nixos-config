{ pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = pkgs.lib.mkDefault false;
      PermitRootLogin = "prohibit-password";
    };
  };
}
