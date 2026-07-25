---
name: roadmap
description: Session starter — reads CLAUDE.md, the active build phase, recent git history, and open PRs. Outputs a prioritized work list for the current session. Use as the first thing in a fresh Kindling session.
---

> SOURCE: pattern proven in a shipped production app's skill set

# /roadmap

Reconstruct what to work on next in a fresh Kindling session. Output is a short prioritized list with one-tap kick-off suggestions.

## When to use

- Fresh session in the Kindling repo.
- After a long gap and you need to remember what phase is in flight.
- Before deciding to start `/new-app` vs. continuing internal Phase work.

## When NOT to use

- Mid-task — `roadmap` resets context; you don't want that when you're in flow.
- Inside a child app (use that child's own `roadmap` skill).

## Steps

1. Read `CLAUDE.md` to ground the session in taste rules.
2. Read [`DECISIONS/005-launch-readiness.md`](../../../DECISIONS/005-launch-readiness.md) — find the next unchecked phase.
3. Run `git log -5 --oneline` to see recent commits.
4. Check open PRs via `mcp__github__list_pull_requests` (your fork/clone's owner + repo).
5. Print:
   - **Current phase** (from the plan doc)
   - **What landed last** (3 most-recent commits)
   - **What's pending in this phase** (open todos / unchecked items)
   - **Top 3 next actions** with the slash command to run for each
6. End with: *"Want me to start with #1?"*

## Output shape

```
Kindling status — <date>

Current phase: <active phase from the plan doc>
Recent commits:
  abc1234 <most recent commit subject>
  def5678 <next>
  ...

Pending in this phase:
  - [ ] <unchecked item>
  - [x] <done item>

Next 3 actions:
  1. <action + slash command>
  2. <action + slash command>
  3. <action + slash command>

Want me to start with #1?
```

## Cross-references

- [CLAUDE.md](../../../CLAUDE.md)
- [DECISIONS/005-launch-readiness.md](../../../DECISIONS/005-launch-readiness.md)
- [docs/CONTRIBUTING.md](../../../docs/CONTRIBUTING.md)
