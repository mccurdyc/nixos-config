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
    ripgrep
    tmux
    tree
    unzip
    wdiff
  ];
}
