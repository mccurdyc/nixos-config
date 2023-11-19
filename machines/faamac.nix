_: {
  # https://mynixos.com/nix-darwin/options/
  nix.useDaemon = true;
  nix.linux-builder.enable = true; # support for nixos-anywhere building for a linux target
  networking.computerName = "faamac";
  networking.hostName = "faamac";
  networking.localHostName = "faamac";
}
