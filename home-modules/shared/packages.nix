{ pkgs, ... }:

{
  home.packages = with pkgs; [
    _1password
    bat
    cloc
    dig
    fd
    fzf
    gh
    go
    gopls
    gron
    gitrs
    htop
    jq
    keychain
    lsof
    ncurses
    ookla-speedtest
    pinentry
    tree
    unzip
    wdiff
    # arguably extras
    nodePackages_latest.bash-language-server
  ];
}
