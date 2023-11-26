{ nixpkgs, nixpkgs-unstable, nix-darwin, home-manager, home-module, darwin-modules ? [ ], nixos-modules ? [ ], system, specialArgs, darwin ? false }:

let
  systemFn =
    if darwin
    then nix-darwin.lib.darwinSystem
    else nixpkgs.lib.nixosSystem;

  homeFn =
    if darwin
    then home-manager.darwinModules.home-manager
    else home-manager.nixosModules.home-manager;

  pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
  pkgs-unstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
  extendedSpecialArgs = specialArgs // { inherit pkgs pkgs-unstable; };
in

systemFn {
  inherit system;
  specialArgs = extendedSpecialArgs;
  modules = darwin-modules ++ nixos-modules ++ [

    homeFn
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.extraSpecialArgs = extendedSpecialArgs;
      home-manager.users."${specialArgs.user}" = import home-module;
    }
  ];
}
