{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";
    # We use the unstable nixpkgs repo for some packages.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      # We want home-manager to use the same set of nixpkgs as our system.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    mkHost = import ./lib/mkhost.nix;
  in {
    # Default container template
    # nixosConfigurations.container = nixpkgs.lib.nixosSystem
    nixosConfigurations.intel = mkHost "intel" rec {
      inherit nixpkgs home-manager;
      system = "x86_64-linux";
      user = "mccurdyc";
    };
  };
}
