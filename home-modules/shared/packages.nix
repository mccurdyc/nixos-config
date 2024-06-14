{ pkgs, ... }:

{
  home.packages = with pkgs; [
    _1password
    # arguably extras
    bat
    cloc
    dig
    fd
    fzf
    gh
    gitrs
    go
    gopls
    gron
    htop
    inferno # flamegraphs
    jq
    keychain
    lsof
    ncurses
    nodePackages_latest.bash-language-server
    ookla-speedtest
    tree
    unzip
    wdiff
  ];
}
