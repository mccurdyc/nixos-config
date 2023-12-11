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
    ripgrep
    tree
    unzip
    wdiff
    zoxide
    zellij
    # arguably extras
    nodePackages_latest.bash-language-server
  ];
}
