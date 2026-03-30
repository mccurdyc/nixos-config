---
name: google-workspace
user-invocable: true
---

# Google Workspace CLI (`gws`)

Use the `gws` CLI to interact with Google Workspace services. All output is
structured JSON. Do NOT use webfetch for Google Workspace URLs — use `gws`.

## Command syntax

    gws <service> <resource> <method> [--params '{}'] [--json '{}']
    gws <service> +<helper> [flags]

## Common services & helpers

| Task | Command |
|------|---------|
| List today's calendar | `gws calendar +agenda` |
| Create calendar event | `gws calendar +insert --params '{"summary":"...", "start":"...", "end":"..."}'` |
| Send email | `gws gmail +send --params '{"to":"...","subject":"...","body":"..."}'` |
| Reply to email | `gws gmail +reply --params '{"messageId":"...","body":"..."}'` |
| Search email | `gws gmail messages list --params '{"q":"...","maxResults":10}'` |
| Read email | `gws gmail messages get --params '{"id":"...","format":"full"}'` |
| Triage inbox | `gws gmail +triage` |
| List Drive files | `gws drive files list --params '{"q":"...","pageSize":10}'` |
| Upload to Drive | `gws drive +upload --upload ./file.pdf` |
| Read spreadsheet | `gws sheets +read --params '{"spreadsheetId":"...","range":"Sheet1!A1:D10"}'` |
| Append to spreadsheet | `gws sheets +append --params '{"spreadsheetId":"...","range":"...","values":[["a","b"]]}'` |
| Write to doc | `gws docs +write --params '{"documentId":"...","text":"..."}'` |
| Send chat message | `gws chat +send --params '{"space":"...","text":"..."}'` |
| List tasks | `gws tasks tasklists list` |
| Search contacts | `gws people connections list --params '{"personFields":"names,emailAddresses"}'` |

## Useful flags

- `--dry-run` — show the API request without executing
- `--page-all` — auto-paginate through all results
- `--page-limit N` — limit pagination to N pages
- `--params '{}'` — URL/query parameters (JSON)
- `--json '{}'` — request body (JSON)

## Discovering APIs

If unsure of available resources/methods for a service:

    gws schema list                    # list all services
    gws schema get --params '{"api":"calendar"}'  # show calendar API schema

## Notes

- All responses are JSON. Parse with jq if needed.
- For paginated results, use `--page-all` or `--page-limit`.
- Exit codes: 0=success, 1=API error, 2=auth error, 3=validation error.
- Auth is pre-configured via `gws auth login`. Do not attempt auth setup.
