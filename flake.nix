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
    nix-darwin = {
      # MacOS Package Management
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, flake-utils, nix-darwin, ... }:

    let
      # modules expect to pass a var named explicitly 'pkgs'.
      pkgs = nixpkgs;
      pkgs-unstable = nixpkgs-unstable;
      inherit (nixpkgs) config;

      mkSystem = import ./lib/mkSystem.nix {
        inherit pkgs pkgs-unstable config nix-darwin home-manager;
        inherit (pkgs) lib;
      };

      user = "mccurdyc";

      fgnix = mkSystem {
        name = "fgnix";
        system = "x86_64-linux";
        profile = "fgnix";
        inherit user;
      };

      # nuc = mkSystem {
      #   name = "nuc";
      #   system = "x86_64-linux";
      #   profile = "nuc";
      #   inherit user;
      # };

      faamac = mkSystem {
        name = "faamac";
        system = "aarch64-darwin";
        profile = "faamac";
        darwin = true;
        inherit user;
      };

    in
    {
      nixosConfigurations.fgnix = fgnix;
      # nixosConfigurations.nuc = nuc;
      darwinConfigurations.faamac = faamac;
    } // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
      in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = import ./shell.nix { inherit pkgs pkgs-unstable; };

        # Writing tests - https://nixos.org/manual/nixos/stable/#sec-nixos-tests
        # Running tests - https://nixos.org/manual/nixos/stable/#sec-running-nixos-tests
        # https://nixcademy.com/2023/10/24/nixos-integration-tests/
        # 'nix flake check'
        checks.default = pkgs.testers.runNixOSTest
          {
            name = "Test connectivity to SSH";
            nodes = {
              # NixOS Configuration - https://nixos.org/manual/nixos/stable/options
              foo = {
                imports = [
                  fgnix
                ];
              };
              testScript = ''
                start_all()
                foo.wait_for_unit("network-online.target")
                foo.succeed("tailscale status")
              '';
            };
          };
      }
    ));
}
