{ pkgs, user, ... }:

{
  programs.zsh.enable = true;

  users = {
    mutableUsers = false;
    users."${user}" = {
      group = user; # required; TODO - startup log warning in VM about 'unknown group';
      isNormalUser = true;
      home = "/home/${user}";
      extraGroups = [ "docker" "wheel" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO2cxynJf1jRyVzsOjqRYVkffIV2gQwNc4Cq4xMTcsmN"
      ];
    };
  };
}
