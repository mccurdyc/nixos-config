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
          mkSystem = import ./lib/mkSystem.nix {
            inherit nixpkgs nixpkgs-unstable nix-darwin home-manager;
          };

          user = "mccurdyc";

          # For nixos-rebuild.
          additionalModules = [
            { nixpkgs = { config.allowUnfree = true; }; }
          ];

          # For nix build / NixOS tests.
          pkgs = import nixpkgs {
            config.allowUnfree = true;
          };
        in
        {
          # sudo nixos-rebuild switch --flake '.#fgnix'
          nixosConfigurations = {
            fgnix = mkSystem {
              name = "fgnix";
              system = "x86_64-linux";
              profile = "fgnix";
              inherit user additionalModules;
            };

            # darwin-rebuild switch --flake '.#faamac'
            faamac = mkSystem {
              name = "faamac";
              system = "aarch64-darwin";
              profile = "faamac";
              darwin = true;
              inherit user additionalModules;
            };
          };
        };

      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      # This is needed for pkgs-unstable - https://github.com/hercules-ci/flake-parts/discussions/105
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
      ];

      perSystem =
        { system, pkgs, pkgs-unstable, lib, config, specialArgs, options }:

        let

          pkgs = import inputs.nixpkgs { inherit system; config.allowUnfree = true; };
          pkgs-unstable = import inputs.nixpkgs-unstable { inherit system; };

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
              imports = import ./lib/modules.nix {
                name = "fgnix";
                system = "x86_64-linux"; # if we do perSystem, I guess change this to system to check.
                profile = "fgnix";
                user = "mccurdyc";
                inherit nixpkgs nixpkgs-unstable home-manager;
                darwin = false;
              };
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
