{ pkgs, ... }:

{
  fonts = {
    fontDir.enable = true;

    packages = with pkgs; [
      # icon fonts
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
