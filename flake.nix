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
        profile = "work";
        inherit user;
      };

      nuc = mkSystem {
        name = "nuc";
        system = "x86_64-linux";
        inherit user;
      };

      faamac = mkSystem {
        name = "faamac";
        system = "aarch64-darwin";
        profile = "work";
        darwin = true;
        inherit user;
      };

    in
    {
      nixosConfigurations.fgnix = fgnix;
      nixosConfigurations.nuc = nuc;
      darwinConfigurations.faamac = faamac;
    } // (flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = import ./shell.nix { inherit pkgs; };

        # Writing tests - https://nixos.org/manual/nixos/stable/#sec-nixos-tests
        # Running tests - https://nixos.org/manual/nixos/stable/#sec-running-nixos-tests
        # nix build
        # https://nixcademy.com/2023/10/24/nixos-integration-tests/
        # checks.default = pkgs.testers.runNixOSTest
        #   {
        #     name = "Test connectivity to SSH";
        #     nodes = {
        #       # NixOS Configuration - https://nixos.org/manual/nixos/stable/options
        #       # Pattern from - https://github.com/NixOS/nixpkgs/blob/d3deaacfb475a62ceba63f34672280029ad6c738/nixos/tests/google-oslogin/default.nix#L20
        #       # doesn't work
        #       # foo = mkSystem {
        #       #   name = "foo";
        #       #   system = "x86_64-linux";
        #       #   profile = "work";
        #       #   user = "mccurdyc";
        #       # };
        #     };
        #     testScript = ''
        #       start_all()
        #       foo.wait_for_unit("network-online.target")
        #       foo.succeed("tailscale status")
        #     '';
        #   };
      }
    ));
}
