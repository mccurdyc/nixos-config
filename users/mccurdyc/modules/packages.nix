{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.packages;
in {
  options.modules.packages = {
    enable = mkEnableOption "packages";
    additionalPackages = mkOption {
      type = types.listOf types.package;
      default = [];
    };
    basePackages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        _1password
        bat
        cachix
        dig
        fd
        fzf
        gh
        go
        gopls
        gron
        keychain
        hadolint
        htop
        jq
        lsof
        lua53Packages.luacheck
        luaformatter
        mosh
        nix-tree
        nodePackages.bash-language-server
        nodePackages.dockerfile-language-server-nodejs
        nodePackages.fixjson
        nodePackages.jsonlint
        nodePackages.lua-fmt
        nodePackages.markdownlint-cli
        nodePackages.yaml-language-server
        nodejs
        pinentry-curses
        python310Packages.grip
        python3Full
        ripgrep
        subnetcalc
        tmux
        tree
        unzip
        watch
        wdiff
        yamllint
      ];
    };
  };
  config =
    mkIf cfg.enable
    {
      home.packages = with pkgs;
        cfg.basePackages ++ cfg.additionalPackages;
    };
}
