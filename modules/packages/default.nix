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
        docker
        fd
        fzf
        gcc
        gh
        git-crypt
        gitui
        go
        gofumpt
        google-cloud-sdk
        gopls
        hadolint
        htop
        jq
        lua53Packages.luacheck
        luaformatter
        nixpkgs-fmt
        nodePackages.bash-language-server
        nodePackages.dockerfile-language-server-nodejs
        nodePackages.fixjson
        nodePackages.jsonlint
        nodePackages.markdownlint-cli
        nodePackages.yaml-language-server
        nodejs
        pinentry-curses
        python39Packages.grip
        python3Full
        ripgrep
        rnix-lsp
        rustfmt
        shfmt
        starship
        statix
        subnetcalc
        sumneko-lua-language-server
        tmux
        tree
        trivy
        vale
        watch
        yamllint
      ]
      ++ cfg.additional-packages;
  };
}
