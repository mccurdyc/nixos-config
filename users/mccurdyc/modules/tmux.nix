{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    baseIndex = 0;
    clock24 = true;
    newSession = true;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    terminal = "screen-256color";
    shortcut = "a";
    escapeTime = 1;
    plugins = [
      pkgs.tmuxPlugins.resurrect
      pkgs.tmuxPlugins.continuum
    ];
    extraConfig = ''
      # clear scrollback buffer - https://stackoverflow.com/questions/10543684/how-can-i-clear-scrollback-buffer-in-tmux#10553992
      bind -n C-k clear-history

      # bind key for synchronizing panes
      bind-key y set-window-option synchronize-panes \; display "toggled synchronize-pages #{?pane_synchronized,on,off}"

      # Undercurl
      # https://github.com/folke/lsp-colors.nvim#making-undercurls-work-properly-in-tmux
      # https://github.com/alacritty/alacritty/issues/109#issuecomment-507026155
      # set -ag terminal-overrides ",alacritty:RGB,screen-256color:RGB"
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'  # undercurl support
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'  # underscore colours - needs tmux-3.0

      # https://unix.stackexchange.com/a/320496
      # necessary to reload shell config changes
      set -g default-shell "${pkgs.zsh}/bin/zsh"

      set -s default-terminal 'screen-256color'
      set-option -ga terminal-overrides ",alacritty:Tc,screen-256color:Tc"

      # This tmux statusbar config was created by tmuxline.vim
      # on Tue, 24 Dec 2019

      set -g status-justify "left"
      set -g status "on"

      # copy-paste Mac -> kitty -> ssh -> tmux -> vim
      # Cmd+c (copy), Cmd+v (paste)
      #
      # NOTE: if you make changes here, you should kill tmux (tmux kill-server)
      # and restart after rebuilding nixos with the new tmux config.
      #
      # NOTE: copy-paste doesn't work if you use mosh instead of ssh.
      # https://github.com/mobile-shell/mosh/pull/1054

      # https://github.com/tmux/tmux/wiki/Clipboard/
      set -g set-clipboard on
      set -g mouse on

      # https://github.com/tmux/tmux/wiki/Clipboard#terminal-support---kitty
      # https://github.com/kovidgoyal/kitty/issues/1807
      # https://gist.github.com/yudai/95b20e3da66df1b066531997f982b57b
      # This must match the value of default-termainal and TERM.
      # for tmux version (tmux -V) >3.2
      # set -ag terminal-features ',screen-256color:clipboard'
      # for tmux version (tmux -V) <3.2
      # Need this for mosh - https://github.com/mobile-shell/mosh/pull/1054#issuecomment-1303725548
      # set-option -ag terminal-overrides ",screen-256color:Ms=\\E]52;c;%p2%s\\7"

      # Base16 Eighties
      # Scheme author: Chris Kempson (http://chriskempson.com)
      # Template author: Tinted Theming: (https://github.com/tinted-theming)

      # default statusbar colors
      set-option -g status-style "fg=#a09f93,bg=#393939"

      # default window title colors
      set-window-option -g window-status-style "fg=#a09f93,bg=default"

      # active window title colors
      set-window-option -g window-status-current-style "fg=#ffcc66,bg=default"

      # pane border
      set-option -g pane-border-style "fg=#393939"
      set-option -g pane-active-border-style "fg=#515151"

      # message text
      set-option -g message-style "fg=#d3d0c8,bg=#393939"

      # pane number display
      set-option -g display-panes-active-colour "#99cc99"
      set-option -g display-panes-colour "#ffcc66"

      # clock
      set-window-option -g clock-mode-colour "#99cc99"

      # copy mode highligh
      set-window-option -g mode-style "fg=#a09f93,bg=#515151"

      # bell
      set-window-option -g window-status-bell-style "fg=#393939,bg=#f2777a"
    '';
  };
}
