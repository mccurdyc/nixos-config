{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wireguard-tools
    google-cloud-sdk
  ];
}
