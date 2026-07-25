# ADR 009 — Signature Motion

- **Status:** Accepted
- **Date:** 2026-05-08
- **App:** iApp
- **Authors:** iApp maintainers

## Context

Every well-made app has *one* signature motion that distinguishes it (Liquid Glass under floating bars; a concentric ring bloom on completion; hard-cut sheet transitions). Picking the motion deliberately — before tech, before palette — forces the app to commit to a felt-quality.

iApp has no UI. But the ADR exists as a worked example for child apps.

## Decision

**iApp has no signature motion** (no UI to apply motion to).

For child apps, this ADR is one of the **six design-first checkpoints** (CLAUDE.md taste rule 3) that precede tech. Shape:

### Child app ADR 009 shape

```markdown
# ADR 009 — Signature Motion

- Status: Accepted
- Date: YYYY-MM-DD
- App: <name>

## Decision

Principle (pick one):
☐ Bloom                — concentric expansion on completion
☐ Orbital wave         — wave propagates around a ring on state change
☐ Liquid Glass         — vibrancy + edge-light under floating chrome
☐ Hard-cut brutalist   — snap transitions, no spring/fade
☐ Breathing            — slow inhale/exhale on idle state (the template default)
☐ Parallax-recede      — layered depth on navigation
☐ Ripple               — concentric ripples on tap
☐ Streak burst         — celebration radiating outward on milestone
☐ Per-theme registry   — each theme has its own signature
☐ Other (write an addendum)

Where it fires:
- <specific user action / state transition>
- <specific surface — home screen, completion screen, etc.>

Where it explicitly does NOT fire:
- <data screens / forms / settings / etc.>

Timing curve:
- Duration: 200-400 ms transitions, 400-600 ms state changes, 600+ ms only for completion celebrations
- Easing: spring (with bounce coefficient) | easeInOut | linear | hard cut

Reduce Motion fallback:
- <what the user sees when UIAccessibility.isReduceMotionEnabled is true>
- Cannot be "no motion at all" — must be a static state that conveys the same meaning

## Why this principle

<one sentence — must tie back to the mission in ADR 000>
e.g. "The mission is calm, so motion is breathing-paced (slow, soft, returning to rest)."
e.g. "The mission is respecting working people's time, so motion is brutalist (no decoration, every transition is information)."

## Constraint

Per docs/PHILOSOPHY.md + DELIGHT_REEL.md: motion longer than 600 ms is forbidden except for completion moments.
This decision ratifies a single PRINCIPLE; specific delight moments live in ADR 014.
Claimed motions in portfolio/PORTFOLIO.md must be REFERENCED here, not duplicated — pick a meaningfully different variant if drawn to a claimed motion.
```

## Options considered

For iApp itself, "no motion" was the only option. The interesting decision is the **structure of the ADR for child apps**, not iApp's own answer.

For that structure:

- **Free-form prose** — rejected. Motion ADRs need to be machine-checkable so the wizard's signature-motion conflict check (against PORTFOLIO claimed motions) can run.
- **Just pick from a list with no "where it fires" / "where it doesn't" / Reduce Motion sections** — rejected. The wizard's review pass needs to verify these answers exist for every shipping app.

## Consequences

- **Unlocks:** the `/pick-signature-motion` skill reads PORTFOLIO's "Claimed signature motions" list, removes them from the picker, prompts for the user's choice, writes the result here.
- **Forecloses:** ad-hoc motion across an app. Every motion either follows the declared principle or is an explicit exception logged in DELIGHT_REEL (ADR 014).
- **Cost to revisit:** small per-app (one ADR rewrite).

## Cross-references

- [portfolio/PORTFOLIO.md](../portfolio/PORTFOLIO.md) — "Claimed signature motions" list
- [docs/DELIGHT_REEL.md](../docs/DELIGHT_REEL.md) — micro-moments that ride on top of the principle
- [docs/PHILOSOPHY.md](../docs/PHILOSOPHY.md) — `motionSafeAnimation()` Reduce Motion gating
- ADR 014 (delight moments) — specific moments that exemplify this principle
