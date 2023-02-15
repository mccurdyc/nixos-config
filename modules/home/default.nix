{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.home;
in
{
  options.modules.home = { enable = mkEnableOption "home"; };
  config = mkIf cfg.enable {
    # force it to create the directory
    home.file."src/github.com/mccurdyc".text = "";
    home.sessionPath = [
      "$HOME/go/bin"
    ];
  };
}
