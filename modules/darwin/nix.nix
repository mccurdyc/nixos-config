{ ... }:

{
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.useDaemon = true;
  nix.gc.user = "root";
}
