---
name: atlassian
description: >
  Interact with Jira and Confluence. Use the Atlassian MCP
  server tools when available, otherwise fall back to the
  jira CLI.
user-invocable: false
---

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
