---
name: roadmap
description: Session starter for the RN child app. Reads CLAUDE.md, DECISIONS/005-launch-readiness.md, recent git history, and open PRs. Outputs a prioritized work list. Use as the first thing in a fresh session.
---

> SOURCE: pattern adapted from `Kindling:.claude/skills/roadmap`, RN-paths-flavored.

# /roadmap

Reconstruct what to work on next in a fresh session inside this child app. Output is a short prioritized list with one-tap kick-off suggestions.

## When to use

- Fresh session in this repo.
- After a long gap and you need to remember what's in flight.
- Before deciding whether to ship a fix vs. continue a feature.

## When NOT to use

- Mid-task — `roadmap` resets context; you don't want that when you're in flow.
- Inside Kindling itself — use that repo's `/roadmap` instead.

## Steps

1. Read `CLAUDE.md` to ground the session in this app's mission + taste rules.
2. Read `DECISIONS/005-launch-readiness.md` — find the next unchecked launch-readiness item.
3. Skim `DECISIONS/004-native-feature-checklist.md` — which services are still in `src/services/_Disabled/`?
4. Run `git log -5 --oneline` to see recent commits.
5. Check open PRs (if a remote exists).
6. Print:
   - **Current focus** (one line)
   - **Next 3 work items** (ordered by impact × effort)
   - **Blocked / waiting** (anything in `// TODO(...)` or pending ADRs)
   - **Quick suggestions** — usually a slash command (`/test`, `/build`, `/translate <lang>`)

## Output shape

```
Current focus: <one-line>

Next up
  1. <item> — <why now>
  2. <item> — <why now>
  3. <item> — <why now>

Blocked / waiting
  - <item>

Try
  /test         (verify nothing regressed)
  /build        (run the app)
```

Keep it tight — readers will skim, not read.
