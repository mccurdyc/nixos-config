# https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#flake-references
{
  # inputs: An attrset specifying the dependencies of the flake (described below).
  # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#flake-inputs
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , flake-utils
    , ...
    } @ inputs:
    let
      mkSystem =
        { nixpkgs ? inputs.nixpkgs
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

        fgnix = mkSystem {
          system = "x86_64-linux";
          hostname = "fgnix";
        };
      };
    };
}
