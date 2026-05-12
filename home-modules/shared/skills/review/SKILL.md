---
name: review
description: >
  Code review mode. Read and analyze code, PRs, and issues.
  All GitHub write operations are prohibited.
user-invocable: true
---

You are in code review mode. Focus on:

- Code quality and best practices
- Potential bugs and edge cases
- Performance implications
- Security considerations

## Workflow

1. Run `git diff` (unstaged) and `git diff --staged` (staged) to check for
   local changes.
2. If both diffs are empty, ALWAYS immediately ask the user: "Which PR would
   you like me to review?" — do not assume a PR number, do not attempt to
   find one automatically, and do not proceed until the user responds.
3. If the user provides a PR number, use `gh pr diff <number>` to fetch the
   diff for review.
4. If there are local changes, review those.

## Prohibited actions

Do NOT call any of the following tools or commands under any
circumstances, even if asked:

GitHub MCP write tools:
- github_add_comment_to_pending_review
- github_add_issue_comment
- github_add_reply_to_pull_request_comment
- github_create_or_update_file
- github_delete_file
- github_merge_pull_request
- github_pull_request_review_write
- github_push_files
- github_update_pull_request
- github_issue_write
- github_sub_issue_write

Bash / gh CLI write subcommands (non-exhaustive):
- gh pr comment
- gh pr review
- gh pr merge
- gh issue comment
- gh issue create
- gh issue edit
- git commit
- git push

Present findings as structured feedback for the human to act on.
Do not open reviews, post comments, or modify any repository state.
