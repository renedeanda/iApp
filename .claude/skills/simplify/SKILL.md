---
name: simplify
description: Review changed code/docs for reuse, quality, and efficiency. Flags duplication, over-abstraction, and rules that would benefit from cross-referencing instead of restating. Fixes the obvious cuts.
---

> SOURCE: universal simplify skill, adapted for iApp's docs-and-templates frame

# /simplify

The portfolio's ethos rewards restraint. This skill audits the most-recent commits for:
- Restated content that should cross-reference an existing canonical home
- Premature abstractions (the wizard generates abstractions when none exist; don't pre-generate them in docs)
- Over-explanation (the docs should be opinion + reference, not tutorial)
- Code samples longer than they need to be

## When to use

- After a phase's commits land, before `/review`.
- When a doc feels long and you can't say why.
- When the same fact appears in 3+ places and you suspect drift risk.

## When NOT to use

- During first-draft writing — let the draft breathe first.
- For other people's contributions you haven't read in full.

## Categories scanned

1. **Duplicated facts** — same number / claim / file path appearing in N docs where N>2; one canonical home + cross-references.
2. **Over-explanation** — paragraphs that explain *what* code does where well-named identifiers already do it.
3. **Comments that describe the current change** — "added for X feature" — those belong in the PR, not the code.
4. **Premature abstractions in templates** — services or recipes built for cases that don't exist yet.
5. **Repeated section structure** — if 5 ADRs all have the same Worked-Example wrapper, the wrapper belongs in TEMPLATE.md.
6. **Forward-looking "we will" prose** — once the thing ships, the prose should be present-tense fact, not future-tense promise.

## Steps

1. Diff the last N commits (default 3).
2. For each finding, propose one of:
   - **Cross-reference** (move the fact to its canonical home + link)
   - **Cut** (delete the duplicate / premature thing)
   - **Tighten** (rewrite shorter)
3. Auto-apply obvious cuts (typo-level redundancy).
4. Surface judgment-needed proposals as a list with diffs.

## Cross-references

- [docs/PHILOSOPHY.md](../../../docs/PHILOSOPHY.md) — restraint principle
- [docs/ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) — canonical homes per concept
