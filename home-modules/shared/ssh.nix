{ ... }:
{
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.ssh.settings
  programs.ssh = {
    enableDefaultConfig = false;
    enable = true;

    # Today, I just manage these ssh configs outside of Nix because I don't currently
    # have a way to "inject" or "consume" secret Nix modules.
    # https://man7.org/linux/man-pages/man5/ssh_config.5.html
    #
    # eval $(op signin) && op document get <name> --output $HOME/.ssh/main
    includes = [
      "~/.ssh/config.d/work/main.conf"
      "~/.ssh/config.d/work/jetpac.conf"
    ];

    settings = {
      "*" = {
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "30m";
        ForwardAgent = true;
        ServerAliveInterval = 30;
        ServerAliveCountMax = 120;
      };

      "github.com" = {
        HostName = "ssh.github.com";
        User = "git";
        Port = 443;
      };
    };
  };
}
