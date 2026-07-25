---
name: implement
description: Implement one focused step from the repo's current build plan. Reads the step spec, writes production-quality files following all conventions, builds/tests to verify. Use for step-by-step execution within a phase.
---

> SOURCE: pattern proven in a shipped production app's skill set

# /implement

Focused single-step execution. Different from `/phase` (which kicks off a whole phase) — this one does *one thing well* within an active phase.

## When to use

- You've kicked off a phase via `/phase` and want to execute the next todo.
- The user named a specific step ("/implement the dev-premium-toggle skill").
- Re-implementing one file after a `/review` flagged it.

## When NOT to use

- Multi-step phase work — use `/phase` to set up the todos first.
- Truly novel work without a spec — write the ADR first.

## Steps

1. Identify the step (from todo list or user instruction).
2. Read the relevant ADR / doc / recipe for context.
3. Identify cross-references the step depends on (CLAUDE.md rules, REUSE_INDEX gold-standard sources, PORTFOLIO claimed items).
4. Write the file(s) with:
   - `// SOURCE:` header if harvested from one of your portfolio apps
   - Inline citations to ADRs / docs in comments
   - Tests where appropriate
5. For Swift files: run `xcodegen generate` then `xcodebuild build` (when templates exist).
6. For Markdown: cross-check with `/review` category-2 (link integrity).
7. Mark the todo complete and propose the next.

## Cross-references

- [DECISIONS/](../../../DECISIONS/) — read the relevant ADR first
- [portfolio/REUSE_INDEX.md](../../../portfolio/REUSE_INDEX.md) — where the gold-standard pattern lives
- [CLAUDE.md](../../../CLAUDE.md) — the taste rules every file must honor
