---
name: pick-tech
description: Swift native vs React Native decision for a new app, plus Universal Purchase (Mac Catalyst) yes/no. Cascades into /pick-monetization tier positioning. Writes DECISIONS/001-tech-choice.md.
---

# /pick-tech

Pick the tech stack for a new app based on mission + native-feature requirements. The choice has direct downstream effects on monetization tier (per ADR 001's portfolio-wide tech-mix rationale).

## When to use

- During `/new-app --draft` step 15.
- Re-evaluating a draft's tech choice before commit.

## When NOT to use

- For an existing app — tech is decided.
- For non-iOS targets — Kindling is iOS-only.

## Pre-positioning logic

The skill recommends Swift vs RN based on these signals:

| Signal | → Recommendation |
|---|---|
| Mission requires Apple Intelligence / Foundation Models | Swift |
| Live Activities or Control Center quick actions | Swift |
| Mac Catalyst (Universal Purchase) likely | Swift |
| Pure Sendable domain engines (computational) | Swift |
| Multilingual breadth (≥10 locales) | RN (the RN template's i18n stack scales furthest) |
| Simpler-bounded utility, content unlocks | RN |
| Cross-platform path *might* matter later | RN |
| First-time-shipper app, smaller scope | RN |

## Forbidden agent behavior

**Never pick the tech on the user's behalf when this skill runs inside `/new-app`.** Even if the pre-positioning logic above produces a clear single answer, the user makes the call via `AskUserQuestion`. The agent presents the recommendation and the reasoning; the user clicks.

## Steps with the user

The skill walks the user through **three `AskUserQuestion` calls in sequence**, then mechanically derives the recommendation and asks one final confirmation.

1. Read the mission (`DECISIONS/000-mission.md`), anti-list (`013-anti-list.md`), and spec (`016-spec.md`).

2. **`AskUserQuestion` #1 — Apple Intelligence dependency.**
   - Question: *"Does this app's value-prop require Apple Intelligence (Foundation Models)? E.g., on-device summarization, semantic search, generation."*
   - Options: "Yes — core to mission" / "Useful but optional" / "No"

3. **`AskUserQuestion` #2 — Native iOS surfaces.**
   - Question: *"Does this app benefit from Live Activities, Control Center quick actions, or rich App Intents?"*
   - Options: "Yes — Live Activities or Control Center" / "App Intents only" / "No native surfaces beyond the app"

4. **`AskUserQuestion` #3 — Breadth signal.**
   - Question: *"Is the value-prop multilingual content / breadth (≥10 locales' worth of content), or a bounded utility?"*
   - Options: "Multilingual content breadth" / "Bounded utility, tier-1 locales" / "Single-locale focus"

5. Score signals → derive recommendation (Swift vs RN). Present back to the user with the reasoning shown.

6. **`AskUserQuestion` #4 — Tech confirmation.**
   - Question: *"Recommended: <Swift|RN> because <reasoning>. Confirm?"*
   - Options: "Confirm <recommendation>" / "Override — pick <the other>" / "Show me the trade-offs again"

7. If Swift: **`AskUserQuestion` #5 — Universal Purchase.**
   - Question: *"Mac Catalyst Universal Purchase — yes, no, or decide later?"*
   - Options: "Yes — Universal Purchase from day 1" / "No — iOS-only" / "Decide later (re-asked before `--commit`)"

8. Write `DECISIONS/001-tech-choice.md` with:
   - Decision (Swift / RN)
   - Universal Purchase (yes / no / TBD)
   - The 3 filter-question answers verbatim
   - Reasoning (1 paragraph tying choice to mission)
   - Cascading implications (which tier this likely lands in, which skills the wizard will gate to)

## Cross-references

- [DECISIONS/001-tech-choice.md](../../../DECISIONS/001-tech-choice.md) — portfolio-wide tech-mix rationale
- [DECISIONS/003-monetization.md](../../../DECISIONS/003-monetization.md) — how tech cascades into tier
- [portfolio/REUSE_INDEX.md](../../../portfolio/REUSE_INDEX.md) — gold-standard sources per tech choice
- [docs/PHILOSOPHY.md](../../../docs/PHILOSOPHY.md) — code-level expectations per stack
