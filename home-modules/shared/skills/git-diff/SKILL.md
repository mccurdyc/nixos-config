---
name: git-diff
description: >
  Review all working changes (staged, unstaged, and untracked) with
  color-highlighted diffs. Offer to commit and push when done.
user-invocable: true
allowed-tools: git_diffstat, git_diff
---

# Git Diff Review

Show a complete, color-highlighted review of all working changes.

Prefer the `git_diffstat` and `git_diff` tools over raw bash — they
render with themed colors in the TUI. Lock files are excluded
automatically by those tools.

## Steps

1. **Show diffstat overview.**
   Use the `git_diffstat` tool with args `HEAD`.
   (Untracked files are included automatically by the tool.)

2. **Show full diff.**
   Use the `git_diff` tool with args `HEAD`.
   If nothing is committed yet (initial commit), use args `--cached`.
   (Untracked files are included automatically by the tool.)

3. **Present a summary** of the changes: what was added, modified, deleted,
   and any new untracked files.

4. **Ask the user**: "Do you want to commit and push these changes?"
   - If **yes**: stage all changes (`git add -A`), generate a Conventional
     Commits message (type(scope): summary, <= 72 chars), commit, and push.
     If the commit fails due to a GPG signing error, retry with
     `git commit --no-gpg-sign -m "<message>"`.
   - If **no**: stop.
