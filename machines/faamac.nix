{
  config,
  pkgs,
  ...
}: {
  # https://mynixos.com/nix-darwin/options/
  nix.useDaemon = true;
  networking.computerName = "faamac";
  networking.hostName = "faamac";
  networking.localHostName = "faamac";
}
