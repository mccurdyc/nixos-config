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

The VM test nodes in `tests/` do not go through `lib/mkSystem.nix` and do not
inherit its `nixpkgs.overlays`. They also receive their `pkgs` from the
`perSystem` block in `flake.nix`, which is a separate pkgs instantiation from
the one used by the actual host configurations. Do not use the check commands
to verify that a package is available in pkgs or that an overlay is applied
correctly -- use `nix build '.#nixosConfigurations.<host>.pkgs.<pkg>'` or
`nix build '.#nixosConfigurations.<host>.config.system.build.toplevel' --dry-run`
instead.

## Git

When showing a git diff, use `git diff` for unstaged changes or `git diff HEAD`
if files are staged. Always exclude lock files and other generated files with
large diffs that add no review value:

```sh
git diff -- . ':(exclude)*lock*' ':(exclude)*.lock'
git diff HEAD -- . ':(exclude)*lock*' ':(exclude)*.lock'
```

If a commit fails due to a GPG signing error, retry with `--no-gpg-sign`:

```sh
git commit --no-gpg-sign -m "message"
```

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
- **pi-coding-agent packaged locally**: `@mariozechner/pi-coding-agent` is not
  in nixpkgs and ships no `package-lock.json`. A lock file is generated via
  `npm install --package-lock-only --ignore-scripts` against the published
  tarball and committed to `pkgs/pi-coding-agent/`. The derivation uses
  `buildNpmPackage`. Config is managed via `home-modules/{shared,nuc,work}/pi.nix`.
- **Shared skills across Claude, pi, and opencode**: Skill definitions live in
  `home-modules/shared/skills/<name>/SKILL.md` as a single source of truth.
  Each tool discovers or references them differently:
  - Claude: deployed to `~/.claude/skills/` via `home.file` entries in
    `home-modules/shared/claude/default.nix`.
  - pi: deployed to `~/.pi/agent/skills/` via `home.file` entries in
    `home-modules/shared/pi.nix`.
  - opencode: referenced as a command via `xdg.configFile` in
    `home-modules/shared/opencode.nix`; also auto-discovered from
    `~/.claude/skills/` as a skill.
  Frontmatter uses the Claude schema (`disable-model-invocation`,
  `allowed-tools`). Opencode and pi ignore unknown fields harmlessly.
  Do not create per-tool copies of skill files.
- **First-party MCP servers only**: only use MCP servers published
  by the service vendor (e.g., Google, Atlassian, GitHub) or by the
  MCP project (`modelcontextprotocol` org). Do not adopt third-party
  community MCP servers.
