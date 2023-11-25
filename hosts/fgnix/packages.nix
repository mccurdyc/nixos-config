{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    awscli2
    infra
    kubectl
    kubernetes-helm
    kubie
    python311Packages.google-compute-engine # needed for GCE startup-scripts
    ssm-session-manager-plugin
    wireguard-tools

    (writeShellScriptBin "docker-stop-all" ''
      docker stop $(docker ps -q)
      docker system prune -f
    '')
    (writeShellScriptBin "docker-prune-all" ''
      docker-stop-all
      docker rmi -f $(docker images -a -q)
      docker volume prune -f
    '')
  ];
}
