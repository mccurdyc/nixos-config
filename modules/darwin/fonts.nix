{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      # icon fonts
      font-awesome

      # nerdfonts
      (nerdfonts.override {
        # https://github.com/ryanoasis/nerd-fonts/
        fonts = [
          "FiraCode"
          "Iosevka"
          "SpaceMono"
        ];
      })
    ];
  };
}
