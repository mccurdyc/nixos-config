{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    _1password-cli
    # arguably extras
    awscli2
    ssm-session-manager-plugin
    google-cloud-sdk
    bat
    bc
    cloc
    universal-ctags # for zoekt-indexserver (running zoekt-git-index) - https://github.com/sourcegraph/zoekt/blob/5ac92b1a7d4ab7b0dbeeaa9df77abb13d555e16b/doc/ctags.md?plain=1#L18-L21
    dig
    fd
    fzf
    zsh-fzf-tab
    zsh-fzf-history-search
    gh
    gitrs
    go
    gopls
    python312Packages.grip
    gron
    htop
    inferno # flamegraphs
    jq
    just
    keychain
    k3d
    k9s
    lsof
    ncurses
    nodePackages_latest.bash-language-server
    ookla-speedtest
    qmk
    subnetcalc
    tree
    unzip
    wdiff
    wireguard-tools
    yamlfmt
    yamllint
    zoekt
    vscode-extensions.vadimcn.vscode-lldb # codelldb
  ] ++ (with pkgs-unstable;
    [
      aider-chat-full
    ]);
}
