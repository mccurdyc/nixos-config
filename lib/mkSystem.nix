{ nixpkgs, nix-darwin, home-manager, home-module, disko, gws, llm-agents, darwin-modules ? [ ], nixos-modules ? [ ], system, specialArgs, darwin ? false }:

let
  systemFn =
    if darwin
    then nix-darwin.lib.darwinSystem
    else nixpkgs.lib.nixosSystem;

  homeFn =
    if darwin
    then home-manager.darwinModules.home-manager
    else home-manager.nixosModules.home-manager;

  extendedSpecialArgs = specialArgs // { inherit home-manager; };
in

systemFn {
  specialArgs = extendedSpecialArgs;
  modules = darwin-modules ++ nixos-modules ++ [
    {
      nixpkgs.hostPlatform = system;
      nixpkgs.config = {
        allowUnfree = true;
        allowBroken = true; #ghostty
      };
      nixpkgs.overlays = [
        llm-agents.overlays.default
        (final: _prev: {
          gws = gws.packages.${final.system}.default;
        })
      ];
    }

    homeFn
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.extraSpecialArgs = extendedSpecialArgs;
      home-manager.users."${specialArgs.user}" = import home-module;
    }
  ];
}
