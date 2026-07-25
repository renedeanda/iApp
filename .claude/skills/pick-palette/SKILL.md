---
name: pick-palette
description: Pick a palette seed from PALETTE_CATALOG, filtered by visual identity, then capture the bespoke departure delta. Enforces ΔE2000 ≥ 15 vs claimed palettes + AAA contrast + no #000/#FFF. Writes DECISIONS/002-palette.md.
---

# /pick-palette

Palettes are **seeds**, not picks. The wizard proposes 3 seeds compatible with the chosen visual identity, the user picks one, and the *final* palette is the bespoke delta from the seed. No two apps ship identical palettes.

## When to use

- During `/new-app --draft` step 7, after `/pick-visual-identity` lands.
- Re-deriving a palette if the identity changed.

## When NOT to use

- For warm-palette overrides on an already-shipped app — those are minor adjustments, not a new seed claim.

## The 10 catalogued seeds

(Per [portfolio/PALETTE_CATALOG.md](../../../portfolio/PALETTE_CATALOG.md).)

All seeds start **unclaimed** — as your portfolio grows, claimed seeds drop out of the picker.

| Seed | Identity match |
|---|---|
| Sage | warm-minimal, typographic-led, hand-drawn |
| Cardamom | warm-minimal, typographic-led |
| Marigold | warm-minimal, maximalist-collage, brutalist |
| Plum | monochrome-luxe, typographic-led, dark warm-minimal |
| Lavender Frost | cool warm-minimal, glassmorphic |
| Copper Dawn | light monochrome-luxe, kinetic-type, warm-minimal |
| Driftwood | warm-minimal, hand-drawn, typographic-led |
| Slate Sky | light brutalist, cool warm-minimal, kinetic-type |
| Fern | maximalist-collage, hand-drawn, warm-minimal |
| Terracotta | typographic-led, hand-drawn, maximalist-collage |

## Enforced rules

1. **No `#000` / `#FFF`** anywhere.
2. **AAA contrast** ≥ 7:1 body, ≥ 4.5:1 large text on the primary surface — **in both light and dark appearances**.
3. **ΔE2000 ≥ 15** vs every accent already claimed by an app in your PORTFOLIO.md.
4. **Identity consistency** — seed must match the chosen `015-visual-identity`.
5. **Light + dark variants both designed** — not dark-mode-as-afterthought.

## Forbidden agent behavior

**Never pick the seed or invent the delta on the user's behalf when this skill runs inside `/new-app`.** The agent does the mechanical work — filtering seeds by identity, computing AAA contrast, running ΔE2000 — and *shows* the results. The user picks the seed; the user approves the delta direction; the user approves the final hex set. If math forces a delta shift (ΔE2000 < 15), the agent shows the constraint and asks the user how to resolve it.

## Steps with the user

0. **Mockup check:** if `drafts/<app-name>/mockups/` exists (see docs/BRING_YOUR_MOCKUPS.md), view the images first and extract the dominant surface + accent colors. Propose the catalog seed *nearest those colors* as the lead option, and offer to record the mockups' actual hexes as the departure delta — running the same AAA-contrast and ΔE2000 checks on them as on any pick. Surface any contrast-forced nudge explicitly; the user decides.
1. Read chosen visual identity from `DECISIONS/015-visual-identity.md`.
2. Filter PALETTE_CATALOG seeds to those matching the identity. Drop any seeds already claimed by your shipped apps.

3. **`AskUserQuestion` #1 — Seed pick.**
   - Question: *"Pick a palette seed. Each is a *departure point*, not a final answer — we'll capture the bespoke delta in the next step."*
   - Options: 3 candidates from the filtered set, each with a one-line mood + currently-claimed status. Label the strongest mission-fit "(Recommended)".

4. **`AskUserQuestion` #2 — Departure direction.**
   - Question: *"How should we shift the seed for this app? Pick the primary direction; we'll refine the exact values after."*
   - Options: drawn from the typical delta dimensions —
     - "Cooler surface (hue toward blue)"
     - "Warmer surface (hue toward orange)"
     - "Higher saturation accent"
     - "Lower saturation, more muted"
     - Plus "Other" for free-form.

5. Agent computes draft hex tokens — **a light set and a dark set** — implementing the chosen direction. The dark set is a warm (or identity-appropriate) near-black triad, never pure black, with the accent brightened enough to carry on the dark surface. Runs AAA contrast on all primary pairs **in both appearances**. Runs ΔE2000 vs every claimed accent.

6. **`AskUserQuestion` #3 — Confirm or adjust.**
   - Question: *"Proposed palette — light <hex table>, dark <hex table>. AAA contrast (both appearances): <ratios>. ΔE2000 vs claimed: <min distance>. Confirm, or adjust?"*
   - Options: "Confirm" / "Shift further from <closest claimed app>" / "Try a different delta direction"
   - If ΔE2000 < 15 vs any claimed palette: the "Confirm" option is removed and a `Shift required` option replaces it, with the conflict named.

7. Optionally surface a 4th question for added tokens (e.g., "Surface tertiary for sheet headers? yes/no").

8. Write `DECISIONS/002-palette.md` using the shape from [DECISIONS/TEMPLATE.md](../../../DECISIONS/TEMPLATE.md):
   - Seed name
   - Delta description (the user's chosen direction + the math)
   - Final hex token tables — **a light table and a dark table**, user-confirmed; both feed `Seed/Theme/AppTheme.swift`'s `dynamic(light:dark:)` tokens
   - AAA contrast ratios for **both appearances**
   - Full ΔE2000 matrix vs claimed palettes
9. After Phase B commit, propagate the seed claim to PORTFOLIO.md "Claimed palette names" via the back-PR.

## Tools the skill uses

- `wcag-contrast.js` (or equivalent) — for AAA contrast math
- `delta-e.js` — for ΔE2000 (D65 illuminant, 2° observer)
- Live read of PORTFOLIO.md "Claimed palette names" table

## Cross-references

- [portfolio/PALETTE_CATALOG.md](../../../portfolio/PALETTE_CATALOG.md) — the 10 seeds + ΔE2000 distance methodology
- [portfolio/PORTFOLIO.md](../../../portfolio/PORTFOLIO.md) — claimed palettes
- [DECISIONS/002-palette.md](../../../DECISIONS/002-palette.md) — worked example shape
- [docs/PHILOSOPHY.md](../../../docs/PHILOSOPHY.md) — palette rules
- [docs/VISUAL_IDENTITIES.md](../../../docs/VISUAL_IDENTITIES.md) — identity ↔ seed compatibility
