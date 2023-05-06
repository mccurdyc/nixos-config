{ inputs
, pkgs
, config
, ...
}: {
  home.stateVersion = "22.11";
  imports = [
    ./direnv
    ./git
    ./gpg
    ./home
    ./nvim
    ./packages
    ./ssh
    ./tmux
    ./zsh
  ];
}
