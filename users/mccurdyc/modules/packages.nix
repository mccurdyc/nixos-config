{ config, pkgs, lib, options, ... }:
let
  cfg = config.modules.packages;
in
{
  options.modules.packages = {
    enable = lib.mkEnableOption "packages";

    additionalPackages = lib.mkOption {
      default = [ ];
    };

    basePackages = lib.mkOption {
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
        keychain
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

  config = lib.mkIf cfg.enable {
    # options.modules.packages.basePackages = options.modules.packages.basePackages ++ cfg.additionalPackages;
  };
}
