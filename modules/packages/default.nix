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
      jq
      nodePackages.bash-language-server
      nodePackages.dockerfile-language-server-nodejs
      nodePackages.jsonlint
      nodePackages.markdownlint-cli
      nodePackages.yaml-language-server
      nodePackages.fixjson
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
      lua53Packages.luacheck
      luaformatter
      statix
      vale
      yamllint
      gofumpt
      rustfmt
      shfmt
      nixpkgs-fmt
    ] ++ cfg.additional-packages;
  };
}
