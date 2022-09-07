{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.packages;
in {
  options.modules.packages = {enable = mkEnableOption "packages";};
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      _1password
      alejandra
      bat
      docker
      fd
      fzf
      gcc
      git-crypt
      gitui
      go
      google-cloud-sdk
      gopls
      hadolint
      htop
      hugo
      jq
      ngrok
      niv
      nodePackages.bash-language-server
      nodePackages.dockerfile-language-server-nodejs
      nodePackages.lua-fmt
      nodePackages.webpack
      nodePackages.webpack-cli
      nodePackages.yaml-language-server
      nodejs
      pinentry-curses
      python39Packages.grip
      python3Full
      ripgrep
      rnix-lsp
      starship
      subnetcalc
      sumneko-lua-language-server
      tmux
      tree
      trivy
      watch
    ];
  };
}
