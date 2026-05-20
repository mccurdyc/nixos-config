---
name: interactive-questionnaire
description: >
  Start an interactive questionnaire when there are more than 5 options or
  bullet points that need to be addressed. Uses the ask_user tool to walk
  through selections interactively instead of dumping a wall of text.
user-invocable: false
allowed-tools: ask_user
---

# Interactive Questionnaire

When you encounter a situation with **more than 5 options, bullet points, or
items** that need user input (prioritization, selection, or confirmation),
use the `ask_user` tool instead of listing them all in a message and asking
the user to respond in freeform text.

## When to trigger

- A list of 6+ options/items that the user needs to choose from or prioritize
- Multiple independent decisions that could be addressed one at a time
- Any situation where a wall of bullet points would overwhelm the response

## How to use

1. **Multi-select for "which of these?"** — present all options with
   `allowMultiple: true` so the user can pick several at once:

   ```json
   {
     "question": "Which of these would you like to address?",
     "options": ["Option A", "Option B", "Option C", "Option D", "Option E", "Option F"],
     "allowMultiple": true,
     "allowFreeform": true
   }
   ```

2. **Single-select for prioritization** — ask "which first?" then proceed:

   ```json
   {
     "question": "Which should we tackle first?",
     "options": ["Option A", "Option B", "Option C"],
     "allowMultiple": false
   }
   ```

3. **Provide context** — use the `context` parameter to summarize why you're
   asking, so the user doesn't lose track:

   ```json
   {
     "question": "Which changes do you want included?",
     "context": "I found 8 files that need updating after the refactor.",
     "options": [...],
     "allowMultiple": true
   }
   ```

## Guidelines

- **Don't over-fragment.** If there are 6-10 items, one multi-select is fine.
  Only break into sequential questions if items are truly independent decisions.
- **Always allow freeform** (`allowFreeform: true`) so the user can type
  something unexpected.
- **Summarize after selection** — once the user responds, confirm what was
  selected before proceeding with work.
