_: {
  programs.ghostty = {
    enable = false; # installed via brew since nix package is broken
  };

  xdg.configFile."ghostty/config".text = ''
    # https://ghostty.org/docs/config/reference
    font-size = "20"
    font-family = "SpaceMono Nerd Font"

    window-decoration = "none"
    term = "xterm-256color"
    scrollback-limit = 10000

    shell-integration-features = no-cursor

    cursor-style = "block"
    link-url = true
    cursor-style-blink = true
    cursor-color = "#d3d0c8"

    background = "#040405"
    foreground = "#e4e4e4"
    selection-background = "#1d1d1d"
    selection-foreground = "#e4e4e4"

    palette = 0=#040405
    palette = 1=#ff5f5f
    palette = 2=#5fd787
    palette = 3=#ffa500
    palette = 4=#2950c5
    palette = 5=#cc99cc
    palette = 6=#66cccc
    palette = 7=#e4e4e4
    palette = 8=#2d2d2d
    palette = 9=#ff5f5f
    palette = 10=#5fd787
    palette = 11=#ffa500
    palette = 12=#2950c5
    palette = 13=#cc99cc
    palette = 14=#66cccc
    palette = 16=#e4e4e4
  '';
}
