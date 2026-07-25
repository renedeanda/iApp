---
name: review
description: Auto-healing code/doc review for Kindling. Scans 16 categories (count bugs, cross-ref integrity, CLAUDE.md rule violations, API naming, etc.), fixes what can be auto-fixed, reports what remains. Use after completing a phase.
---

> SOURCE: pattern proven in a shipped production app's skill set

# /review

Auto-healing audit pass. After a phase's commits land, run `/review` to catch consistency bugs before merge to main.

## When to use

- After pushing a phase's commits (e.g., after Phase 3 commits land).
- Before opening a PR to main.
- When you suspect drift between docs.

## When NOT to use

- Inside a portfolio child app — use that child's `/review` instead.
- Mid-phase — wait until the phase logically completes.

## The 16 audit categories

1. **Count consistency** — "N items" claims match actual list lengths (caught the "Five design decisions" / 6 items bug)
2. **Cross-reference integrity** — every `[link](path)` resolves; forward refs to future-phase files acceptable but flagged
3. **CLAUDE.md taste-rule compliance** — no `#000`/`#FFF` in code samples (except explicit anti-examples), no `.system(size:)`, etc.
4. **API naming consistency** — Swift method signatures vs Obj-C names (caught `URLForSecurityApplicationGroupIdentifier` bug)
5. **Naming convention** — product names vs repo names stay consistent when an app's marketing name differs from its repo name
6. **Repo shorthand** — `repo:path` references use the shorthand from REUSE_INDEX
7. **⚠️-source quarantine** — no code harvesting from sources flagged ⚠️ in REUSE_INDEX
8. **Number agreement** — tier counts, locale counts, haptic counts consistent across docs
9. **Pricing consistency** — every app's pricing matches MONETIZATION_MATRIX and ADR 003
10. **Reliability matrix sync** — REUSE_INDEX rows match PORTFOLIO reliability flags
11. **ADR cross-refs** — every ADR cross-references at least one other ADR and one doc
12. **Phase status truthfulness** — DECISIONS/005 checkboxes match what's actually on disk
13. **Stale TODO drift** — no abandoned `TODO(skill)` or `TODO(phase N)` markers
14. **Forbidden pattern leaks** — no smart quotes, no emoji (where not asked), no trailing whitespace
15. **Portfolio diversity claims** — current-mix tables match actual portfolio
16. **Universal Purchase flag agreement** — ADR 003 + MONETIZATION_MATRIX + PORTFOLIO all agree per app

## Steps

1. For each of the 16 categories, run the check.
2. For each finding:
   - **Auto-fixable** (typo, count mismatch, broken link): fix immediately.
   - **Judgment-needed** (intent unclear, structural): surface to the user.
3. Commit auto-fixes with message `<Phase N> review: <summary of fixes>`.
4. Report:
   - Categories clean: N
   - Auto-fixed: M (with one-line summary per fix)
   - Needs decision: K (with the question per finding)

## Cross-references

- [CLAUDE.md](../../../CLAUDE.md) — the taste rules
- [docs/PHILOSOPHY.md](../../../docs/PHILOSOPHY.md) — code-level expectations
- [portfolio/REUSE_INDEX.md](../../../portfolio/REUSE_INDEX.md) — reliability matrix
- [docs/CONTRIBUTING.md](../../../docs/CONTRIBUTING.md) — PR review checklist
