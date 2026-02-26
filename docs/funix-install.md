# funix Install Guide

Standalone home-manager on a GCP Ubuntu VM (not NixOS).

## Fresh Install

1. Install Nix (multi-user)

    ```bash
    sh <(curl -L https://nixos.org/nix/install) --daemon
    ```

    Restart your shell or source the daemon profile:

    ```bash
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    ```

2. Enable flakes

    ```bash
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" \
      >> ~/.config/nix/nix.conf
    ```

    Restart the nix-daemon so it picks up the new config:

    ```bash
    sudo systemctl restart nix-daemon
    ```

3. Clone this repo

    ```bash
    git clone https://github.com/mccurdyc/nixos-config \
      ~/.config/nixos-config
    cd ~/.config/nixos-config
    ```

4. Run home-manager switch via `nix run`

    ```bash
    nix run home-manager/release-25.11 -- \
      switch --flake '.#funix'
    ```

    After the first run, `programs.home-manager.enable = true`
    puts `home-manager` on your PATH. Subsequent rebuilds:

    ```bash
    home-manager switch --flake '.#funix'
    ```

## Existing Multi-User Nix Install

If Nix is already installed in multi-user (daemon) mode, verify
it's running:

```bash
nix --version
systemctl status nix-daemon
```

1. Enable flakes (if not already)

    Check if flakes are enabled:

    ```bash
    grep experimental-features ~/.config/nix/nix.conf
    ```

    If missing:

    ```bash
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" \
      >> ~/.config/nix/nix.conf
    sudo systemctl restart nix-daemon
    ```

2. Clone this repo

    ```bash
    git clone https://github.com/mccurdyc/nixos-config \
      ~/.config/nixos-config
    cd ~/.config/nixos-config
    ```

3. Run home-manager switch via `nix run`

    ```bash
    nix run home-manager/release-25.11 -- \
      switch --flake '.#funix'
    ```

    Subsequent rebuilds:

    ```bash
    home-manager switch --flake '.#funix'
    ```
