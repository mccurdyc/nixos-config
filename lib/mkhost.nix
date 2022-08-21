# Inspiration - https://github.com/mitchellh/nixos-config/blob/6c03003b1101f363751a086b4e8178f4b7b6b20c/lib/mkvm.nix

name: { nixpkgs, home-manager, system, user }:

nixpkgs.lib.nixosSystem rec {
  inherit system;

  modules = [
    ../hardware/${name}.nix
    ../machines/${name}.nix
    ../users/${user}/nixos.nix

    home-manager.nixosModules.home-manager {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = import ../users/${user}/home-manager.nix;
    }

    {
      # https://github.com/NixOS/nixpkgs/blob/58088cb7978176f3cff387ebb4e3bc2716e7ce4d/lib/modules.nix#L172
      config._module.args = {
        currentSystemName = name;
        currentSystem = system;
      };
    }
  ];
}
