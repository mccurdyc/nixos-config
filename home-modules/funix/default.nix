{ zshPath, ... }:

let
  user = "cmccurdy_fastly_com";
in
{
  imports = [
    ../shared
    ../work
    ./bash.nix
    ./packages.nix
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
  };

  home.sessionVariables = {
    SHELL = zshPath;
  };
}
