{ modulesPath, ... }:

{
  imports = [
    # The qemu-vm NixOS module gives us the `vm` attribute that we will later
    # use, and other VM-related settings
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  virtualisation.graphics = false;
}
