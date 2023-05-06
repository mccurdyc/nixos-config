# ZSH / shell

## reloading

You need to fully reload the shell i.e., kill tmux (shouldn't need to), not just close and open a new tmux pane.
TODO - look into this. Stop being lazy and putting up with this crap.

- <https://unix.stackexchange.com/a/320496>

## why does tmux launch with 0,1 windows?

# vim

## lazy.nvim

- use keymap support - <https://github.com/folke/lazy.nvim#%EF%B8%8F-lazy-key-mappings>
- actually clean up plugins a bit and leverage features of lazy

## go

- <https://github.com/Integralist/nvim/blob/f0392f6b1360bd6d1e5d17aceb7beee50e4fe966/lua/plugins/lsp.lua#L157-L160>
- <https://github.com/Integralist/nvim/blob/f0392f6b1360bd6d1e5d17aceb7beee50e4fe966/lua/plugins/lsp.lua#L10-L91>
- <https://github.com/Integralist/nvim/blob/main/lua/plugins/null-ls.lua#L15>
- <https://github.com/Integralist/nvim/blob/main/lua/plugins/null-ls.lua#L21>
- <https://github.com/Integralist/nvim/blob/main/lua/plugins/null-ls.lua#L28>
- <https://github.com/Integralist/nvim/blob/main/lua/plugins/lsp.lua#L65-L74>
- read through more of <https://github.com/ray-x/go.nvim> readme
- run :GoTest async (not on save)

# Sync repos

I want to have a single yaml file with a list of repos to keep up to date on a daily
basis. I wouldn't mind running the tool manually / cron job daily.
I want the yaml file to be the source of truth. If a repo is deleted from the yaml
file, it should be removed from filesystem and vice versa. I don't want a tool
that does things to multiple repos.

My proposed name would be `g2rs` - like "git repos" or "git repo management tool,
written in rust". And one of my favorite cars is a porsche gt2rs.

- <http://myrepos.branchable.com/>
- <https://github.com/orf/git-workspace#define-your-workspace>
  - clones all repos owned by a user or org. Expects you to exclude.
    - I want to specify the repos I want to clone, not the exclusions.
    - <https://github.com/orf/git-workspace/issues/171>
  - Rust
  - nix package
  - supports config
  - supports cloning if not exist locally
  - supports delete via `archive` command. moves to an `.archived` dir when deleted
    - might ask if they be interested in a `--delete` flag to the archive command,
    or a separate `rm` command that hard removes.
  - if you run a cli command to `add`, updates config
  - decent UI
- <https://github.com/x-motemen/ghq>
  - I like the path management
  - interface isn't great
  - Go
- <https://github.com/isacikgoz/gitbatch>
  - Go
  - Perfect UI
  - Almost perfect! Just no way to cleanup a repo
- <https://github.com/nosarthur/gita>
  - Python
  - good cli interface `gita add` and `gita rm`
  - `gita rm` doesnt remove files from disk...
- <https://davvid.github.io/garden>
  - rust
  - <https://davvid.github.io/garden/configuration.html>
  - declarative YAML config file
  - does a lot more than I need
  - not a fan of the cutesy naming
  - does it clean up a repo?
    - `garden prune`
  - doesn't have a simple, built-in command for syncing.
- <https://github.com/nickgerace/gfold>
  - Rust. Good learning op / contributing
  - nix package
  - doesnt use a config file. just traverses a path on the fs
- <https://github.com/alajmo/mani>
