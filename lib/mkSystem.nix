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
        llm-agents.overlays.shared-nixpkgs
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
      home-manager.users."${specialArgs.user}" = {
        imports = [ (import home-module) ];
        home.username = specialArgs.user;
        home.homeDirectory =
          if darwin
          then "/Users/${specialArgs.user}"
          else "/home/${specialArgs.user}";
      };
    }
  ];
}
