# NixOS Tests

## Building NixOS Configuration

Just to see what is produced

```bash
nixos-rebuild build '.#<machine>'
```

## Tests

```bash
nix build '.#packages.default'
```
