# Nix-Darwin Install Guide

## Inspiration

- [MatthiasBenaets/nixos-config](https://github.com/MatthiasBenaets/nixos-config/tree/76eea152f56e1a8f4c908b65028e8aa2f7bafaaa#nix-darwin-installation-guide)

## Steps

1. Install Nix

    ```bash
    sh <(curl -L https://nixos.org/nix/install)
    ```

    ```bash
    mkdir ~/.config/nix
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
    ```

1. Clone nixos-config repo

    ```bash
    nix-env -iA nixpkgs.git
    git clone https://github.com/mccurdyc/nixos-config ~/.config/nixos-config
    cd ~/.config/nixos-config
    ```

1. Rebuild

    ```bash
    sudo NIXPKGS_ALLOW_UNFREE=1 \
    HOME=/var/root NIX_SSL_CERT_FILE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt \
    nix build --extra-experimental-features 'nix-command flakes' --impure '.#darwinConfigurations.faamac.system'
    ```

    Activate

    ```bash
    export NIXPKGS_ALLOW_UNFREE=1; /result/sw/bin/darwin-rebuild switch --impure --flake '.#faamac'
    rm -rf result
    ```

1. Start tailscale daemon

    ```bash
    sudo tailscaled install-system-daemon
    tailscale login
    ```

## Common Commands

### Rebuilding System

```zsh
NIXPKGS_ALLOW_UNFREE=1 darwin-rebuild switch --impure --flake '.#faamac'
```

## Open Questions

- GUI Apps - https://github.com/LnL7/nix-darwin/issues/139#issuecomment-666771621

