{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.xdg;
in
{
  options.modules.xdg = { enable = mkEnableOption "xdg"; };
  config = mkIf cfg.enable {
    xdg.configFile = {
      nvim = {
        source = ../nvim/lua;
        recursive = true;
      };
    };
  };
}
