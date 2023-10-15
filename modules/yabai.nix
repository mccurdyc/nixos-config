# Refs
# - https://bryce-s.com/yabai/
{pkgs, ...}: {
  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    config = {
      layout = "bsp";
      auto_balance = "off";
      split_ratio = "0.50";
      window_placement = "second_child";
      focus_follows_mouse = "off";
      mouse_follows_focus = "off";
      top_padding = "10";
      bottom_padding = "10";
      left_padding = "10";
      right_padding = "10";
      window_gap = "5";
      # https://github.com/koekeishiya/yabai/blob/master/doc/yabai.asciidoc#6-domains
      window_border = "on";
      window_border_width = "4";
      window_border_hidpi = "on";
      window_border_blur = "off";
      window_border_radius = "0";
      insert_feedback_color = "0xffa54242";
      active_window_border_color = "0xffde935f";
      normal_window_border_color = "0xffc5c8c6";
    };
    extraConfig = ''
      yabai -m rule --add title='Preferences' manage=off layer=above
      yabai -m rule --add title='^(Opening)' manage=off layer=above
      yabai -m rule --add title='Library' manage=off layer=above
      yabai -m rule --add app='^System Preferences$' manage=off layer=above
      yabai -m rule --add app='Activity Monitor' manage=off layer=above
      yabai -m rule --add app='Finder' manage=off layer=above
      yabai -m rule --add app='^System Information$' manage=off layer=above
    '';
  };
}
