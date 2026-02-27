{ ... }:

{
  imports = [
    ./nvim

    ./alacritty.nix
    ./direnv.nix
    ./environment.nix
    ./ghostty.nix
    ./git.nix
    ./gpg.nix
    ./opencode.nix
    ./packages.nix
    ./ripgrep.nix
    ./ssh.nix
    ./tmux.nix
    ./zellij.nix
    ./zoekt.nix
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
