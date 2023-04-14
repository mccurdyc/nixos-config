# NOTES

These are notes on things that I always forget how to do.

## Rebuild

```bash
sudo nixos-rebuild switch --flake '.#fgnix'
```

## Making ZSH / shell changes

You need to fully reload the shell i.e., kill tmux (shouldn't need to), not just close and open a new tmux pane.

TODO - look into this. Stop being lazy and putting up with this crap.

## Install a Nvim plugin via Lazy

NixOS is a read-only filesystem, so I've overriden my `lazy-lock.json` path to
be in my home directory. I check in my `lazy-lock.json` file to `modules/nvim/lazy-lock.json`
which, by default gets written to my home directory and therefore, Nix is the owner
of this file, hence why I have to delete it.

```bash
rm -rf /home/mccurdyc/lazy-lock.json modules/nvim/lazy-lock.json && \
  nvim --headless "+Lazy! sync" +qa && \
  cp /home/mccurdyc/lazy-lock.json modules/nvim/lazy-lock.json && \
  sudo nixos-rebuild switch --flake '.#fgnix'
```

## Install missing Treesitter parser

Again, can't do things automatically because it is a RO filesystem.

```bash
:TSInstall <lang>
```

## Debugging vim Dap

Plugins:

- <https://github.com/mfussenegger/nvim-dap> - Dap Nvim pluging for interacting with Delve binary.
  - The Vim keymaps for debugging
- <https://github.com/rcarriga/nvim-dap-ui> - A clean debugger UI in Nvim
- <https://github.com/leoluz/nvim-dap-go> - Configuration params for Go
  - Launch delve automatically from Vim

- <https://github.com/go-delve/delve> - Delve the binary (not a Vim plugin)

1. `:lua require("dap").toggle_breakpoint()`
1. `:lua require("dapui").open()`
1. `:lua require("dapui").setup()`
1. `:lua require('dap-go').debug_test()`

- `:help dap-mapping`

1. `:lua require('dap').step_over()` - (same as "next")
1. `:lua require('dap').step_into()`
1. `:lua require('dap').continue()`
