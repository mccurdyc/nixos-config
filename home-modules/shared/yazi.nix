{ ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      preview = {
        image_filter = "lanczos3";
        image_quality = 90;
        max_width = 600;
        max_height = 900;
      };
    };
  };
}
