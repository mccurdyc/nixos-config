_: {
  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        TERM = "xterm-256color";
      };

      selection = {
        save_to_clipboard = true;
      };

      scrolling = {
        # Maximum number of lines in the scrollback buffer.
        # Specifying '0' will disable scrolling.
        history = 100000;
      };

      font = {
        normal.family = "SpaceMono Nerd Font";
        bold = { style = "Bold"; };
        size = 20;
      };

      window.dimensions = {
        lines = 30;
        columns = 100;
      };

      # remove titlebar
      window.decorations = "None";

      # Base16 Eighties 256 - alacritty color config
      # Chris Kempson (http://chriskempson.com)
      colors = {
        # Default colors
        primary = {
          background = "0x202020";
          foreground = "0xd3d0c8";
        };

        # Colors the cursor will use if `custom_cursor_colors` is true
        cursor = {
          text = "0x202020";
          cursor = "0xd3d0c8";
        };

        # Normal colors
        normal = {
          black = "0x414141"; # zsh comments
          red = "0xf2777a";
          green = "0x99cc99";
          yellow = "0xffcc66";
          blue = "0x6699cc";
          magenta = "0xcc99cc";
          cyan = "0x66cccc";
          white = "0xd3d0c8";
        };

        # Bright colors
        bright = {
          black = "0x747369";
          red = "0xf2777a";
          green = "0x99cc99";
          yellow = "0xffcc66";
          blue = "0x6699cc";
          magenta = "0xcc99cc";
          cyan = "0x66cccc";
          white = "0xf2f0ec";
        };

        indexed_colors = [
          {
            index = 16;
            color = "0xf99157";
          }
          {
            index = 17;
            color = "0xd27b53";
          }
          {
            index = 18;
            color = "0x393939";
          }
          {
            index = 19;
            color = "0x515151";
          }
          {
            index = 20;
            color = "0xa09f93";
          }
          {
            index = 21;
            color = "0xe8e6df";
          }
        ];
      };
    };
  };
}
