# Subagent Delegation

Prefer delegating work to subagents via the `subagent` tool rather than doing
everything in the main context. Subagents run as isolated processes with their
own context windows and stream results back.

## When to delegate

- **Always scout first**: For any non-trivial task, use the `scout` agent to
  gather context before planning or implementing. This keeps the main context
  clean.
- **Parallel exploration**: When you need to understand multiple parts of the
  codebase, run multiple scouts in parallel.
- **Implementation**: Use the `/implement` workflow (scout → planner → worker
  chain) for implementation tasks.
- **Code review**: Use the `reviewer` agent after making changes.

## When NOT to delegate

- Simple questions that need no file reading
- Single-file edits where the context is already in the conversation
- Follow-up adjustments to work already done in this session

## Available agents

| Agent     | Use for                              |
|-----------|--------------------------------------|
| `scout`   | Fast codebase recon (Haiku)          |
| `planner` | Implementation plans from context    |
| `worker`  | General-purpose implementation       |
| `reviewer`| Code review and quality analysis     |

## Available workflows (prompt templates)

| Command                  | Flow                        |
|--------------------------|-----------------------------|
| `/implement <task>`      | scout → planner → worker    |
| `/scout-and-plan <task>` | scout → planner             |
| `/implement-and-review`  | worker → reviewer → worker  |
