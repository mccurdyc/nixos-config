{ ... }:

{
  imports = [
    ../darwin
    ./packages.nix
    ./pi.nix
    ./secrets.nix
    ./ssh.nix
  ];
}
