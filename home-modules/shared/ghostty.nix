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

    cursor-style = "block_hollow"
    link-url = true
    cursor-style-blink = true
    cursor-color = "#d3d0c8"

    background = "#202020"
    foreground = "#d3d0c8"
    selection-background = "#262626"
    selection-foreground = "#d3d0c8"

    palette = 0=#414141
    palette = 1=#f2777a
    palette = 2=#99cc99
    palette = 3=#ffcc66
    palette = 4=#6699cc
    palette = 5=#cc99cc
    palette = 6=#66cccc
    palette = 7=#d3d0c8
    palette = 8=#414141
    palette = 9=#f2777a
    palette = 10=#99cc99
    palette = 11=#ffcc66
    palette = 12=#6699cc
    palette = 13=#cc99cc
    palette = 14=#66cccc
    palette = 16=#d3d0c8
  '';
}
