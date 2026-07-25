---
name: pick-delight-moments
description: Pick 3–5 specific micro-joys from the DELIGHT_REEL catalog for the new app. Each moment requires user action + Reduce Motion fallback + cost-benefit fit. Cap at 5; 6th requires ADR addendum. Writes DECISIONS/014-delight-moments.md.
---

# /pick-delight-moments

Delight moments are *earned*, not sprinkled. The catalog (`docs/DELIGHT_REEL.md`) holds ~18 moments across the portfolio. Each new app picks 3–5 to bake in.

## When to use

- During `/new-app --draft` step 10, after motion is picked.
- Adding a 6th moment to an existing app (requires `/pick-delight-moments --add-extra` and writes an addendum).

## When NOT to use

- For an "general polish pass" — that's not a delight moment, that's craft.
- For dev-only easter eggs (Force Premium toggle, etc.) — those are explicitly excluded; see HOUSEKEEPING.md "Dev/Debug Premium Toggle."

## The reel

Initial catalog (~18 moments) per [docs/DELIGHT_REEL.md](../../../docs/DELIGHT_REEL.md), all proven in shipped production apps. Grouped by family:

- **Calm / grounding** — breathing orb expand-on-tap, three concentric ring bloom, sense-tick descending haptic, soft launch fade-in
- **Glass / chrome** — Liquid Glass under floating bars, lock-screen widget → Dynamic Island morph, save → favorite haptic chain
- **Dark / ambient** — orbital state-change wave, dark palette settling on launch
- **Brutalist** — hard-cut transitions, countdown timer "snap", tally type-animation
- **Celebration** — streak-as-celebration burst, reveal blur-to-sharp
- **Warmth** — multi-page onboarding fade-in cadence, card flip on tap
- **Tactile** — dot fill on tap, per-theme micro-animation registry

Plus 6 future slots (page-curl easter egg, spring-back overscroll, type-weight shift, color-bleed on nav, sound-aware visual, time-of-day palette settling).

## Discipline

- **Cap: 5 moments per app.** Adding a 6th requires:
  1. Run with `--add-extra` flag
  2. Write an addendum to `DECISIONS/014-delight-moments.md` justifying it
  3. Sleep on it (reviewer = you tomorrow morning)
- **Each moment must:**
  - Tie to a specific user action (not "ambient delight")
  - Have a source file path you can link to
  - Pass the forbidden-delights checklist
- **Timing budget:**
  - 200–400 ms transitions
  - 400–600 ms state changes
  - 600+ ms ONLY for completion celebrations
- **Reduce Motion fallback** defined for every moment
- **Dev easter eggs are SEPARATE** — those go in HOUSEKEEPING.md, not here

## Forbidden agent behavior

**Never pick the delight moments on the user's behalf when this skill runs inside `/new-app`.** The 5-cap is a bandwidth rule — picking for the user invites scope creep. The agent filters by identity + motion and presents the candidate set; the user multi-selects via `AskUserQuestion`.

## Steps with the user

1. Read chosen visual identity (`015`) and signature motion (`009`) from prior ADRs.
2. Filter the reel to moments compatible with the identity + motion principle.

3. **`AskUserQuestion` #1 — Delight pick (multiSelect).**
   - Question: *"Pick 3–5 delight moments from the filtered reel. Hard cap is 5; a 6th requires an addendum and a night to sleep on it."*
   - Options: up to 4 of the strongest mission-fit moments from the filtered reel, each option's description naming the source file path + the user action it fires on.
   - multiSelect: true
   - If user selects >5 via Other: surface the cap and refuse to proceed without dropping or invoking `/pick-delight-moments --add-extra`.

4. For each picked moment: **`AskUserQuestion` follow-up** to capture:
   - "Where it fires in *this* app" — free-form via "Other" with 2 example chips drawn from the moment's reel entry.
   - "Cost-benefit fit (one sentence tying to mission)" — free-form via "Other".

5. **`AskUserQuestion` — Reduce Motion fallbacks.**
   - Question for each moment: *"Reduce Motion fallback for <moment>? (Cannot be 'no fallback'.)"*
   - Options: 2 sensible fallbacks per moment (e.g., "Static end-state image" / "Crossfade") + "Other".

6. Write `DECISIONS/014-delight-moments.md` per the TEMPLATE shape — table of [#, moment, source, fires-on, cost-benefit-fit, reduce-motion-fallback].

7. After Phase B commit:
   - `/wire-first-screen` closes the ADR→code loop: it applies each chosen moment to the first screen's matching action surface, using the reusable patterns in `Theme/DelightMoments.swift` (`.resultReveal()` for completion/result views, `.celebrationPop(_:)` for milestone moments) and adding a bespoke modifier there for any moment the shipped patterns don't cover.
   - Wizard seeds `recipes/swift/delight-animations.md` with copy-ready snippets from each chosen source.
   - If THIS app proves a new moment not in the reel, the back-PR adds it to DELIGHT_REEL.md with the new app's file path.

   > **The ADR is the spec, not the end.** A `DECISIONS/014` row with no corresponding modifier is the delight half of the "ADR that produced no code" gap — the signature-motion loop closes via `SignatureMotionWiredTests`; this one closes the same way. `Theme/DelightMoments.swift` is the code home: every picked moment ends as an applied modifier, not just a table row.

## Cross-references

- [docs/DELIGHT_REEL.md](../../../docs/DELIGHT_REEL.md) — full catalog, forbidden delights, dev-egg distinction
- [DECISIONS/014-delight-moments.md](../../../DECISIONS/014-delight-moments.md) — table shape
- [docs/WHATS_ALLOWED.md](../../../docs/WHATS_ALLOWED.md) — developer-only easter eggs are explicitly OK (separate category)
- [CLAUDE.md](../../../CLAUDE.md) taste rule 3 — 6 design-first checkpoints
