{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware/vm-gce-x86_64.nix
  ];
}
