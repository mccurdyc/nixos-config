{ pkgs, ... }:

{
  home.packages = with pkgs; [
    cntr
    infra
  ];
}
