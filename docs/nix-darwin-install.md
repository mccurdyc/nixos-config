# Getting Started on macOS (from scratch)

Complete guide to bootstrapping a new macOS machine with this nix-darwin flake.

## Prerequisites

- macOS (Apple Silicon or Intel)
- Admin access (sudo)

## Steps

### 1. Install Nix (Determinate)

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Determinate Nix enables flakes and the `nix` command by default — no extra configuration needed.

After installation completes, open a new terminal to pick up the Nix environment.

### 2. Clone this repo

```bash
nix-env -iA nixpkgs.git
git clone https://github.com/mccurdyc/nixos-config ~/.config/nixos-config
cd ~/.config/nixos-config
```

### 3. First build

Pick your hostname from the table in the README (e.g., `paamac`, `faamac`).

```bash
sudo NIXPKGS_ALLOW_UNFREE=1 \
  HOME=/var/root \
  NIX_SSL_CERT_FILE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt \
  nix build --extra-experimental-features 'nix-command flakes' --impure \
    '.#darwinConfigurations.<hostname>.system'
```

### 4. Activate

```bash
export NIXPKGS_ALLOW_UNFREE=1
./result/sw/bin/darwin-rebuild switch --impure --flake '.#<hostname>'
rm -rf result
```

After activation, close and reopen your terminal to pick up the new shell environment.

## Day-to-day rebuilds

```bash
darwin-rebuild switch --flake '.#<hostname>'
```

If you hit unfree package errors:

```bash
NIXPKGS_ALLOW_UNFREE=1 darwin-rebuild switch --impure --flake '.#<hostname>'
```

## Troubleshooting

### "error: file 'nixpkgs' was not found in the Nix search path"

Ensure you installed Nix via Determinate (flakes are enabled by default) and restart your terminal.

### Build fails with SSL certificate error

Make sure `NIX_SSL_CERT_FILE` is set correctly on the first build (see step 3).

### GUI apps not appearing in Spotlight

Known nix-darwin limitation. See: https://github.com/LnL7/nix-darwin/issues/139
