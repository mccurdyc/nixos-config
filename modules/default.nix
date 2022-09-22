{ inputs
, pkgs
, config
, ...
}: {
  home.stateVersion = "22.05";
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
    ./xdg
    ./packages
  ];
}
