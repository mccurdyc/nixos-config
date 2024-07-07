{ pkgs, ... }: {

  # 00 - #ff5f5f red (IndianRed1) (error) ctermfg=203
  # 01 - #ffa500 orange (Orange1) (warning) ctermfg=214
  # 02 - #5fd787 green (SeaGreen3) (good) ctermfg=78
  # 03 - #2950c5 blue (alt) no direct ctermfg, use ctermfg=33
  # 04 - empty (alt) ->
  # 05 - empty (alt) ->
  # 06 - empty (alt) ->
  # --- Black and White
  # 07 - #000000 pure black (Black) ctermfg=00
  # 08 - #1c1c1c "black" (Grey11) (background) ctermfg=234
  # 09 - #262626 really dark gray (Grey15) (comment) ctermfg=235
  # 0A - #4e4e4e dark grey (Grey30) (more important than comment) ctermfg=29
  # 0B - #9e9e9e (247_Grey62) ctermfg=247
  # 0C - #d3d0c8 (252_Grey82) ctermfg=252
  # 0D - #e4e4e4 light grey (Grey89) (foreground) ctermfg=254
  # 0E - #eeeeee "white" (Grey93) (foreground) ctermfg=255
  # 0F - #ffffff pure white (White) ctermfg=16

  programs.tmux = {
    enable = true;
    baseIndex = 0;
    clock24 = true;
    newSession = false;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    terminal = "screen-256color";
    shortcut = "a";
    escapeTime = 1;
    extraConfig = ''
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
      set -g default-shell "${pkgs.zsh}/bin/zsh"

      set -g status-justify "left"
      set -g status "on"

      set-option -g status-left-length 8
      set-option -g status-right-length 20

      set -g window-status-format " • #[fg=#ffa500,bg=#1c1c1c]#W"
      set -g window-status-current-format " • #[fg=#ffa500,bg=#1c1c1c]#W"

      set-option -g status-left "#[fg=#1c1c1c,bg=#ffa500,bold]#S"
      set-option -g status-right "#[fg=#1c1c1c,bg=#ffa500,bold]#(date -u "+%%H:%%M") • #[fg=#1c1c1c,bg=#ffa500,bold]#(uptime | cut -d ' ' -f 2)"

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
      set -ag terminal-features ',screen-256color:clipboard'
      # for tmux version (tmux -V) <3.2
      # Need this for mosh - https://github.com/mobile-shell/mosh/pull/1054#issuecomment-1303725548
      # set-option -ag terminal-overrides ",screen-256color:Ms=\\E]52;c;%p2%s\\7"

      # default statusbar colors
      set-option -g status-interval 1
      set-option -g status-style "fg=#ffa500,bg=#1c1c1c"

      # default window title colors
      set-window-option -g window-status-style "fg=#ffa500,bg=#1c1c1c"

      # active window title colors
      set-window-option -g window-status-current-style "fg=#ffa500,bg=#1c1c1c"

      # pane border
      set-option -g pane-border-style "fg=#1c1c1c"
      set-option -g pane-active-border-style "fg=#ffa500"

      # message text
      set-option -g message-style "fg=#ffa500,bg=#1c1c1c"

      # pane number display
      set-option -g display-panes-active-colour "#ffa500"
      set-option -g display-panes-colour "#ffa500"

      # clock
      set-window-option -g clock-mode-colour "#ffa500"

      # copy mode highlight
      set-window-option -g mode-style "bg=#4e4e4e"

      # bell
      set-window-option -g window-status-bell-style "fg=#1c1c1c,bg=#ffa500"
    '';
  };
}
