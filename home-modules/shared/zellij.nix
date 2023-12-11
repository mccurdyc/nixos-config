{ pkgs, ... }:

{
  programs.zellij.enable = true;
  programs.zellij.enableZshIntegration = true;

  home.file.".config/zellij/config.kdl".source = ./zellij/config.kdl;
}
