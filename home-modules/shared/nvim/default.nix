{ pkgs, pkgs-unstable, config, ... }: {
  programs.neovim = {
    enable = true;
    # package = pkgs.neovim-unwrapped;
    package = pkgs-unstable.neovim-unwrapped; # https://github.com/nix-community/home-manager/issues/5430
    vimdiffAlias = true;
  };

  xdg.configFile.nvim = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos-config/home-modules/shared/nvim/config";
    recursive = true;
  };
}
