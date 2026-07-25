---
name: session-continue
description: Resume work after a session limit / restart. Reads recent git history, working-tree state, and unchecked DECISIONS items to reconstruct context. Use as the first thing in a session that follows a limit hit.
---

> SOURCE: pattern adapted from the Kindling root skill `session-continue`.

# /session-continue

Recover working context after a session limit, restart, or long break.

## When to use

- Fresh session immediately after a limit-hit / context-reset.
- After more than ~24h since the last session in this repo.

## When NOT to use

- Fresh sessions where you want to start something new — use `/roadmap` instead.
- Mid-flow within a session — context isn't lost; this skill resets rather than restores.

## Steps

1. `git log -10 --oneline` — surface the last 10 commits. Look for the most recent phase-boundary marker.
2. `git status` and `git diff --stat` — find uncommitted work (the previous session may have stopped mid-edit).
3. `git stash list` — surface any stashes left behind.
4. Grep `DECISIONS/005-launch-readiness.md` for unchecked boxes — that's the next milestone.
5. Grep the working tree for `// TODO(claude)` / `// FIXME(claude)` markers — those are conversation-context handoffs.
6. Print a short summary:

```
Last commit: <hash> <subject>
Uncommitted: <N files>
Stashes: <N>
Next unchecked item: <one line>
Conversation handoffs:
  - <file>:<line>  <TODO text>
```

7. Recommend a single next action (usually `git diff` on the uncommitted work, or `/roadmap` if everything's clean).

## What it doesn't do

- It doesn't restore conversation history — that's gone after a limit hit. The session reconstructs from file state only.
- It doesn't auto-resume work — it's diagnostic, not active.
