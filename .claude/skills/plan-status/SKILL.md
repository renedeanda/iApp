---
name: plan-status
description: Show current progress across the repo's build plan. Reads the repo to determine what's actually on disk vs what each phase specifies. Outputs a dashboard.
---

> SOURCE: pattern proven in a shipped production app's skill set

# /plan-status

Inspect the repo file tree against the current build plan, report what's done vs pending. Works against whatever build-plan doc the repo carries — a `PLAN.md`, a roadmap doc, or the phase checkboxes in `DECISIONS/005-launch-readiness.md`. If no plan doc exists, say so and offer `/phase` or a plan draft instead.

## When to use

- You want a snapshot of overall progress, not just the current phase.
- Before deciding to PR a phase branch → main.
- When asked "how far along is this?"

## When NOT to use

- During a focused task — too much context for one mid-task check-in.

## Phase fingerprints

For each phase in the plan doc, derive a quick on-disk check from its stated deliverables — the files/directories the phase says it ships. A phase is "done" when its deliverables exist on disk AND its checkbox (if the plan has checkboxes) is ticked; "in progress" when some deliverables exist; "pending" otherwise. Trust the disk over the checkbox and flag any mismatch (checkbox ticked but files missing, or vice versa).

## Steps

1. Read the plan doc and extract each phase's deliverables.
2. `ls` / `find` the repo to fingerprint each phase's deliverables on disk.
3. For each phase, emit one line: `Phase N: ✅ done` / `⚙️ in progress (N/M items)` / `⏳ pending`.
4. Highlight the active phase.
5. End with a completion summary — *"N/M phases complete. Currently active: Phase X."*

## Output shape

```
Plan status — <date>

Phase 1: <name>                 ✅ done
Phase 2: <name>                 ✅ done
Phase 3: <name>                 ⚙️ in progress (13/29 items)
Phase 4: <name>                 ⏳ pending

Launch readiness: 2/4 phases complete. Currently active: Phase 3.
```

## Cross-references

- [DECISIONS/005-launch-readiness.md](../../../DECISIONS/005-launch-readiness.md)
- [docs/ARCHITECTURE.md](../../../docs/ARCHITECTURE.md)
