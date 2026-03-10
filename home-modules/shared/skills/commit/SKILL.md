---
name: commit
description: >
  Generate a Conventional Commits message and commit staged
  changes. Use when the user asks to commit changes.
disable-model-invocation: true
allowed-tools: Bash
---

Generate a git commit message and commit the changes.

1. Run `git diff --staged -- . ':(exclude)*lock*' ':(exclude)*.lock'`
   to see staged changes. If nothing is staged, run
   `git diff -- . ':(exclude)*lock*' ':(exclude)*.lock'` instead.
2. Read surrounding code only when the diff is unclear.
3. Write a commit message following Conventional Commits
   (type(scope): summary). Summary line must be <= 72 chars.
   Add a body only when the "why" is not obvious from the summary.
4. Run `git commit -m "<message>"`.
   If the commit fails due to a GPG signing error, retry with
   `git commit --no-gpg-sign -m "<message>"`.
