{ pkgs, ... }:

{
  services.gpg-agent.enable = true;
  services.gpg-agent.pinentryPackage = pkgs.pinentry; # https://github.com/NixOS/nixpkgs/blob/9b5328b7f761a7bbdc0e332ac4cf076a3eedb89b/nixos/modules/programs/gnupg.nix#L90-L92
}
