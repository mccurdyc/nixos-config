{ pkgs, ... }:

{
  programs.zellij = {
    enable = false;
    package = pkgs.zellij;
    enableZshIntegration = false; # disable auto startup in every zsh shell
  };

  home.file.".config/zellij/config.kdl".source = ./zellij/config.kdl;
  home.file.".config/zellij/layouts/main.kdl".source = ./zellij/layouts/main.kdl;
}
