---
name: demo-recording
description: >
  Record a demo of a web application or terminal session. Uses Playwright for
  browser recordings and VHS for terminal recordings. Offers to attach the
  resulting GIF/video as a PR comment.
user-invocable: true
---

# Demo Recording Skill

Record a demo of a running application or terminal session.

## Workflow

1. **Determine the type of demo.**
   - **Browser demo**: recording interactions in a web application.
   - **Terminal demo**: recording a terminal session (commands, output).

2. **Ask if the local dev environment is already running** (for browser demos).
   - If yes, ask for the URL (default: `http://localhost:3000`).
   - If no, ask the user how to start it, then run the provided command and
     wait for the server to be ready before proceeding.

3. **Ask what flow/steps to demonstrate.**
   Get a clear description of the interactions to script (pages to visit,
   buttons to click, text to type, etc.).

4. **Record the demo.**

   ### Browser demo (Playwright)

   Install Playwright and Chromium to a temp directory:

   ```bash
   npm install --prefix /tmp/pw playwright
   npx --prefix /tmp/pw playwright install chromium
   ```

   Create a script (e.g., `/tmp/pw/demo-record.mjs`) that performs the
   described interactions with video recording enabled:

   ```javascript
   import { chromium } from '/tmp/pw/node_modules/playwright/index.mjs';

   const url = process.argv[2] || 'http://localhost:3000';

   const browser = await chromium.launch();
   const context = await browser.newContext({
     recordVideo: { dir: '/tmp/pw/', size: { width: 1600, height: 900 } },
     viewport: { width: 1600, height: 900 }
   });
   const page = await context.newPage();

   await page.goto(url, { waitUntil: 'networkidle' });
   await page.waitForTimeout(3000);

   // Scripted interactions here
   // await page.click('button#start');
   // await page.waitForTimeout(2000);
   // await page.fill('input#search', 'demo query');
   // ...

   await context.close(); // saves the video
   await browser.close();
   ```

   Run with:

   ```bash
   node /tmp/pw/demo-record.mjs "<URL>"
   ```

   **Tips:**
   - Add `page.waitForTimeout(2000–3000)` pauses between actions so the
     recording is easy to follow.
   - For JS-heavy apps (Grafana, SPAs), use longer waits after navigation.
   - Use `waitUntil: 'networkidle'` for every `page.goto()` call.

   ### Terminal demo (VHS)

   Create a `.tape` file describing the session:

   ```tape
   Output demo.gif
   Set FontSize 14
   Set Width 1200
   Set Height 600

   Type "command here"
   Enter
   Sleep 2s
   ```

   Run with:

   ```bash
   vhs demo.tape
   ```

   If VHS is not available, fall back to `asciinema` + `agg`:

   ```bash
   asciinema rec demo.cast
   agg demo.cast demo.gif
   ```

5. **Convert to GIF if needed** (for browser recordings that output `.webm`):

   ```bash
   ffmpeg -i /tmp/pw/*.webm -vf "fps=15,scale=1280:-1:flags=lanczos" -loop 0 demo.gif
   ```

   If the GIF is too large (>10MB), reduce fps or scale:

   ```bash
   ffmpeg -i /tmp/pw/*.webm -vf "fps=10,scale=800:-1:flags=lanczos" -loop 0 demo.gif
   ```

6. **Show the result to the user** using the read tool on the resulting GIF/video
   file so they can verify it looks correct.

7. **Ask if the user wants the recording added as a comment on the current
   pull request.**
   - If yes, determine the current PR number:
     ```bash
     gh pr view --json number -q .number
     ```
   - **Never commit the GIF to the repository.** Always upload it as a GitHub
     comment attachment and reference the resulting URL:
     ```bash
     # Upload the GIF as a GitHub comment attachment (returns markdown image URL)
     # GitHub renders attached images hosted on user-attachments CDN
     gh pr comment <number> --body "## Demo" --edit-last 2>/dev/null || true

     # Use gh api to upload the file as a comment attachment:
     REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
     ASSET_URL=$(curl -sS \
       -H "Authorization: token $(gh auth token)" \
       -H "Accept: application/json" \
       -F "file=@demo.gif;type=image/gif" \
       "https://uploads.github.com/repos/${REPO}/issues/${PR_NUMBER}/comments/assets" \
       | jq -r '.[0].href // .[0].url')

     # If the upload endpoint above fails, fall back to creating a gist:
     # ASSET_URL=$(gh gist create demo.gif --public | tail -1)/raw/demo.gif

     gh pr comment <number> --body "## Demo

     ![demo](${ASSET_URL})"
     ```
   - **Do NOT** use `git add`, `git commit`, or `git push` for demo GIFs.
     They bloat the repository and are not source code.

## Notes

- **Use Chromium, not Firefox.** The Playwright Firefox build has compatibility
  issues with JS-heavy apps (e.g., Grafana fails to load application files).
- **Use the programmatic API with ESM imports** from `/tmp/pw/node_modules/playwright/index.mjs`.
- Install to `/tmp/pw` to avoid polluting the project directory.
- Keep recordings short and focused (aim for < 30 seconds).
- Clean up intermediate files (`.webm`, scripts) after the final GIF is produced,
  unless the user says otherwise.
- If both VHS and asciinema are unavailable for terminal demos, inform the user
  and suggest installing one via nix (`pkgs.vhs` or `pkgs.asciinema`).
