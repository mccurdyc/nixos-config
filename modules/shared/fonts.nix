{ pkgs, ... }:

{
  fonts.packages = [
    # icon fonts
    pkgs.font-awesome

    # nerdfonts
    pkgs.nerd-fonts.space-mono
  ];
}
