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
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , flake-utils
    , darwin
    , ...
    } @ inputs:
    let
      mkSystem = import ./lib/mkSystem.nix {
        inherit nixpkgs nixpkgs-unstable inputs;
        inherit (nixpkgs) lib;
      };

      user = "mccurdyc";

      fgnix = mkSystem "fgnix" {
        system = "x86_64-linux";
        profile = "work";
        inherit user;
      };

      nuc = mkSystem "nuc" {
        system = "x86_64-linux";
        inherit user;
      };

      faamac = mkSystem "faamac" {
        system = "aarch64-darwin";
        profile = "work";
        darwin = true;
        inherit user;
      };
    in
    {
      nixosConfigurations.fgnix = fgnix;
      nixosConfigurations.nuc =  nuc;
      darwinConfigurations.faamac = faamac;
    }
    // (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        devShells = {
          default = import ./shell.nix { inherit pkgs; };
        };

        # Writing tests - https://nixos.org/manual/nixos/stable/#sec-nixos-tests
        # Running tests - https://nixos.org/manual/nixos/stable/#sec-running-nixos-tests
        # nix build
        # https://nixcademy.com/2023/10/24/nixos-integration-tests/
        packages.default = pkgs.testers.runNixOSTest {
          name = "Test connectivity to SSH";
          nodes = {
            # NixOS Configuration - https://nixos.org/manual/nixos/stable/options
            inherit fgnix;
          };
          testScript = ''
            start_all()
            fgnix.wait_for_unit("network-online.target")
            fgnix.succeed("nc machine 22")
          '';
        };
      }
    ));
}
