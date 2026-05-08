---
name: screenshot
description: >
  Take a screenshot of a running web application using Playwright and a
  Zen/Firefox browser. Offers to attach the screenshot as a PR comment.
user-invocable: true
---

# Screenshot Skill

Take a screenshot of a locally running web application.

## Workflow

1. **Ask if the local dev environment is already running.**
   - If yes, ask for the URL (default: `http://localhost:3000`).
   - If no, ask the user how to start it, then run the provided command and
     wait for the server to be ready before proceeding.

2. **Take the screenshot with Playwright.**

   Use `npx playwright screenshot` with the Firefox/Zen channel:

   ```bash
   npx playwright screenshot --browser firefox "<URL>" screenshot.png
   ```

   If `npx playwright` is not available, install it first:

   ```bash
   npm exec -- playwright install firefox
   ```

   If the user requests a specific viewport, element, or full-page capture,
   pass the appropriate Playwright flags (e.g., `--full-page`,
   `--viewport-size 1280,720`).

3. **Show the screenshot to the user** using the read tool on the resulting
   PNG file so they can verify it.

4. **Ask if the user wants the screenshot added as a comment on the current
   pull request.**
   - If yes, determine the current PR number (e.g., via `gh pr view --json number -q .number`).
   - Upload the image and comment using the GitHub CLI:

     ```bash
     gh pr comment <number> --body "![screenshot](screenshot.png)" --attach screenshot.png
     ```

     Or if `--attach` is not supported in the installed `gh` version, upload
     via the GitHub API:

     ```bash
     # Upload as a repo asset or embed via issue comment with base64
     gh api repos/{owner}/{repo}/issues/<number>/comments \
       -f body="![Screenshot](https://user-images.githubusercontent.com/...)"
     ```

     Prefer the simplest approach that works: commit the screenshot to the
     branch and reference it in the comment body if other methods fail.

## Notes

- Always use Firefox (Zen) as the browser engine.
- Clean up screenshot files after they are uploaded unless the user says otherwise.
- If Playwright is not installed globally, use `npx` to run it ephemerally.
