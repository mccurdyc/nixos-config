{ inputs
, pkgs
, config
, ...
}: {
  home.stateVersion = "22.11";
  imports = [
    # gui
    # ./firefox

    # cli
    ./nvim
    ./zsh
    ./git
    ./ssh
    ./tmux
    ./gpg
    # ./direnv

    # system
    ./home
    ./xdg
    ./packages
  ];
}
