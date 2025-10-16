{ pkgs, ... }: {

  programs.tmux = {
    enable = true;
    baseIndex = 0;
    clock24 = true;
    newSession = false;
    keyMode = "vi";
    terminal = "xterm-256color";
    shortcut = "a";
    escapeTime = 1;
    extraConfig = ''
      # Reload tmux config
      bind-key R source-file ~/.config/tmux/tmux.conf \; display "Reloaded"

      # Pane navigation (vim-style)
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      # Pane resizing (vertical only)
      bind-key J resize-pane -D 5
      bind-key K resize-pane -U 5

      # clear scrollback buffer - https://stackoverflow.com/questions/10543684/how-can-i-clear-scrollback-buffer-in-tmux#10553992
      bind -n C-k clear-history

      # bind key for synchronizing panes
      bind-key y set-window-option synchronize-panes \; display "toggled synchronize-pages #{?pane_synchronized,on,off}"

      # Undercurl
      # https://github.com/folke/lsp-colors.nvim#making-undercurls-work-properly-in-tmux
      # https://github.com/alacritty/alacritty/issues/109#issuecomment-507026155
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'  # undercurl support
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'  # underscore colours - needs tmux-3.0

      # https://unix.stackexchange.com/a/320496
      # necessary to reload shell config changes
      set -g default-shell "/etc/profiles/per-user/$USER/bin/zsh"
      set -g default-command "/etc/profiles/per-user/$USER/bin/zsh"

      set -g status-justify "left"
      set -g status "on"

      set-option -g status-left-length 8
      set-option -g status-right-length 20

      set -g window-status-format " • #[fg=#ffa500,bg=#040405]#W"
      set -g window-status-current-format " • #[fg=#ffa500,bg=#040405]#W"

      set-option -g status-left "#[fg=#040405,bg=#ffa500,bold]#S"
      set-option -g status-right "#[fg=#040405,bg=#ffa500,bold]#(date -u "+%%H:%%M") • #[fg=#040405,bg=#ffa500,bold]#(uptime | cut -d ' ' -f 2)"

      # copy-paste Mac -> Terminal Emulator -> ssh -> tmux -> neovim
      # Cmd+c (copy), Cmd+v (paste)
      #
      # NOTE: if you make changes here, you should kill tmux (tmux kill-server)
      # and restart after rebuilding nixos with the new tmux config.
      #
      # NOTE: copy-paste doesn't work if you use mosh instead of ssh.
      # https://github.com/mobile-shell/mosh/pull/1054

      # Copy & keep copy mode active with selection highlight
      # Ideally, I wanted it to clear the selection, but hold its place in copy mode.
      bind-key -T copy-mode-vi Enter send-keys -X copy-selection

      # https://github.com/tmux/tmux/wiki/Clipboard/
      set -g set-clipboard external
      set -g allow-passthrough on
      set -g mouse on

      # https://github.com/tmux/tmux/wiki/Clipboard#terminal-support---kitty
      # https://github.com/kovidgoyal/kitty/issues/1807
      # https://gist.github.com/yudai/95b20e3da66df1b066531997f982b57b
      # This must match the value of default-termainal and TERM.
      # for tmux version (tmux -V) >3.2
      set -ag terminal-features ',xterm-256color:clipboard'
      # for tmux version (tmux -V) <3.2
      # Need this for mosh - https://github.com/mobile-shell/mosh/pull/1054#issuecomment-1303725548
      set -as terminal-features ',xterm-256color:clipboard'

      # Don't exit copy-mode after hitting enter, but still clear selection
      bind-key -T copy-mode-vi Enter send-keys -X copy-selection-no-clear

      # default statusbar colors
      set-option -g status-interval 1
      set-option -g status-style "fg=#ffa500,bg=#040405"

      # default window title colors
      set-window-option -g window-status-style "fg=#ffa500,bg=#040405"
      set-window-option -g window-style "fg=#ffa500,bg=#040405"

      # active window title colors
      set-window-option -g window-status-current-style "fg=#ffa500,bg=#040405"

      # pane border
      set-option -g pane-border-style "fg=#040405"
      set-option -g pane-active-border-style "fg=#ffa500"

      # message text
      set-option -g message-style "fg=#ffa500,bg=#040405"

      # pane number display
      set-option -g display-panes-active-colour "#ffa500"
      set-option -g display-panes-colour "#ffa500"

      # clock
      set-window-option -g clock-mode-colour "#ffa500"

      # copy mode highlight
      set-window-option -g mode-style "bg=#2d2d2d"

      # bell
      set-window-option -g window-status-bell-style "fg=#040405,bg=#ffa500"

      # Auto-install tpm if not present
      if "test ! -d ~/.tmux/plugins/tpm" \
         "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"

      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'tmux-plugins/tmux-yank'

      run '~/.tmux/plugins/tpm/tpm'
    '';
  };
}
