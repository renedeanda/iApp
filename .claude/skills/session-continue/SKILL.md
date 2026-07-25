---
name: session-continue
description: Resume work after a session limit / restart. Reads recent git history, todo state, and unchecked phase items to reconstruct context and pick up where the previous session left off.
---

> SOURCE: pattern proven in a shipped production app's skill set

# /session-continue

Different from `/roadmap` — this one is for *resuming an in-progress task* rather than starting a session cold.

## When to use

- Previous session hit a context limit mid-task.
- New session opened on the same branch you were working in.
- You want to pick up exactly where you stopped, not re-prioritize.

## When NOT to use

- Truly fresh start with no in-progress work — use `/roadmap` instead.
- Switching to a different phase — use `/phase` instead.

## Steps

1. `git log -10 --oneline` to see what landed.
2. `git status` to see uncommitted work.
3. Read [`DECISIONS/005-launch-readiness.md`](../../../DECISIONS/005-launch-readiness.md) phase checklist.
4. Look for the most-recent commit's message — it usually names what was in-flight.
5. Identify the half-done thing:
   - If the last commit message ends with `(cont)` or `commit A`, there's a paired commit pending.
   - If a phase is partly checked, the next unchecked item is the resume point.
6. Print:
   - **What was being worked on** (one sentence)
   - **What was completed** (last 3 commits with one-line summary each)
   - **What's the next concrete step** (specific file/skill/recipe to create)
7. Propose the next single action; don't list a roadmap.

## Output shape

```
Resuming <phase / task>. Last commit was "<subject>" (abc1234). Next: <the paired
commit or next unchecked item>.

Specifically next:
  - <file or skill to create/edit>
  - <file or skill to create/edit>
  - ... [more]

Ready to draft. Confirm or override?
```

## Cross-references

- [CLAUDE.md](../../../CLAUDE.md)
- [docs/CONTRIBUTING.md](../../../docs/CONTRIBUTING.md) — phase boundary commit conventions
