{ pkgs, user, ... }:

{
  imports = [
    ../shared
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "22.11";
  };

  programs.home-manager.enable = true;
}
