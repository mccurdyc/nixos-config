---
name: git-worktree
description: >
  Do work in an isolated git worktree instead of switching branches.
  Use when creating a branch and opening a PR so the user's working
  directory is never disturbed. Triggers: 'create a branch', 'open a PR',
  'make a change on a new branch'.
user-invocable: false
allowed-tools: bash, edit, write, read, grep, find, ls
---

# Git Worktree Workflow

Use git worktrees to isolate branch work from the user's current checkout.
This avoids disrupting uncommitted changes or the user's active branch.

## Shell helpers available

- `gw <name> [base]` — create worktree at `.git-worktrees/<name>` branching
  from `base` (default: `origin/main`). Copies `.envrc` and shares direnv cache.
- `gwl` — list active worktrees.
- `gwd <name>` — cd into an existing worktree.
- `gw-clean` — remove merged worktrees.

## Steps

1. **Create the worktree** from `origin/main` (unless told otherwise):
   ```sh
   git fetch origin main
   gw <branch-name>
   ```
   This creates `.git-worktrees/<branch-name>` with a new branch of the same name.

2. **Change into the worktree directory**:
   ```sh
   cd .git-worktrees/<branch-name>
   ```

3. **Do all work inside the worktree** — edits, commits, pushes, PR creation
   all happen in this directory. The user's main checkout is untouched.

4. **After the PR is opened**, return to the original directory:
   ```sh
   cd -
   ```
   The worktree stays on disk for future updates. Tell the user they can
   clean it up later with `gw-clean` or manually remove it.

## When to use

- The user asks to "create a branch and open a PR" or similar.
- The user has uncommitted work and wants to make changes on a separate branch.
- Any time branch isolation is beneficial.

## When NOT to use

- The user explicitly says to use the current branch.
- The user says "don't use a worktree" or "just switch branches".
- Quick edits on the current branch that don't need a PR.
