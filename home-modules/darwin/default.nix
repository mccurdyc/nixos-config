{ pkgs, ... }:

{
  imports = [
    ../shared
  ];

  home.packages = with pkgs; [
    raycast
  ];
}
