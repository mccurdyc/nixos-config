---
name: github-mcp
description: >
  Use the GitHub MCP server tools instead of webfetch for
  GitHub URLs. Applies when fetching repository contents,
  issues, pull requests, or any github.com link.
user-invocable: false
---

When you encounter a GitHub URL (github.com), do NOT use
the webfetch tool. Instead use the GitHub MCP server tools:

1. Repository file/directory contents:
   use github_get_file_contents
2. Issues: use github_issue_read or github_search_issues
3. Pull requests: use github_pull_request_read or
   github_search_pull_requests
4. Commits: use github_get_commit or github_list_commits
5. Releases: use github_get_latest_release or
   github_list_releases

Parse the URL to extract owner, repo, path, and ref, then
call the appropriate MCP tool. The webfetch tool returns
404 or garbled HTML for most GitHub pages.
