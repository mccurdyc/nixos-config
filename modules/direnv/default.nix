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
    # optional for nix flakes support in home-manager 21.11, not required in home-manager unstable or 22.05
    programs.direnv.nix-direnv.enableFlakes = true;
  };
}
