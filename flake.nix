{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, flake-utils, nix-darwin, ... }:
    let
      mkSystem = import ./lib/mkSystem.nix {
        inherit nixpkgs nixpkgs-unstable nix-darwin home-manager;
      };

      user = "mccurdyc";
    in
    {
      # sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --impure --flake '.#fgnix'
      nixosConfigurations = {
        fgnix = mkSystem {
          name = "fgnix";
          system = "x86_64-linux";
          profile = "fgnix";
          inherit user;
        };

        # NIXPKGS_ALLOW_UNFREE=1 darwin-rebuild switch --impure --flake '.#faamac'
        faamac = mkSystem {
          name = "faamac";
          system = "aarch64-darwin";
          profile = "faamac";
          darwin = true;
          inherit user;
        };

        # nuc = mkSystem {
        #   name = "nuc";
        #   system = "x86_64-linux";
        #   profile = "nuc";
        #   inherit user;
        # };
      };

    } // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = import ./shell.nix { inherit pkgs pkgs-unstable; };
      }
    )) // (flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
      in
      {
        # NIXPKGS_ALLOW_UNFREE=1 nix build --impure '.#fgnix'
        packages.fgnix = pkgs.testers.runNixOSTest
          {
            name = "Test connectivity to SSH";
            nodes = {
              fgnix = {
                imports = import ./lib/modules.nix {
                  name = "fgnix";
                  system = "x86_64-linux"; # if we do perSystem, I guess change this to system to check.
                  profile = "fgnix";
                  inherit user nixpkgs nixpkgs-unstable home-manager;
                  darwin = false;
                };
              };
            };
            testScript = ''
              start_all()
              fgnix.wait_for_unit("network-online.target")
              fgnix.succeed("tailscale status")
            '';
          };
      }));
}
