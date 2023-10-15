
## Inspiration

- [MatthiasBenaets/nixos-config](https://github.com/MatthiasBenaets/nixos-config/tree/76eea152f56e1a8f4c908b65028e8aa2f7bafaaa)
    - [For Mac](https://github.com/MatthiasBenaets/nixos-config/blob/76eea152f56e1a8f4c908b65028e8aa2f7bafaaa/README.org#nix-darwin-installation-guide)
- [cors/nixos-config](https://github.com/cor/nixos-config/blob/3156d0ca560a8561187b0f4ab3cb25bbbb4ddc9f/flake.nix#L62)
    - Shared modules
- [mitchellh/nixos-config](https://github.com/mitchellh/nixos-config)
    - Single `lib/mkSystem.nix` shared across nixos and nix-darwin
- [phamann/nixos-config](https://github.com/phamann/nixos-config)
- [notusknot/dotfiles-nix](https://github.com/notusknot/dotfiles-nix)
- [kclejeune/system](https://github.com/kclejeune/system)

## Installation Docs

- [nix-darwin](./docs/nix-darwin-install.md)
- [nixos](./docs/nix-darwin-install.md)
- [shared](./docs/shared.md)

## Common Commands

### faamac Rebuild

```bash
NIXPKGS_ALLOW_UNFREE=1 darwin-rebuild switch --impure --flake '.#faamac'
```

### fgnix Rebuild

```bash
sudo nixos-rebuild switch --upgrade --flake '.#fgnix'
```

### Update Flake

```bash
nix flake update
```

### Formatting

```bash
nix fmt
```
