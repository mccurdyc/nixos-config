# https://github.com/cor/nixos-config/blob/3156d0ca560a8561187b0f4ab3cb25bbbb4ddc9f/flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05"; # Stable Nix Packages (Default)
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable"; # Unstable Nix Packages

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      # User Environment Manager
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      # MacOS Package Management
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    flake-utils,
    darwin,
    ...
  } @ inputs: let
    mkSystem = import ./lib/mkSystem.nix {
      inherit nixpkgs nixpkgs-unstable inputs;
      inherit (nixpkgs) lib;
    };

    user = "mccurdyc";
  in
    {
      nixosConfigurations.fgnix = mkSystem "fgnix" {
        system = "x86_64-linux";
        profile = "work";
        inherit user;
      };

      nixosConfigurations.nuc = mkSystem "nuc" {
        system = "x86_64-linux";
        inherit user;
      };

      darwinConfigurations.faamac = mkSystem "faamac" {
        system = "aarch64-darwin";
        profile = "work";
        darwin = true;
        inherit user;
      };
    }
    // (flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        formatter = pkgs.alejandra;

        devShells = {
          default = import ./shell.nix {inherit pkgs;};
        };
      }
    ));
}
