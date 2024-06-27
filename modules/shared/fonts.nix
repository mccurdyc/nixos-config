{ pkgs, ... }:

{
  fonts = {
    # if darwin
    #   then nix-darwin.lib.darwinSystem
    #   else nixpkgs.lib.nixosSystem;
    #   # icon fonts
    #   font-awesome
    #
    #     # nerdfonts
    #     (nerdfonts.override {
    #     # https://github.com/ryanoasis/nerd-fonts/
    #     fonts = [
    #     "FiraCode"
    #     "Iosevka"
    #     "SpaceMono"
    #   ];
    # })
    # ];
  };
}
