_: {
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.ssh.matchBlocks
  programs.ssh = {
    enable = true;
    controlMaster = "no";
    controlPath = "~/.ssh/master-%r@%n:%p";
    controlPersist = "30m";
    forwardAgent = true;
    serverAliveInterval = 30;
    serverAliveCountMax = 120;

    # Today, I just manage these ssh configs outside of Nix because I don't currently
    # have a way to "inject" or "consume" secret Nix modules.
    # https://man7.org/linux/man-pages/man5/ssh_config.5.html
    #
    # eval $(op signin) && op document get <name> --output $HOME/.ssh/main
    includes = [
      "~/.ssh/config.d/work/main.conf"
      "~/.ssh/config.d/work/jetpac.conf"
    ];

    matchBlocks = {
      "*" = { };

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
