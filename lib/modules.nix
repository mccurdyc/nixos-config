# Returns a list of modules used by Darwin/NixOS System configurations
# https://nixos.org/manual/nixos/stable/#sec-modularity
# https://nixos.org/manual/nixos/stable/#sec-importing-modules
# https://nixos.wiki/wiki/NixOS_modules
{ name, system, user, profile, nixpkgs, nixpkgs-unstable, home-manager, darwin ? false, additionalModules ? [ ] }:

let
  homeFn =
    if darwin
    then home-manager.darwinModules
    else home-manager.nixosModules;
  pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
  pkgs-unstable = import nixpkgs-unstable { inherit system; };

in

[
  ../machines/${name}.nix
  ../users/${user}/${ if darwin then "darwin" else "nixos" }.nix

  homeFn.home-manager
  {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${user} = import ../users/${user}/home-manager.nix {
        inherit pkgs profile;
      };

      # passed to every `home-module`.
      extraSpecialArgs = {
        currentSystem = system;
        currentSystemName = name;
        inherit pkgs-unstable profile darwin;
      };
    };
  }

  # passed to every module
  {
    config._module.args = {
      currentSystem = system;
      currentSystemName = name;
      inherit pkgs-unstable profile;
    };
  }
]
++ [
  ../modules/environment.nix
  ../modules/nix.nix
  ../modules/zsh.nix
]
++ additionalModules
++ (
  if darwin
  then [
    ../modules/yabai.nix
    ../modules/skhd.nix
  ]
  # TODO - move these to include the darwin conditional in each module
  else [
    ../modules/networking.nix
    ../modules/misc.nix
    ../modules/fonts.nix
    ../modules/openssh.nix
  ]
)
