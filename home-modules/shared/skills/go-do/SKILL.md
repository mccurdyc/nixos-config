---
name: go-do
description: >
  Goal-driven execution. Breaks a task into phases with verification,
  parallelizes via subagents, and iterates until the outcome is achieved.
  Triggers: 'go-do', 'goal-driven', 'achieve this', 'make it so'.
user-invocable: true
allowed-tools: bash, edit, write, read, grep, find, ls, tmux-delegate, tmux-check-worker, tmux-check-workers, tmux-list-workers, browser_diff, subagent
---

# Go-Do: Goal-Driven Execution

Efficiently and effectively achieve a specified goal through structured
decomposition, parallel execution, verification, and iteration.

## Intake

When activated, gather the following from the user. If the user provides a
brief instruction (e.g., "go-do: make the tests pass"), ask clarifying
questions for any missing pieces. Use the `interactive-questionnaire` skill
if there are many options to resolve.

| # | Question | Purpose |
|---|----------|---------|
| 1 | **Motivation** — Why are you doing this? | PR description, commit messages |
| 2 | **Outcome** — What is the desired final state? | Success criteria |
| 3 | **Phases** — Are there logical stages? | Decomposition |
| 4 | **Verification** — How do we confirm each phase and the final outcome? | Concrete commands/checks |
| 5 | **Iteration** — What's the rebuild/deploy/verify loop? | Worker instructions |
| 6 | **Guardrails** — What MUST or MUST NOT happen? | Hard constraints |
| 7 | **Cross-references** — Docs, files, or examples to consult? | Context for workers |

If the user's intent is clear enough to infer answers, propose them and
confirm rather than asking redundant questions.

## Goal Contract

After intake, write a `.go-do.md` file in the project root with the
structured answers. This file is the single source of truth for all
subagents. Pass its path to every worker so they have full context.

```markdown
# Goal Contract

## Motivation
<why>

## Outcome
<desired final state — specific, verifiable>

## Phases
1. <phase> — done when: <verification command/criteria>
2. <phase> — done when: <verification command/criteria>

## Iteration Loop
- Rebuild: <command>
- Deploy: <command>
- Verify: <command>

## Guardrails
- MUST: <requirement>
- MUST NOT: <prohibition>

## Cross-References
- <path or URL>
```

## Execution

### Decomposition

The orchestrator breaks the goal into phases. For each phase:

1. **Assess parallelism** — Can subphases run independently? If yes,
   spawn parallel workers via `tmux-delegate`.
2. **Assign verification** — Every phase has a "done when" criterion
   that produces a binary pass/fail (command exits 0, output matches
   expected, file exists, etc.).
3. **Provide full context** — Each worker receives:
   - The path to `.go-do.md`
   - The specific phase they own
   - The verification command they must run before reporting done
   - Any guardrails that apply

### Verification

After each worker reports done, the orchestrator runs the phase
verification independently. Trust but verify — don't take the worker's
word for it.

For the final outcome, run the outcome verification (which may be a
superset of phase checks — e.g., full test suite, end-to-end test,
build from clean).

### Iteration

When verification fails:

1. **Attempt 1-3**: Provide the failure output as context to the next
   worker attempt. Each attempt must show measurable progress (fewer
   errors, different error, partial fix). If an attempt produces the
   exact same failure with no progress, count it as wasted and escalate
   sooner.

2. **After 3 attempts without clear progress**: **STOP.** Do not
   continue iterating. Iteration without progress is a signal that
   context is missing. Ask the user:
   - What failed and what was tried
   - What specific context or guidance would help
   - Whether the approach should change

### Branching Strategy

- **Default**: Single branch for the entire goal.
- **Stacked branches**: Use when phases produce independently shippable
  and reviewable units (e.g., "phase 1 is a refactor, phase 2 builds
  on it"). Use the `git-worktree` skill for isolation.
- **Parallel branches**: Use when phases are independent and could each
  become their own PR.

The orchestrator decides during planning and tells the user the strategy.

## Pre-Flight Check

Before starting phase 1, verify:

- [ ] Correct branch / clean working tree (or worktree created)
- [ ] Required tools available (check commands in iteration loop)
- [ ] Environment variables / secrets accessible
- [ ] Cross-reference files exist and are readable

If any pre-flight check fails, resolve it or ask the user before
proceeding.

## Guardrails (Always Active)

- **MUST** write `.go-do.md` before starting work.
- **MUST** verify each phase independently after worker completion.
- **MUST** stop and ask after 3 iterations without measurable progress.
- **MUST** show diff and get user approval before committing.
- **MUST** clean up `.go-do.md` after the goal is achieved and committed.
- **MUST NOT** continue iterating when the same error repeats unchanged.
- **MUST NOT** skip verification because "it probably works."
- **MUST NOT** commit, push, or open PRs without user approval.
- **MUST NOT** guess at missing context — ask the user.

## Completion

When the final outcome verification passes:

1. Show the user what was achieved (summary + diff).
2. Get approval to commit.
3. Clean up `.go-do.md`.
4. If applicable, open PR with the **Motivation** as the description.
