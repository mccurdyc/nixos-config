{
  pkgs,
  lib,
  config,
  ...
}: {
  programs.ssh = {
    enable = true;
    controlMaster = "no";
    controlPath = "~/.ssh/master-%r@%n:%p";
    controlPersist = "30m";
    forwardAgent = true;

    matchBlocks = {
      "*" = {};

      # programs.ssh doesn't work well for darwin.
      # home.file.".ssh/config".text = ''
      #   Host *
      #     IdentityFile ~/.ssh/fastly_rsa
      # '';

      "github.com" = {
        hostname = "ssh.github.com";
        user = "git";
        port = 443;
      };
    };
  };
}
