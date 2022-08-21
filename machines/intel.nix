{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./shared.nix
  ];

  # Lots of stuff that claims doesn't work, actually works.
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;
}
