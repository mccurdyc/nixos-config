---
name: git-diff
description: >
  Review all working changes (staged, unstaged, and untracked) with
  a browser-based diff view. Offer to commit and push when done.
user-invocable: true
allowed-tools: browser_diff
---

# Git Diff Review

Open a visual, side-by-side diff in the browser using diff2html.

## Steps

1. **Open diff in browser.**
   Use the `browser_diff` tool with args `HEAD`.
   If nothing is committed yet (initial commit), use args `--cached`.
   (Untracked files and lock-file exclusions are handled automatically.)

2. **Present a summary** of the changes: what was added, modified, deleted,
   and any new untracked files.

3. **Ask the user**: "Do you want to commit and push these changes?"
   - If **yes**: stage all changes (`git add -A`), generate a Conventional
     Commits message (type(scope): summary, <= 72 chars), commit, and push.
     If the commit fails due to a GPG signing error, retry with
     `git commit --no-gpg-sign -m "<message>"`.
   - If **no**: stop.
