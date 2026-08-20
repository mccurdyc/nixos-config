{ pkgs, config, ... }:

{
  home.packages = [
    pkgs.neovim-unwrapped
    pkgs.gnumake
    pkgs.imagemagick
    pkgs.luajitPackages.magick
  ];

  home.shellAliases = {
    gd = "(){ nvim +\"DiffviewOpen $*\"; }";
    vimdiff = "nvim -d";
  };

  xdg.configFile.nvim = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos-config/home-modules/shared/nvim/config";
    recursive = true;
  };
}
