{ zshPath, ... }:

let
  user = "cmccurdy_fastly_com";
in
{
  imports = [
    ../shared
    ./bash.nix
    ./packages.nix
    ./zsh.nix
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = "22.11";
  };

  home.sessionVariables = {
    SHELL = zshPath;
  };

  programs.home-manager.enable = true;
}
