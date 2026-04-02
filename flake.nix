{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gws = {
      url = "github:googleworkspace/cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, flake-parts, nix-darwin, disko, gws, llm-agents, ... }:
    let
      specialArgs = {
        user = "mccurdyc";
        hashedPassword = "$y$j9T$5CjBgjlXBsYF3FYnTP9wQ.$hl8uCypIgOcrh3OrhcJA600Fgv5T9l0U85InRwmRdy5";
        zshPath = "/etc/profiles/per-user/mccurdyc/bin/zsh";
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake =
        let
          mkSystem = import ./lib/mkSystem.nix;

          fgnixArgs = {
            system = "x86_64-linux";
            nixos-modules = [
              ./hosts/hardware/vm-gce-x86_64.nix
              ./hosts/fgnix
              ./modules/nixos
            ];
            home-module = ./home-modules/fgnix;
            inherit specialArgs; # passed to every module and home-module (via extraSpecialArgs)
            inherit nixpkgs nix-darwin home-manager disko gws llm-agents; # TODO - consider using 'inputs'
          };

          nucArgs = {
            system = "x86_64-linux";
            nixos-modules = [
              ./hosts/hardware/x86_64.nix
              ./hosts/nuc
              ./modules/nixos
            ];
            home-module = ./home-modules/nuc;
            inherit specialArgs; # passed to every module and home-module (via extraSpecialArgs)
            inherit nixpkgs nix-darwin home-manager disko gws llm-agents; # TODO - consider using 'inputs'
          };

          faamacArgs = {
            system = "aarch64-darwin";
            darwin = true;
            darwin-modules = [
              ./hosts/faamac
              ./modules/darwin
            ];
            home-module = ./home-modules/faamac;
            inherit specialArgs; # passed to every module and home-module (via extraSpecialArgs)
            inherit nixpkgs nix-darwin home-manager disko gws llm-agents; # TODO - consider using 'inputs'
            # TODO: add lvk so that my mac can use the devbox for nix build, etc.
          };

          funixArgs = {
            system = "x86_64-linux";
          };
        in
        {
          # sudo nixos-rebuild switch --flake '.#fgnix'
          nixosConfigurations.fgnix = mkSystem fgnixArgs;

          # sudo nixos-rebuild switch --flake '.#nuc'
          nixosConfigurations.nuc = mkSystem nucArgs;

          # darwin-rebuild switch --flake '.#faamac'
          darwinConfigurations.faamac = mkSystem faamacArgs;

          # home-manager switch --flake '.#funix'
          homeConfigurations.funix = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              inherit (funixArgs) system;
              config.allowUnfree = true;
              config.allowBroken = true;
              overlays = [
                llm-agents.overlays.default
                (final: _prev: {
                  gws = gws.packages.${final.system}.default;
                })
              ];
            };
            extraSpecialArgs = specialArgs // {
              zshPath = "/home/cmccurdy_fastly_com/.nix-profile/bin/zsh";
              inherit home-manager;
            };
            modules = [ ./home-modules/funix ];
          };
        };

      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      perSystem = { system, ... }:
        let
          pkgs = import inputs.nixpkgs { inherit system; config.allowUnfree = true; };
        in
        {
          formatter = pkgs.nixpkgs-fmt;
          devShells.default = import ./shell.nix { inherit pkgs; };

          checks = pkgs.lib.optionalAttrs (system == "x86_64-linux") {
            fgnix = import ./tests/fgnix.nix {
              inherit pkgs specialArgs;
              inherit (inputs) home-manager;
            };
            nuc = import ./tests/nuc.nix {
              inherit pkgs specialArgs;
              inherit (inputs) home-manager;
            };
            # Eval-only: building the activation package confirms the config evaluates.
            funix = inputs.self.homeConfigurations.funix.activationPackage;
          } // pkgs.lib.optionalAttrs (system == "aarch64-darwin") {
            # Eval-only: building the system drv confirms the darwin config evaluates.
            faamac = inputs.self.darwinConfigurations.faamac.system;
          };
        };
    };
}
