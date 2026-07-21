{ ... }:

{
  # Determinate Nix manages the daemon, gc, and settings — disable nix-darwin's nix module.
  nix.enable = false;
}
