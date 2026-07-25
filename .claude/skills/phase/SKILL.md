---
name: phase
description: Kick off a specific phase from the repo's current build plan. Summarizes what's in scope, dependencies, risks, and creates a structured todo list for execution.
---

> SOURCE: pattern proven in a shipped production app's skill set

# /phase

Start a new phase deliberately. Use this when transitioning from one phase to the next, not while resuming mid-phase (`/session-continue` for that). Works against whatever build-plan doc the repo currently carries — a `PLAN.md`, a roadmap doc, or the phase checkboxes in `DECISIONS/005-launch-readiness.md`. If no plan doc exists, say so and offer to draft one instead.

## When to use

- Just completed a phase, ready to start the next.
- Need to revisit a phase's scope mid-flight.
- Onboarding a fresh session to a specific phase.

## When NOT to use

- Mid-phase work — you'll lose context. Use `/session-continue` instead.
- No build plan exists — draft one first; this skill executes plans, it doesn't invent them.

## Usage

```
/phase 4
/phase 5
/phase next
```

`next` reads the plan doc and picks the first unchecked phase.

## Steps

1. Identify the requested phase number.
2. Locate the repo's build-plan doc (check `PLAN.md`, `DECISIONS/005-launch-readiness.md`, or any doc the user names) and read the phase's section.
3. Look up any local plan file (in `/root/.claude/plans/` locally) if available, otherwise extrapolate from the plan doc.
4. Summarize:
   - **Phase number + name**
   - **What ships at the end of this phase**
   - **Dependencies** (which earlier phases must be done)
   - **Risks** (anything that's tricky)
   - **Estimated scope** (file count, commit count)
5. Create a TodoWrite list with concrete tasks.
6. Propose the first todo and ask to proceed.

## Output shape

```
Phase 4 — <phase name from the plan doc>

Ships: <the phase's deliverables>
Dependencies: <earlier phases that must be done>
Risks: <anything tricky>
Estimated scope: ~N files, ~N lines, ~N commits

Creating todo list:
  [in progress] <first concrete task>
  [pending]     <next task>
  [pending]     <next task>

Starting with item 1. Proceed?
```

## Cross-references

- [DECISIONS/005-launch-readiness.md](../../../DECISIONS/005-launch-readiness.md)
- [docs/ARCHITECTURE.md](../../../docs/ARCHITECTURE.md)
- [docs/CONTRIBUTING.md](../../../docs/CONTRIBUTING.md) — commit conventions
