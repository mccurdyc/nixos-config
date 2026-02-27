{ pkgs, ... }:

{
  home.packages = with pkgs; [
    awscli2
    cntr
    google-cloud-sdk
    infra
    k3d
    k9s
    kubectl
    kubernetes-helm
    kubie
    ssm-session-manager-plugin
    wireguard-tools
    zoekt
  ];
}
