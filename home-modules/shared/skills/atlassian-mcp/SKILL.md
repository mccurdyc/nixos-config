---
name: atlassian-mcp
description: >
  Use the Atlassian MCP server tools for Jira and Confluence
  queries. Applies when searching issues, reading epics,
  transitioning tickets, or fetching Confluence pages.
user-invocable: false
---

When you need to interact with Jira or Confluence, use the
Atlassian MCP server tools instead of webfetch or guessing:

## Jira

1. Search issues/epics: use jira_search (JQL queries)
2. Get a specific issue: use jira_get_issue
3. Create an issue: use jira_create_issue
4. Update an issue: use jira_update_issue
5. Get available transitions: use jira_get_transitions
6. Transition an issue: use jira_transition_issue
7. Search for fields: use jira_search_fields
8. Get field options: use jira_get_field_options

## Confluence

1. Search pages: use confluence_search (CQL queries)
2. Get a specific page: use confluence_get_page

Parse user requests to determine the appropriate tool. For
example, "what's the X epic" → jira_search with a JQL query
like `summary ~ "X" AND issuetype = Epic`.
