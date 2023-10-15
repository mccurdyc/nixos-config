{lib, ...}: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      PermitRootLogin = "prohibit-password";
    };
  };
}
