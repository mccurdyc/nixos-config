{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, flake-parts, nix-darwin, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake =
        let
          mkSystem = import ./lib/mkSystem.nix;

          fgnixArgs = {
            nixos-modules = [
              ./hosts/fgnix
              ./modules/nixos
            ];
            system = "x86_64-linux";
            home-module = ./home-modules/nixos;
            # passed to every module and home-module (via extraSpecialArgs)
            specialArgs = {
              user = "mccurdyc";
              currentSystemName = "fgnix";
            };
            inherit nixpkgs nixpkgs-unstable nix-darwin home-manager; # TODO - consider using 'inputs'
          };

          faamacArgs = {
            darwin-modules = [
              ./hosts/faamac
              ./modules/darwin
            ];
            system = "aarch64-darwin";
            home-module = import ./home-modules/darwin;
            darwin = true;
            # passed to every module and home-module (via extraSpecialArgs)
            specialArgs = {
              user = "mccurdyc";
              currentSystemName = "faamac";
            };
            inherit nixpkgs nixpkgs-unstable nix-darwin home-manager; # TODO - consider using 'inputs'
          };
        in
        {
          # sudo nixos-rebuild switch --flake '.#fgnix'
          nixosConfigurations.fgnix = mkSystem (fgnixArgs);

          # darwin-rebuild switch --flake '.#faamac'
          darwinConfigurations.faamac = mkSystem (faamacArgs);
        };

      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      # This is needed for pkgs-unstable - https://github.com/hercules-ci/flake-parts/discussions/105
      imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

      perSystem = { system, ... }:
        let
          pkgs = import inputs.nixpkgs { inherit system; config.allowUnfree = true; };
          pkgs-unstable = import inputs.nixpkgs-unstable { inherit system; config.allowUnfree = true; };
        in
        {
          # This is needed for pkgs-unstable - https://github.com/hercules-ci/flake-parts/discussions/105
          overlayAttrs = { inherit pkgs-unstable; };

          formatter = pkgs.nixpkgs-fmt;
          devShells.default = import ./shell.nix { inherit pkgs pkgs-unstable; };

          # nix build '.#fgnix'
          packages.fgnix = pkgs.testers.runNixOSTest {
            name = "Test connectivity to SSH";
            nodes.fgnix = {
              imports = [
                ./hosts/fgnix
                # TODO fix
                ./modules/nixos
                ./home-modules/nixos
              ];
            };
            testScript = ''
              start_all()
              fgnix.wait_for_unit("network-online.target")
              fgnix.succeed("tailscale status")
            '';
          };
        };
    };
}
