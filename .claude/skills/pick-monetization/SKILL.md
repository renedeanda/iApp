---
name: pick-monetization
description: Two-axis pricing decision for a new app — per-app fit (5-tier ladder) × portfolio mix (current distribution). Reads ADR 003 + MONETIZATION_MATRIX, surfaces tip warnings, writes DECISIONS/003-monetization.md.
---

# /pick-monetization

The studio's monetization decision is **two-axis**: which tier fits the app's mission/infra, AND which tier serves the portfolio mix. Mission always wins, but trade-offs are surfaced explicitly.

## When to use

- During `/new-app --draft` step 16, after `/pick-tech`.
- Re-evaluating a draft's pricing before commit.
- When an existing app considers changing monetization model (separate ADR for the change).

## When NOT to use

- For a Tier 0 app where the answer is obvious (mission has zero infra costs and is gift-tier shape).

## The 5-tier ladder

(Per [DECISIONS/003-monetization.md](../../../DECISIONS/003-monetization.md).)

| Tier | Pricing | When |
|---|---|---|
| 0 | $0 forever | RN + no infra + emotionally simple mission |
| 1 | $3.99–$7.99 lifetime IAP | RN + bounded utility + no ongoing infra |
| 2 | $9.99–$14.99 lifetime IAP | Swift + substantial scope + no ongoing infra |
| 3 | sub + lifetime escape | Swift + AI inference OR hosted sync OR server processing |
| 4 | $19.99+ upfront | Specialist mission + professional audience |

## Axis 1 — Per-app fit

Inputs from prior ADRs:
- Mission (ADR 000) — emotionally simple? specialist? prosumer?
- Tech (ADR 001) — Swift vs RN; Universal Purchase yes/no
- Native features (ADR 004) — Apple Intelligence / CloudKit / Live Activities
- Audience (inferred)

Pre-positioning logic:

```
RN + no enabled infra services + emotionally-simple mission  →  Tier 0
RN + bounded content/utility + no ongoing costs              →  Tier 1
Swift + substantial scope + no ongoing infra                 →  Tier 2
Swift + Apple Intelligence OR hosted sync OR server proc     →  Tier 3
Specialist + professional + willing-to-pay-upfront signal    →  Tier 4
```

Universal Purchase cascade: Mac Catalyst opt-in → top of tier band.

## Axis 2 — Portfolio mix

Read current mix from [MONETIZATION_MATRIX.md](../../../portfolio/MONETIZATION_MATRIX.md). Targets:

| Tier | Target |
|---|---|
| 0 | 1–2 apps |
| 1 | 2–3 apps |
| 2 | 1–2 apps |
| 3 | 2–3 apps |
| 4 | 0–1 apps |

Compute what the mix would become if recommendation accepted. Surface warnings:

- **>70% on one model** → warn, require confirmation
- **Tier at cap** → warn, suggest underrepresented tier as alternative
- **Tier underrepresented** → bonus signal ("would fill a gap")
- **Two consecutive new apps on same tier** → soft warning

## Forbidden agent behavior

**Never pick the tier on the user's behalf when this skill runs inside `/new-app`.** Monetization is a portfolio-strategy decision — even when Axis 1 produces a clean answer, the user weighs it against the Axis 2 mix and confirms via `AskUserQuestion`. The agent surfaces the data; the user commits.

## Steps with the user

1. Load current portfolio mix from MONETIZATION_MATRIX.
2. Run Axis 1 pre-positioning based on prior ADRs (mission, tech, native features).
3. Run Axis 2 mix cross-check (target ranges per tier).

4. **`AskUserQuestion` #1 — Tier pick.**
   - Question: *"Pick the monetization tier. Axis 1 (per-app fit): <recommended tier> because <reason>. Axis 2 (portfolio mix): tier currently at <X/Y>. <If trade-off>: would push to <new%>."*
   - Options: up to 4 tiers most plausible for this app —
     - Recommended tier first, labeled "(Recommended)"
     - Adjacent tiers (one above, one below) with one-line trade-off rationale
     - "Mission override — pick a different tier with reason"
   - Each option's `description` cites a market data point from MONETIZATION_MATRIX (e.g., *"~93–95% of iOS users don't have an active sub — Tier 2 captures them"*).

5. If user picks a non-recommended tier: **`AskUserQuestion` #2 — Override reason.**
   - Question: *"You picked Tier <N>. Recommendation was Tier <M>. What's the override reason?"*
   - Options: 2–3 plausible override patterns ("Mission requires specialist pricing" / "Portfolio mix is underweight there" / "Conscious experiment") + "Other" for free-form.

6. If Swift + Universal Purchase from `/pick-tech`: **`AskUserQuestion` #3 — Top of band confirmation.**
   - Question: *"Universal Purchase typically pushes pricing to the top of the tier band (e.g., $14.99 instead of $9.99). Confirm?"*
   - Options: "Yes — top of band" / "No — keep midpoint with rationale"

7. Write `DECISIONS/003-monetization.md` recording:
   - Chosen tier + pricing (final number the user confirmed)
   - Both axes' answers verbatim
   - Trade-off acknowledgments (if any)
   - Universal Purchase flag (from `/pick-tech`)
   - Product IDs reserved (added to MONETIZATION_MATRIX claim list)

## Cross-references

- [DECISIONS/003-monetization.md](../../../DECISIONS/003-monetization.md) — 5-tier framework, strategic rationale
- [portfolio/MONETIZATION_MATRIX.md](../../../portfolio/MONETIZATION_MATRIX.md) — current mix, decision tree, market data
- [docs/NOT_FOR.md](../../../docs/NOT_FOR.md) §11 — when subscription is wrong
- [docs/WHATS_ALLOWED.md](../../../docs/WHATS_ALLOWED.md) ✅ Paywalls — honest paywall patterns
