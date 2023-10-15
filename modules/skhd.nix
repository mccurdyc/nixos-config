{pkgs, ...}: {
  services.skhd = {
    enable = true;
    package = pkgs.skhd;
    skhdConfig = ''
              # Open Terminal
              alt - return : /Applications/Alacritty.App/Contents/MacOS/alacritty

              # Toggle Window
              alt - t : yabai -m window --toggle float && yabai -m window --grid 4:4:1:1:2:2
              alt - f : yabai -m window --toggle zoom-fullscreen
              alt - q : yabai -m window --close

              # Focus Window
              alt - k : yabai -m window --focus north
              alt - j : yabai -m window --focus south
              alt - h : yabai -m window --focus west
              alt - l : yabai -m window --focus east

              # Swap Window
              shift + alt - k : yabai -m window --swap north
              shift + alt - j : yabai -m window --swap south
              shift + alt - h : yabai -m window --swap west
              shift + alt - l : yabai -m window --swap east

              # Resize Window
              shift + cmd - k : yabai -m window --resize up:-50:0 && yabai -m window --resize down:-50:0
              shift + cmd - j : yabai -m window --resize up:-50:0 && yabai -m window --resize down:-50:0
              shift + cmd - h : yabai -m window --resize left:-50:0 && yabai -m window --resize right:-50:0
              shift + cmd - l : yabai -m window --resize left:50:0 && yabai -m window --resize right:50:0

              # Focus Space
              ctrl - 1 : yabai -m space --focus 1
              ctrl - 2 : yabai -m space --focus 2
              ctrl - 3 : yabai -m space --focus 3
              ctrl - 4 : yabai -m space --focus 4
              ctrl - 5 : yabai -m space --focus 5
              ctrl - left : yabai -m space --focus prev
              ctrl - right: yabai -m space --focus next

              # Send to Space
              shift + ctrl - 1 : yabai -m window --space 1
              shift + ctrl - 2 : yabai -m window --space 2
              shift + ctrl - 3 : yabai -m window --space 3
              shift + ctrl - 4 : yabai -m window --space 4
              shift + ctrl - 5 : yabai -m window --space 5
              shift + ctrl - left : yabai -m window --space prev && yabai -m space --focus prev
              shift + ctrl - right : yabai -m window --space next && yabai -m space --focus next

      # https://bryce-s.com/yabai/
       # create desktop, move window and follow focus - uses jq for parsing json
       # https://nixos.org/manual/nix/stable/language/values.html#primitives
       		shift + cmd - n : yabai -m space --create && \
                      index="$(yabai -m query --spaces --display | jq 'map(select(."native-fullscreen" == 0))[-1].index')" && \
                      yabai -m window --space "$index" && \
                      yabai -m space --focus "$index"

      # create desktop and follow focus - uses jq for parsing json
      cmd + alt - n : yabai -m space --create && \
      	index="$(yabai -m query --spaces --display | jq 'map(select(."native-fullscreen" == 0))[-1].index')" && \
      	yabai -m space --focus "$index"

      # destroy desktop
      cmd + alt - w : yabai -m space --destroy

              # Menu
              #cmd + space : for now its using the default keybinding to open Spotlight Search
    '';
  };

  system = {
    keyboard = {
      enableKeyMapping = true;
    };
  };
}
