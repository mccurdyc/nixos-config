{
  config,
  pkgs-unstable,
  ...
}: {
  fonts.fonts = with pkgs-unstable; [
    source-code-pro
    font-awesome
    (nerdfonts.override {
      fonts = [
        "FiraCode"
      ];
    })
  ];
}
