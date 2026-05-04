{ pkgs, config, ... }: {
  home.packages = [ pkgs.neovim-unwrapped ];

  home.shellAliases = {
    vimdiff = "nvim -d";
  };

  xdg.configFile.nvim = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos-config/home-modules/shared/nvim/config";
    recursive = true;
  };
}
