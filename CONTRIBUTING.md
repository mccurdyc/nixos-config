# Contributing

## AGENTS.md

`AGENTS.md` is the persistent memory for AI sessions in this repo. opencode
injects it into every session's context automatically. It is the authoritative
source of truth for how this repo is structured, what conventions are followed,
and why key decisions were made.

### What belongs in AGENTS.md

- **Structural facts**: directory layout, what each directory is for
- **Conventions**: naming, module placement rules, signature style
- **Apply commands**: how to activate changes on each host
- **Decisions**: things that were evaluated and chosen (or rejected), with a
  brief rationale -- this is the most valuable memory to capture

### What does not belong in AGENTS.md

- Transient state ("currently working on X") -- use a branch or a TODO comment
- Implementation details that are already obvious from reading the code
- Things that change frequently without a stable rationale

### When to update AGENTS.md

Update it immediately when:

1. **A structural decision is made** -- e.g., a new host is added, a module is
   split, a tool is adopted or replaced
2. **A convention is established** -- e.g., "all per-host packages go in
   `home-modules/<host>/packages.nix`"
3. **Something was tried and rejected** -- capturing rejected approaches
   prevents the same conversation from happening again in future sessions
4. **An apply command or workflow changes** -- the commands in AGENTS.md must
   stay accurate or they become misleading

### How to update AGENTS.md safely

Bad updates cause more harm than no update: the AI will follow incorrect
instructions confidently. Apply the same care you would to a comment in code.

1. **Be precise and minimal** -- add only what is stable and accurate; avoid
   capturing things that are likely to drift
2. **Update the Decisions section** rather than scattering rationale throughout;
   one decision per bullet, format: `**topic**: explanation`
3. **Remove stale entries** -- if a decision was reversed or a tool was dropped,
   delete or replace the old entry rather than leaving contradictory information
4. **Keep it short** -- long AGENTS.md files dilute signal; if a section grows
   large, consider whether it belongs in a separate referenced doc instead
5. **Verify apply commands** -- if you change the flake structure, test the
   commands before committing the update to AGENTS.md

### Relationship to CLAUDE.md / PROMPT.md

`~/.claude/CLAUDE.md` and `~/.claude/PROMPT.md` contain global personal
preferences (tone, behavior, style) that apply across all repos. `AGENTS.md`
in this repo is for repo-specific structural knowledge. Do not duplicate
content between them.
