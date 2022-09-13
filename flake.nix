# https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#flake-references
{
  # inputs: An attrset specifying the dependencies of the flake (described below).
  # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#flake-inputs
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";
    # We use the unstable nixpkgs repo for some packages.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      # We want home-manager to use the same set of nixpkgs as our system.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    base16-vim-mccurdyc = {
      url = "github:mccurdyc/base16-vim";
      flake = false;
    };
  };

  # outputs: A function that, given an attribute set containing the outputs of each
  # of the input flakes keyed by their identifier, yields the Nix values provided
  # by this flake. Thus, in the example above, inputs.nixpkgs contains the result
  # of the call to the outputs function of the nixpkgs flake
  #
  # The value returned by the outputs function must be an attribute set.
  # The attributes can have arbitrary values; however, various nix subcommands
  # require specific attributes to have a specific value (e.g. packages.x86_64-linux
  # must be an attribute set of derivations built for the x86_64-linux platform).
  #
  # Each input is fetched, evaluated and passed to the outputs function as a set
  # of attributes with the same name as the corresponding input.
  #
  # The special input named self refers to the outputs and source tree of this flake.
  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
    # https://nixos.org/manual/nix/stable/language/constructs.html#functions
    # An @-pattern provides a means of referring to the whole value being matched
  } @ inputs: let
    system = "x86_64-linux"; #current system
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    lib = nixpkgs.lib;

    vimPlugins = {
      inherit (inputs) base16-vim-mccurdyc;
    };

    mkSystem = pkgs: system: hostname:
      pkgs.lib.nixosSystem {
        system = system;
        # replaces the older configuration.nix
        modules = [
          {networking.hostName = hostname;}
          # General configuration (users, networking, sound, etc)
          ./modules/system/configuration.nix
          # Hardware config (bootloader, kernel modules, filesystems, etc)
          (./. + "/hosts/${hostname}/hardware-configuration.nix")
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              extraSpecialArgs = {inherit inputs;};
              users.mccurdyc = ./. + "/hosts/${hostname}/user.nix";
            };
          }
          {
            nixpkgs.overlays = [
              (import ./overlays/vim-plugins.nix nixpkgs vimPlugins system)
            ];
          }
        ];
        specialArgs = {inherit inputs;};
      };
  in {
    nixosConfigurations = {
    nuc = mkSystem inputs.nixpkgs "x86_64-linux" "nuc";
    };
  };
}
