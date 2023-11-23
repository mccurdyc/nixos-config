# A function that returns a function that returns a darwin/nixos system configuration.
{ nixpkgs, nixpkgs-unstable, nix-darwin, home-manager }:

{ name, system, user, profile, darwin ? false, additionalModules ? [ ] }:

let
  systemFn =
    if darwin
    then nix-darwin.lib.darwinSystem
    else nixpkgs.lib.nixosSystem;

in
systemFn {
  inherit system;
  modules = import ./modules.nix {
    inherit nixpkgs nixpkgs-unstable name system user profile home-manager darwin additionalModules;
  };
}
