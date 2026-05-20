---
name: diff-here
description: >
  Show git diff output inline in the conversation without opening a browser.
  Covers staged, unstaged, and untracked files.
user-invocable: true
allowed-tools: bash
---

# Inline Git Diff

Show working changes directly in the conversation — no browser, no diff2html.

## Steps

1. **Show the diff inline.**
   Run `git diff HEAD -- . ':(exclude)*lock*' ':(exclude)*.lock'` to show
   staged + unstaged changes (excluding lock files).
   If nothing is committed yet (initial commit), use `git diff --cached`.
   Also run `git ls-files --others --exclude-standard` to list untracked files.

2. **Present a summary** of the changes: what was added, modified, deleted,
   and any new untracked files.

3. **Ask the user**: "Do you want to commit and push these changes?"
   Never offer to commit without pushing — commit always means commit AND push.
   - If **yes**: stage all changes (`git add -A`), generate a Conventional
     Commits message (type(scope): summary, <= 72 chars), commit, and push.
     If the commit fails due to a GPG signing error, retry with
     `git commit --no-gpg-sign -m "<message>"`.
   - If **no**: stop.
