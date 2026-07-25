---
name: pick-signature-motion
description: Pick one motion principle for the new app. Reads PORTFOLIO claimed motions (removes them from the picker), filters by visual identity, captures timing curve + Reduce Motion fallback. Writes DECISIONS/009-signature-motion.md.
---

# /pick-signature-motion

Every portfolio app has ONE signature motion that distinguishes it. The wizard prevents duplicating a claimed motion AND forces an explicit Reduce Motion fallback.

## When to use

- During `/new-app --draft` step 9, after `/pick-palette` lands.
- Re-picking if the visual identity shifts mid-draft.

## When NOT to use

- For specific micro-moments (delight) — use `/pick-delight-moments` instead.
- For chrome behaviors that don't define the app's feel.

## Available principles

The wizard offers these motion principles, filtered by visual identity:

| Principle | Identity match |
|---|---|
| **Bloom** (concentric rings) | warm-minimal |
| **Orbital wave** | dark warm-minimal, monochrome-luxe |
| **Liquid Glass** (floating chrome) | glassmorphic |
| **Hard-cut** (no easing, instant states) | brutalist |
| **Breathing (idle)** | warm-minimal |
| **Parallax-recede** | warm-minimal, hand-drawn |
| **Ripple** | glassmorphic, hand-drawn |
| **Streak burst** (celebration) | maximalist-collage, playful |
| **Per-theme registry** | apps with user-selectable themes |
| **Type-weight kinetic** | kinetic-type |
| **Other** | requires addendum |

All principles start unclaimed. As your portfolio grows, motions claimed in PORTFOLIO.md drop out of the picker.

Claimed motions are *referenceable as inspiration* but a new app must pick a meaningfully different variant (different trigger, different target, different timing curve).

## Forbidden agent behavior

**Never pick the motion principle on the user's behalf when this skill runs inside `/new-app`.** The principle is the felt soul of the app — the user owns it. The agent filters claimed-out principles, presents candidates, and walks the user through the capture fields via `AskUserQuestion` for each.

## Steps with the user

The skill targets **3 `AskUserQuestion` calls total**, matching the cadence of `pick-palette` and `pick-tech`. Where-doesn't-fire, easing, and rationale are derived by the agent from the answers and shown back to the user when writing the ADR — not asked as separate questions. This consolidation came out of earlier wizard iterations (the original 7-question shape felt long; cadence matters more than completeness when the agent can derive the rest).

1. Read chosen visual identity from `DECISIONS/015-visual-identity.md`.
2. Read claimed motions from PORTFOLIO.md "Claimed signature motions" section.
3. Filter the principles list to those matching the identity AND not duplicate-claimed.

4. **`AskUserQuestion` #1 — Principle pick.**
   - Question: *"Pick the signature motion principle. Identity is <X>; claimed motions filtered out. Recommended: <Y> because <reason>."*
   - Options: up to 4 candidates from the filtered list, one-line descriptions of feel + portfolio-status (open slot / requires-different-variant / etc.). Strongest mission-fit labeled "(Recommended)".
   - If user picks "Other": require an addendum to PORTFOLIO.md proposing an additional principle with justification.

5. **`AskUserQuestion` #2 — Mechanics composite.**
   - Question: *"Pick the timing + easing + Reduce Motion fallback combination."*
   - Options: 2–3 mechanics presets tailored to the chosen principle, each option's `description` listing the three values explicitly:
     - "Quiet defaults" — e.g., 600ms idle, easeInOut spring, static-rest-state RM fallback
     - "Faster / more responsive" — e.g., 400ms, easeInOut, same RM fallback
     - "Bolder" — e.g., 800ms with bounce, spring, crossfade RM fallback
   - The mechanics options are scoped per principle; the agent generates them based on the principle picked in #1.

6. **`AskUserQuestion` #3 — Fires-on.**
   - Question: *"Where does this motion fire in *this* app's screens? Pick the primary trigger."*
   - Options: 2–3 firing-pattern candidates tailored to the principle + the app's mission (drawn from prior ADRs), with one-line examples. "Other" supports free-form.

7. Agent derives the *doesn't-fire* surfaces (settings / forms / data lists by default), the easing (from the mechanics preset), the rationale (from prior ADRs + the principle's character), and writes them into the ADR's "Options considered" and rationale sections. Each derived value is shown back to the user in the ADR-write confirmation step (see below).

8. **Final confirmation** (no new question — the agent writes the draft and asks "ADR written; confirm or revise" via the wizard's standard write-confirmation step).

9. Write `DECISIONS/009-signature-motion.md` per the shape in [TEMPLATE.md](../../../DECISIONS/TEMPLATE.md), citing every user answer + agent-derived values.

   > **The ADR is the spec, not the end.** At `/new-app --commit`, `/wire-first-screen` turns this ADR into code — it writes `Theme/SignatureMotion.swift` and applies `.signatureMotion()` to the first screen. The template ships a working Breathing default, so an app that picks Breathing needs no rewrite; any other principle has its modifier body rewritten there. An ADR 009 with no corresponding `.signatureMotion()` call site is the classic "ADR that produced no code" gap — the loop must close.

10. After Phase B commit: the back-PR to Kindling adds this motion to PORTFOLIO.md "Claimed signature motions."

## Cross-references

- [portfolio/PORTFOLIO.md](../../../portfolio/PORTFOLIO.md) — claimed motions list
- [docs/DELIGHT_REEL.md](../../../docs/DELIGHT_REEL.md) — specific micro-moments that ride on top of the principle
- [docs/PHILOSOPHY.md](../../../docs/PHILOSOPHY.md) — `motionSafeAnimation()` Reduce Motion rule
- [DECISIONS/009-signature-motion.md](../../../DECISIONS/009-signature-motion.md) — worked example shape
- [.claude/skills/wire-first-screen/SKILL.md](../wire-first-screen/SKILL.md) — turns this ADR into `Theme/SignatureMotion.swift` code at `/new-app --commit`
