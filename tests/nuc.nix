# NixOS VM test for the nuc host configuration.
#
# Imports the logical host config and shared modules without any hardware-specific
# modules (no fileSystems, no boot-loader declarations). The VM test framework
# supplies its own root filesystem and bootloader.
#
# Run with:
#   nix build '.#checks.x86_64-linux.nuc'
{ pkgs, home-manager, specialArgs }:

pkgs.testers.runNixOSTest {
  name = "nuc";

  nodes.nuc = { lib, ... }: {
    imports = [
      # Host-specific logical config (no hardware import).
      ../hosts/nuc

      # Shared NixOS modules.
      ../modules/nixos

      # Home-manager wiring.
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = specialArgs // { inherit home-manager; };
        home-manager.users.${specialArgs.user} = import ../home-modules/nuc;
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
    nuc.start()
    nuc.wait_for_unit("multi-user.target")

    # nftables should be loaded and the docker-nat table present.
    nuc.succeed("nft list tables | grep -q docker-nat")
  '';
}
