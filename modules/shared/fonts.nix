{ pkgs, ... }:

{
  fonts = {
    fontDir.enable = true;

    fonts = with pkgs; [
      # icon fonts
      material-design-icons
      font-awesome

      # nerdfonts
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "Iosevka"
        ];
      })
    ];
  };
}
