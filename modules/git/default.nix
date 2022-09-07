{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.git;
in {
  options.modules.git = {enable = mkEnableOption "git";};
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = "Colton J. McCurdy";
      userEmail = "mccurdyc22@gmail.com";
      signing = {
        key = "9CD9D30EBB7B1EEC";
        signByDefault = true;
      };
      extraConfig = {
        init = {defaultBranch = "main";};
        core = {
          excludesfile = "$NIXOS_CONFIG_DIR/scripts/gitignore";
        };
      };
    };

    programs.gitui = {
      enable = true;
    };
  };
}
