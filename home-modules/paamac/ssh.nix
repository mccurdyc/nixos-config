{ ... }:
{
  # Use 1Password as the SSH agent.
  programs.ssh.settings."*" = {
    IdentityAgent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
  };

  # Only expose the personal_ssh key via the 1Password SSH agent.
  # https://developer.1password.com/docs/ssh/agent/config/
  home.file.".config/1Password/ssh/agent.toml".text = ''
    [[ssh-keys]]
    item = "personal_ssh"
  '';
}
