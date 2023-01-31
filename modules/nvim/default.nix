{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.nvim;
in
{
  options.modules.nvim = { enable = mkEnableOption "nvim"; };
  config = mkIf cfg.enable {
    home.file."lazy-lock.json".source = ./lazy-lock.json;
    programs.neovim = {
      enable = true;
      # https://github.com/nix-community/home-manager/issues/1907#issuecomment-934316296
      extraConfig = ''
        luafile ${config.xdg.configHome}/nvim/main.lua
      '';
      vimdiffAlias = true;
    };
  };
}
