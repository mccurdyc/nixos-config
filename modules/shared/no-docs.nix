{ pkgs, ... }:

{
  documentation.enable = pkgs.lib.mkForce false;
  documentation.nixos.enable = pkgs.lib.mkForce false;
}
