# https://nixos.wiki/wiki/Flakes#Super_fast_nix-shell
{ pkgs, pkgs-unstable }:
pkgs.mkShell {
  buildInputs = [
    pkgs.statix
    pkgs.deadnix
    pkgs.nixpkgs-fmt
    pkgs.google-cloud-sdk
    pkgs.lua54Packages.luacheck
    pkgs-unstable.nil
    pkgs.stylua
    pkgs.lua-language-server
  ];
}
