{ pkgs, ... }:

{
  documentation.enable = pkgs.lib.mkForce true;
  documentation.nixos.enable = pkgs.lib.mkForce true;
}
