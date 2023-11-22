# mccurdyc nixos-config

![](./docs/imgs/screenshot.png)

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
- [tfc/nixos-config](https://github.com/tfc/nixos-configs/tree/main)
    - [Nixcademy Nix Training](https://nixcademy.com/)

## References

- [nix-darwin options](https://mynixos.com/options)
    - https://daiderd.com/nix-darwin/manual/index.html
- [nixos options](https://search.nixos.org/options)

## Installation Docs

- [nix-darwin](./docs/nix-darwin-install.md)
- [nixos](./docs/nix-darwin-install.md)
- [shared](./docs/shared.md)

## Common Commands

### faamac Rebuild

```bash
darwin-rebuild switch --flake '.#faamac'
```

### fgnix Rebuild

```bash
sudo nixos-rebuild switch --flake '.#fgnix'
# sudo nixos-rebuild switch --flake 'git+https://github.com/mccurdyc/nixos-config.git#fgnix'
```

### Update Flake

```bash
nix flake update
```

### Formatting

```bash
nix fmt
```

### Testing

#### Automated

```bash
nix build '.#fgnix'
```

#### Interactive (debugging tests)

- https://blog.thalheim.io/2023/01/08/how-to-execute-nixos-tests-interactively-for-debugging/

```bash
nix build '.#packages.x86_64-linux.fgnix.driver'
./result/bin/nixos-test-driver --interactive
(repl) fgnix.start()
(repl) fgnix.shell_interactive()
```
