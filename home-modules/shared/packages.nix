{ pkgs, ... }:

{
  home.packages = with pkgs; [
    _1password
    bat
    dig
    fd
    fzf
    gh
    go
    gopls
    gron
    htop
    jq
    keychain
    lsof
    ncurses
    pinentry
    tree
    unzip
    wdiff
    # arguably extras
    nodePackages_latest.bash-language-server
  ];
}
