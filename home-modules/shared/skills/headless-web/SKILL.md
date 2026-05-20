---
description: Browse the web headlessly using Chrome DevTools Protocol. Use when you need to interact with web pages - click buttons, fill forms, navigate, take screenshots, or extract dynamic content that requires JavaScript.
---

# Web Browser Skill

Minimal CDP tools for collaborative site exploration.

## Quick Start

Run `start.js` — it handles everything automatically:

* Installs `ws` dependency if missing
* Finds Chrome/Chromium across macOS and Linux
* Detects headless-only environments (no `$DISPLAY`)
* Reuses an existing `:9222` instance if one is running

```bash
node ./scripts/start.js              # Fresh profile
node ./scripts/start.js --profile    # Copy your Chrome profile
node ./scripts/start.js --headless   # Force headless mode
```

Override the Chrome binary with `CHROME_PATH`:

```bash
CHROME_PATH=/usr/bin/chromium node ./scripts/start.js
```

## Navigate

```bash
node ./scripts/nav.js https://example.com
node ./scripts/nav.js https://example.com --new
```

Navigate current tab or open new tab.

## Evaluate JavaScript

```bash
node ./scripts/eval.js 'document.title'
node ./scripts/eval.js 'document.querySelectorAll("a").length'
```

Execute JavaScript in active tab (async context). Be careful
with string escaping — best to use single quotes.

## Screenshot

```bash
node ./scripts/screenshot.js
```

Screenshot current viewport, returns temp file path.

## Pick Elements

```bash
node ./scripts/pick.js "Click the submit button"
```

Interactive element picker. Click to select, Cmd/Ctrl+Click
for multi-select, Enter to finish.

## Dismiss Cookie Dialogs

```bash
node ./scripts/dismiss-cookies.js          # Accept
node ./scripts/dismiss-cookies.js --reject # Reject
```

Automatically dismisses EU cookie consent dialogs.

Run after navigating to a page:

```bash
node ./scripts/nav.js https://example.com \
  && node ./scripts/dismiss-cookies.js
```

## Background Logging (Console + Errors + Network)

Automatically started by `start.js` and writes JSONL logs to:

```
~/.cache/agent-web/logs/YYYY-MM-DD/<targetId>.jsonl
```

Manually start:

```bash
node ./scripts/watch.js
```

Tail latest log:

```bash
node ./scripts/logs-tail.js           # dump and exit
node ./scripts/logs-tail.js --follow  # keep following
```

Summarize network responses:

```bash
node ./scripts/net-summary.js
```
