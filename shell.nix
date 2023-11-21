# https://nixos.wiki/wiki/Flakes#Super_fast_nix-shell
{ pkgs, pkgs-unstable }:
pkgs.mkShell {
  buildInputs = [
    pkgs.statix
    pkgs.nixpkgs-fmt
    pkgs-unstable.nixd
  ];
}
