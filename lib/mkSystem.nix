{ pkgs, pkgs-unstable, config, nix-darwin, home-manager, lib, }:

{ name, system, user, profile, darwin ? false, }:

let
  # NixOS vs nix-darwin functions
  systemFn =
    if darwin
    then nix-darwin.lib.darwinSystem
    else pkgs.lib.nixosSystem;
  homeFn =
    if darwin
    then home-manager.darwinModules
    else home-manager.nixosModules;
in

systemFn {
  inherit system;

  modules =
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
            inherit darwin profile;
          };
        };
      }

      # passed to every module
      {
        config._module.args = {
          inherit lib profile;
          currentSystem = system;
          currentSystemName = name;
          currentSystemUser = user;
          pkgs-unstable = import pkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };
      }
    ]
    ++ [
      ../modules/environment.nix
      ../modules/nix.nix
      ../modules/zsh.nix
    ]
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
        ../modules/nixpkgs.nix
        ../modules/openssh.nix
      ]
    );
}
