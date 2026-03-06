# NixOS VM test for the fgnix host configuration.
#
# Imports the logical host config and shared modules without any hardware-specific
# modules (no fileSystems, no boot-loader declarations). The VM test framework
# supplies its own root filesystem and bootloader.
#
# Run with:
#   nix build '.#checks.x86_64-linux.fgnix'
{ pkgs, home-manager, specialArgs }:

pkgs.testers.runNixOSTest {
  name = "fgnix";

  nodes.fgnix = { lib, ... }: {
    imports = [
      # Host-specific logical config (no hardware import).
      ../hosts/fgnix

      # Shared NixOS modules.
      ../modules/nixos

      # Home-manager wiring.
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = specialArgs // { inherit home-manager; };
        home-manager.users.${specialArgs.user} = import ../home-modules/fgnix;
      }
    ];

    # Pass specialArgs values as module args so modules that expect them work.
    _module.args = specialArgs;

    # Suppress services that require real hardware or external network auth --
    # they are not under test and add unnecessary build cost.
    # mkOverride 0 beats the mkForce (mkOverride 50) in docs.nix.
    services.xserver.enable = lib.mkForce false;
    documentation.nixos.enable = lib.mkOverride 0 false;
  };

  testScript = ''
    fgnix.start()
    fgnix.wait_for_unit("multi-user.target")

    # nftables should be loaded and the docker-nat table present.
    fgnix.succeed("nft list tables | grep -q docker-nat")
  '';
}
