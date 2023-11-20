{ config, lib, pkgs, options, specialArgs, modulesPath }: {
  imports = [
    ./hardware/vm-gce-x86_64.nix
  ];
}
