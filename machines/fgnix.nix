{ config, lib, nixpkgs, options, specialArgs, modulesPath }: {
  imports = [
    ./hardware/vm-gce-x86_64.nix
  ];
}
