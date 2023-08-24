{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.packages;
in
{
  options.modules.packages = {
    enable = mkEnableOption "packages";
    additional-packages = mkOption {
      type = types.listOf types.package;
      default = [ ];
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        _1password
        alejandra
        bat
        cachix
        crane
        dig
        docker
        docker-compose
        fastly
        fd
        fzf
        gcc
        gh
        git-crypt
        git-workspace
        gitui
        gnumake
        go
        gofumpt
        google-cloud-sdk
        gopls
        gron
        hadolint
        htop
        jq
        lsof
        lua53Packages.luacheck
        luaformatter
        nix-tree
        nixpkgs-fmt
        nodePackages.bash-language-server
        nodePackages.dockerfile-language-server-nodejs
        nodePackages.fixjson
        nodePackages.jsonlint
        nodePackages.lua-fmt
        nodePackages.markdownlint-cli
        nodePackages.yaml-language-server
        nodejs
        openssl
        pinentry-curses
        poetry
        python310Packages.grip
        # python310Packages.pip - use "python -m ensurepip --default-pip"
        python3Full
        qrencode
        ripgrep
        rnix-lsp
        rustup
        shfmt
        starship
        statix
        stern
        subnetcalc
        terraform
        tfswitch
        tmux
        tree
        trivy
        unzip
        vale
        watch
        wdiff
        yamllint
      ]
      ++ cfg.additional-packages;
  };
}
