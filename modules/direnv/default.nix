{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.direnv;
in
{
  options.modules.direnv = { enable = mkEnableOption "direnv"; };
  config = mkIf cfg.enable {
    # https://github.com/nix-community/nix-direnv#via-home-manager
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
  };
}
