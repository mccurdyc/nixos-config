{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    raycast
    infra
  ];
}
