---
name: atlassian
description: >
  Interact with Jira and Confluence. Use the Atlassian MCP
  server tools when available, otherwise fall back to the
  jira CLI.
user-invocable: false
---

## MCP tools (Claude, opencode)

If Atlassian MCP tools are available, prefer them:

### Jira
- jira_search — JQL queries (e.g. `summary ~ "X" AND issuetype = Epic`)
- jira_get_issue — fetch a specific issue by key
- jira_create_issue, jira_update_issue — create/edit issues
- jira_get_transitions, jira_transition_issue — workflow transitions
- jira_search_fields, jira_get_field_options — field metadata

### Confluence
- confluence_search — CQL queries
- confluence_get_page — fetch a page by ID

## CLI fallback (pi, or when MCP is unavailable)

Use the `jira` CLI (`jira-cli-go`):

```sh
# Search issues
jira issue list -q "summary ~ 'control cache' AND issuetype = Epic"

# Get a specific issue
jira issue view PROJ-123

# List epics in a project
jira epic list --project PROJ

# Create an issue
jira issue create -t Bug -s "Title" -b "Description" -P PROJ

# Transition an issue
jira issue move PROJ-123 "In Progress"

# Open in browser
jira open PROJ-123
```

Parse user requests and pick the right approach. For
"what's the X epic" → search with JQL or `jira issue list -q`.
