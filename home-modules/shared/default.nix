{ ... }:

{
  imports = [
    ./nvim

    ./alacritty.nix
    ./direnv.nix
    ./git.nix
    ./gpg.nix
    ./packages.nix
    ./ripgrep.nix
    ./ssh.nix
    # ./tmux.nix
    ./zellij.nix
    ./zoxide.nix
    ./zsh.nix
  ];

  xdg.enable = true;

  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/.cargo/bin"
  ];

  # Hide "last login" message on new terminal.
  home.file.".hushlogin".text = "";

  xdg.configFile."yamllint/config".text = ''
    rules:
      document-start:
        present: true
  '';

  home.stateVersion = "22.11";
}
