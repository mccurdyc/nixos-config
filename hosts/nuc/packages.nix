{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
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
