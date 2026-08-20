{ ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    settings = {
      preview = {
        image_filter = "lanczos3";
        image_quality = 90;
        max_width = 600;
        max_height = 900;
      };
    };
    theme = {
      manager = {
        cwd = { fg = "#ffa500"; };
        hovered = { bg = "#1d1d1d"; };
        preview_hovered = { bg = "#1d1d1d"; };
        find_keyword = { fg = "#ffa500"; bold = true; };
        find_position = { fg = "#5fd787"; };
        marker_selected = { fg = "#ffa500"; bg = "#ffa500"; };
        marker_copied = { fg = "#5fd787"; bg = "#5fd787"; };
        marker_cut = { fg = "#ff5f5f"; bg = "#ff5f5f"; };
        tab_active = { fg = "#e4e4e4"; bg = "#2d2d2d"; };
        tab_inactive = { fg = "#5d5d5d"; bg = "#0d0d0d"; };
        border_symbol = "│";
        border_style = { fg = "#2950c5"; };
      };
      status = {
        separator_open = "";
        separator_close = "";
        mode_normal = { fg = "#040405"; bg = "#ffa500"; bold = true; };
        mode_select = { fg = "#040405"; bg = "#5fd787"; bold = true; };
        mode_unset = { fg = "#040405"; bg = "#ff5f5f"; bold = true; };
        progress_label = { fg = "#e4e4e4"; };
        progress_normal = { fg = "#2950c5"; };
        progress_error = { fg = "#ff5f5f"; };
      };
      input = {
        border = { fg = "#2950c5"; };
        title = { fg = "#e4e4e4"; };
        value = { fg = "#e4e4e4"; };
        selected = { bg = "#2d2d2d"; };
      };
      select = {
        border = { fg = "#2950c5"; };
        active = { fg = "#ffa500"; bold = true; };
        inactive = { fg = "#b1b1b1"; };
      };
      filetype = {
        rules = [
          { mime = "image/*"; fg = "#ffa500"; }
          { mime = "video/*"; fg = "#ffa500"; }
          { mime = "audio/*"; fg = "#5fd787"; }
          { mime = "text/*"; fg = "#b1b1b1"; }
          { mime = "application/*"; fg = "#e4e4e4"; }
        ];
      };
    };
  };
}
