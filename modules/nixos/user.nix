{ pkgs, user, hashedPassword, ... }:

{
  programs.zsh.enable = true;

  users = {
    mutableUsers = false;
    users."${user}" = {
      isNormalUser = true;
      home = "/home/${user}";
      hashedPassword = hashedPassword;
      extraGroups = [ "docker" "wheel" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO2cxynJf1jRyVzsOjqRYVkffIV2gQwNc4Cq4xMTcsmN"
      ];
    };
  };
}
