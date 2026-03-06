# nixos-config

Personal NixOS/nix-darwin flake. Single user: `mccurdyc`.

## Hosts

| Name   | System         | Type              | Apply command                                  | Check command                                       |
|--------|----------------|-------------------|------------------------------------------------|-----------------------------------------------------|
| fgnix  | x86_64-linux   | GCE VM            | `sudo nixos-rebuild switch --flake '.#fgnix'`  | `nix build '.#checks.x86_64-linux.fgnix'`           |
| nuc    | x86_64-linux   | Intel NUC         | `sudo nixos-rebuild switch --flake '.#nuc'`    | `nix build '.#checks.x86_64-linux.nuc'`             |
| faamac | aarch64-darwin | Apple Silicon Mac | `darwin-rebuild switch --flake '.#faamac'`     | `nix build '.#checks.aarch64-darwin.faamac'`        |
| funix  | x86_64-linux   | Work VM           | `home-manager switch --flake '.#funix'`        | `nix build '.#checks.x86_64-linux.funix'`           |

fgnix and nuc run full `pkgs.testers.runNixOSTest` VM tests. faamac and funix
are eval-only; building the activation package confirms the config evaluates.
Hardware modules are excluded from tests; the VM framework supplies its own
root filesystem and bootloader.

## Formatting and Linting

```sh
nix fmt            # nixpkgs-fmt
statix check .     # lint
deadnix .          # find dead code
```

## Conventions

- `nixpkgs` tracks `nixos-unstable`; `flake-parts` structures outputs.
- `home-manager` uses `useGlobalPkgs = true` and
  `useUserPackages = true`.
- `allowUnfree = true` and `allowBroken = true` globally.
- `specialArgs` (`user`, `hashedPassword`, `zshPath`) are passed to
  every module via `extraSpecialArgs`.
- Prefer `{ ... }:` module signatures when args are unused.
- System-level concerns go in `modules/nixos/` or `modules/darwin/`.
- Shared home-manager concerns go in `home-modules/shared/`.
- Host-specific home-manager overrides go in `home-modules/<host>/`.
- Hardware config (filesystems, boot loader) belongs only in
  `hosts/hardware/`, never in logic modules.

## Decisions

- **opencode.nix not imported in shared/default.nix**: intentional --
  opencode config is per-host since not all hosts run it the same way.
- **funix uses home-manager only**: Work-managed machine; NixOS
  cannot be installed on it.
- **`allowBroken = true`**: required for ghostty; not a general policy.
- **`autoupdate = true` in opencode**: accepted; opencode is installed
  outside Nix via its own updater on hosts that use it.
