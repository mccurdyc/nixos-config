{ ... }:
{
  # Today, I just manage these ssh configs outside of Nix because I don't currently
  # have a way to "inject" or "consume" secret Nix modules.
  # https://man7.org/linux/man-pages/man5/ssh_config.5.html
  #
  # eval $(op signin) && op document get <name> --output $HOME/.ssh/main
  programs.ssh.includes = [
    "~/.ssh/config.d/work/main.conf"
    "~/.ssh/config.d/work/jetpac.conf"
  ];

  # Only expose the fastly_ssh key via the 1Password SSH agent.
  # https://developer.1password.com/docs/ssh/agent/config/
  home.file.".config/1Password/ssh/agent.toml".text = ''
    [[ssh-keys]]
    item = "fastly_ssh"
  '';
}
