{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.ssh;
in
{
  options.modules.ssh = { enable = mkEnableOption "ssh"; };
  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "30m";
      forwardAgent = true;

      matchBlocks = {
        "*" = { };

        "github.com" = {
          hostname = "ssh.github.com";
          user = "git";
          port = 443;
        };
      };
    };
  };
}
