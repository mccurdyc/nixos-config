# https://nixos.wiki/wiki/Flakes#Super_fast_nix-shell
{ pkgs, pkgs-unstable }:
pkgs.mkShell {
  buildInputs = [
    pkgs.statix
    pkgs.nixpkgs-fmt
    pkgs.google-cloud-sdk
    pkgs.lua54Packages.luacheck
    pkgs-unstable.nil
  ];
}
