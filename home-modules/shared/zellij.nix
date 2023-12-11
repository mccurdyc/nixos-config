{ pkgs-unstable, ... }:

{
  programs.zellij.enable = true;
  programs.zellij.package = pkgs-unstable.zellij;
  programs.zellij.enableZshIntegration = true;

  home.file.".config/zellij/config.kdl".source = ./zellij/config.kdl;
}
