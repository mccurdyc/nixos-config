---
name: atlassian
description: >
  Interact with Jira and Confluence. Use the Atlassian MCP
  server tools when available, otherwise fall back to the
  jira CLI.
user-invocable: false
---

## Ticket ID detection

Any reference matching the pattern `[A-Za-z]{2,4}-\d+` (2–4 letters, a dash,
then one or more digits — e.g. CP-78, cp-78, ENG-1234, abcd-5) is a **Jira
issue key**. When the user mentions one of these:

1. **Always** treat it as a Jira issue — never as a GitHub issue.
2. Normalize to uppercase before passing to Jira (e.g. `cp-78` → `CP-78`).
3. Use the MCP `jira_get_issue` / `jira_update_issue` tools (or CLI fallback)
   to interact with it.
4. If the user says "add a comment to cp-78", use Jira comment tools — do
   NOT use `gh issue comment`.

GitHub issues are referenced with a bare `#78` (hash prefix, no letters).
A letter-prefix like `CP-78` or `cp-78` is **never** a GitHub issue.

## URL parsing

When given an Atlassian URL, extract identifiers directly:

- **Confluence page:** `https://fastly.atlassian.net/wiki/spaces/.../pages/<PAGE_ID>/...` → use page ID with `confluence_get_page`
- **Jira issue:** `https://fastly.atlassian.net/browse/PROJ-123` → use key with `jira_get_issue`

## MCP tools (preferred)

### Confluence
- `confluence_get_page` — fetch a page by ID
- `confluence_search` — CQL queries (e.g. `title = "Varnishlog"`)

### Jira
- `jira_get_issue` — fetch by key (e.g. PROJ-123)
- `jira_search` — JQL queries (e.g. `summary ~ "X" AND issuetype = Epic`)
- `jira_create_issue`, `jira_update_issue` — create/edit issues
- `jira_get_transitions`, `jira_transition_issue` — workflow transitions

## CLI fallback (when MCP is unavailable)

Use the `jira` CLI (`jira-cli-go`):

```sh
jira issue list -q "summary ~ 'control cache' AND issuetype = Epic"
jira issue view PROJ-123
jira epic list --project PROJ
jira issue create -t Bug -s "Title" -b "Description" -P PROJ
jira issue move PROJ-123 "In Progress"
```
