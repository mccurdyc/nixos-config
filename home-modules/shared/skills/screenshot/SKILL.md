---
name: screenshot
description: >
  Take a screenshot of a running web application using Playwright and Chromium.
  Offers to attach the screenshot as a PR comment.
user-invocable: true
---

# Screenshot Skill

Take a screenshot of a locally running web application.

## Workflow

1. **Ask if the local dev environment is already running.**
   - If yes, ask for the URL (default: `http://localhost:3000`).
   - If no, ask the user how to start it, then run the provided command and
     wait for the server to be ready before proceeding.

2. **Install Playwright and Chromium to a temp directory.**

   ```bash
   npm install --prefix /tmp/pw playwright
   npx --prefix /tmp/pw playwright install chromium
   ```

3. **Take the screenshot with a Node.js script using the Playwright API.**

   Write a script (e.g., `/tmp/pw/screenshot.mjs`):

   ```javascript
   import { chromium } from '/tmp/pw/node_modules/playwright/index.mjs';

   const url = process.argv[2] || 'http://localhost:3000';
   const outputPath = process.argv[3] || 'screenshot.png';

   const browser = await chromium.launch();
   const page = await browser.newPage({ viewport: { width: 1600, height: 900 } });
   await page.goto(url, { waitUntil: 'networkidle' });
   await page.waitForTimeout(8000); // extra wait for JS-heavy apps (dashboards, SPAs)
   await page.screenshot({ path: outputPath, fullPage: true });
   await browser.close();
   ```

   Run it:

   ```bash
   node /tmp/pw/screenshot.mjs "<URL>" screenshot.png
   ```

   **Adjust wait time and viewport as needed:**
   - For simple apps, reduce `waitForTimeout` to 2000–3000ms.
   - For dashboards (Grafana, etc.), keep 8000ms or more so panels finish
     fetching data and rendering.
   - If the user requests a specific viewport, change the `width`/`height`.
   - If the user wants a specific element, use `page.locator('selector').screenshot()`
     instead of full-page.

4. **Show the screenshot to the user** using the read tool on the resulting
   PNG file so they can verify it.

5. **Ask if the user wants the screenshot added as a comment on the current
   pull request.**
   - If yes, determine the current PR number:
     ```bash
     gh pr view --json number -q .number
     ```
   - Commit the screenshot to the branch and push, then comment with an image
     reference:
     ```bash
     git add screenshot.png
     git commit --no-gpg-sign -m "docs: add screenshot"
     git push
     gh pr comment <number> --body "## Screenshot\n\n![screenshot](screenshot.png)"
     ```
   - Alternatively, if the user prefers not to commit the file to the repo,
     upload it externally and reference the URL in the comment.

## Notes

- **Use Chromium, not Firefox.** The Playwright Firefox build has compatibility
  issues with JS-heavy apps (e.g., Grafana fails to load application files).
- **Use the programmatic API, not the Playwright CLI.** The API gives control
  over viewport, wait conditions, selectors, and timeouts.
- **Always use `waitUntil: 'networkidle'`** plus an additional timeout for
  apps that render asynchronously after initial load.
- Install to `/tmp/pw` to avoid polluting the project directory.
- Clean up screenshot files after they are uploaded unless the user says otherwise.
