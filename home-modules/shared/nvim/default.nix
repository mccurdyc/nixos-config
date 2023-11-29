{ nixpkgs, config, ... }: {
  programs.neovim = {
    enable = true;
    vimdiffAlias = true;
  };

  xdg.configFile.nvim = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos-config/home-modules/shared/nvim/config";
    recursive = true;
  };
}
