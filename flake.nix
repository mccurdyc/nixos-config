# https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#flake-references
{
  # inputs: An attrset specifying the dependencies of the flake (described below).
  # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#flake-inputs
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , flake-utils
    , ...
    } @ inputs:
    let
      # https://nixos.wiki/wiki/Flakes#Importing_packages_from_multiple_channels
      overlay-unstable = system: final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          inputs.nixpkgs.config.allowUnfree = true;
        };
      };

      mkSystem =
        { nixpkgs ? inputs.nixpkgs-unstable
        , system
        , hostname
        }:
        nixpkgs.lib.nixosSystem
          {
            inherit system;

            modules = [
              {
                networking.hostName = hostname;
              }
              ./modules/system/configuration.nix
              (./. + "/hosts/${hostname}/hardware-configuration.nix")

              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useUserPackages = true;
                  useGlobalPkgs = true;
                  extraSpecialArgs = { inherit inputs; };
                  users.mccurdyc = ./. + "/hosts/${hostname}/user.nix";
                };
              }
              {
                nixpkgs.overlays = [
                  (overlay-unstable system)
                ];
              }
            ];
          };
    in
    {
      nixosConfigurations = {
        nuc = mkSystem {
          system = "x86_64-linux";
          hostname = "nuc";
        };

        # GCE Arm Nix
        ganix = mkSystem {
          system = "aarch64-linux";
          hostname = "ganix";
        };
      };
    };
}
