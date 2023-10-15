# https://nixos.wiki/wiki/Flakes#Super_fast_nix-shell
{pkgs ? import <nixpkgs> {}}:
with pkgs;
  mkShell {
    buildInputs = with pkgs; [
      alejandra
      statix
      rnix-lsp
    ];
  }
