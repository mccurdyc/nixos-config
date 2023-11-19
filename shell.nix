# https://nixos.wiki/wiki/Flakes#Super_fast_nix-shell
{ pkgs }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    statix
    rnix-lsp
    nixpkgs-fmt
  ];
}
