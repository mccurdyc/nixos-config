{ pkgs, ... }:

{
  home.packages = with pkgs; [
    _1password
    # arguably extras
    bat
    cloc
    universal-ctags # for zoekt-indexserver (running zoekt-git-index) - https://github.com/sourcegraph/zoekt/blob/5ac92b1a7d4ab7b0dbeeaa9df77abb13d555e16b/doc/ctags.md?plain=1#L18-L21
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
    zoekt
  ];
}
