---
description: Search the web, fetch web page content, or search GitHub issues/PRs/repos. Use when you need current information not available locally.
---

# Web Search

Three CLI tools are available for web access. No API keys or servers required.

## Tools

### `ddgr` — Web Search (DuckDuckGo)

Search the web for current information.

```bash
ddgr --json --np -n 5 "your search query"
```

**Flags:**
- `--json` — JSON output (title, URL, abstract per result)
- `--np` — non-interactive (no prompt, exits after results)
- `-n N` — number of results (default 10)
- `--time=w` — limit to past week (`d` day, `m` month, `y` year)

**When to use:**
- Current events, news, recent releases
- Documentation, API references, package info
- Error messages or troubleshooting
- Any question requiring info beyond your training data

**Tips:**
- Be specific: `"nix flake-parts perSystem"` not `"nix help"`
- Use site scoping: `"site:docs.github.com actions workflow"`
- Start with 5 results, expand if needed

### `readable` — Fetch & Extract Web Content

Extract clean readable text from a URL (Mozilla Readability).

```bash
readable "https://example.com/article" 2>/dev/null
```

**Flags:**
- `--json` — JSON output with title, byline, content, excerpt
- `--low-confidence=force` — extract even if confidence is low
- `--properties=text-content` — plain text only (no HTML)

**When to use:**
- Reading a specific page (docs, blog, README, changelog)
- Following up on a URL from search results
- User shares a URL and asks about its content

**Tips:**
- Pipe to head for long pages: `readable "URL" 2>/dev/null | head -200`
- Use `--properties=text-content` for cleaner LLM input
- Redirect stderr to suppress warnings: `2>/dev/null`

### `gh` — GitHub Search

Search GitHub issues, PRs, repos, and code.

```bash
# Search issues
gh search issues "memory leak" --repo owner/repo --limit 5

# Search PRs
gh search prs "fix timeout" --repo owner/repo --limit 5

# Search repos
gh search repos "nix flake-parts" --limit 5

# Search code
gh search code "function name" --repo owner/repo

# View a specific issue/PR
gh issue view 123 --repo owner/repo
gh pr view 456 --repo owner/repo
```

**When to use:**
- Finding issues, bugs, or feature requests
- Looking up PRs (open, closed, merged)
- Discovering repositories
- Reading specific issue/PR discussions

**Tips:**
- Add `--state=open` or `--state=closed` to filter
- Use `--json title,url,body` for structured output
- Combine with labels: `--label bug`
- For full issue body: `gh issue view N --repo owner/repo --comments`

## Workflow

1. **Start broad**: `ddgr` to find relevant URLs
2. **Go deep**: `readable` to extract full content from promising results
3. **GitHub-specific**: Use `gh` directly for issues/PRs/repos — faster and more structured than web search
