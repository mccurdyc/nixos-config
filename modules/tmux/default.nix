{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.tmux;
in
{
  options.modules.tmux = { enable = mkEnableOption "tmux"; };
  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      baseIndex = 0;
      clock24 = true;
      newSession = true;
      keyMode = "vi";
      customPaneNavigationAndResize = true;
      shortcut = "a";
      terminal = "xterm-256color";
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
        set -g default-terminal "xterm-256color"
        set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'  # undercurl support
        set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'  # underscore colours - needs tmux-3.0

        # https://unix.stackexchange.com/a/320496
        # necessary to reload shell config changes
        set -g default-shell "${pkgs.zsh}/bin/zsh"

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
        # set -ag terminal-features ',xterm-256color:clipboard'
        # for tmux version (tmux -V) <3.2
        # Need this for mosh - https://github.com/mobile-shell/mosh/pull/1054#issuecomment-1303725548
        set-option -ag terminal-overrides ",xterm-256color:Ms=\\E]52;c;%p2%s\\7"

        set -g status-left-style "none"
        set -g message-command-style "fg=colour7,bg=colour19"
        set -g status-right-style "none"
        set -g pane-active-border-style "fg=colour16"
        set -g status-style "none,bg=colour18"
        set -g message-style "fg=colour7,bg=colour19"
        set -g pane-border-style "fg=colour19"
        set -g status-right-length "100"
        set -g status-left-length "100"
        setw -g window-status-activity-style "none"
        setw -g window-status-separator ""
        setw -g window-status-style "none,fg=colour15,bg=colour18"
        set -g status-left "#[fg=colour0,bg=colour16] #S #[fg=colour16,bg=colour18,nobold,nounderscore,noitalics]"
        set -g status-right "#[fg=colour19,bg=colour18,nobold,nounderscore,noitalics]#[fg=colour8,bg=colour19] %Y-%m-%d | %H:%M #[fg=colour8,bg=colour19,nobold,nounderscore,noitalics]#[fg=colour18,bg=colour8] #h "
        setw -g window-status-format "#[fg=colour15,bg=colour18] #I |#[fg=colour15,bg=colour18] #W "
        setw -g window-status-current-format "#[fg=colour18,bg=colour19,nobold,nounderscore,noitalics]#[fg=colour7,bg=colour19] #I |#[fg=colour7,bg=colour19] #W #[fg=colour19,bg=colour18,nobold,nounderscore,noitalics]"

        # COLOUR (base16)
        # https://github.com/mattdavis90/base16-tmux/blob/master/colors/base16-eighties.conf
        # default statusbar colors
        set-option -g status-style "fg=#a09f93,bg=#393939"

        # default window title colors
        set-window-option -g window-status-style "fg=#a09f93,bg=default"

        # active window title colors
        set-window-option -g window-status-current-style "fg=#f99157,bg=default"

        # pane border
        set-option -g pane-border-style "fg=#f99157"
        set-option -g pane-active-border-style "fg=#393939"

        # message text
        set-option -g message-style "fg=#d3d0c8,bg=#393939"

        # pane number display
        set-option -g display-panes-active-colour "#f99157"
        set-option -g display-panes-colour "#393939"

        # clock
        set-window-option -g clock-mode-colour "#f99157"

        # copy mode highlight
        set-window-option -g mode-style "fg=#2d2d2d,bg=#f99157"

        # bell
        set-window-option -g window-status-bell-style "fg=#393939,bg=#f2777a"
      '';
    };
  };
}
