{pkgs}:
let nixos-lib = import (pkgs + "/nixos/lib") { };
in

nixos-lib.runTest {
  imports = [ ./test.nix ];
  hostPkgs = pkgs;  # the Nixpkgs package set used outside the VMs
  defaults.services.foo.package = mypkg;
}
