# ADR 002 — Palette

- **Status:** Accepted
- **Date:** 2026-05-08
- **App:** iApp
- **Authors:** iApp maintainers

## Context

iApp itself is a docs-only repo — it has no UI, no rendered app, no user-facing surface. So why does it need a palette ADR?

Because every child app the wizard generates needs one. The iApp ADR 002 is the **template** every child fills in. The shape, not the values.

## Decision

**iApp as a docs-only repo has no palette of its own.** This ADR exists as a *worked example of structure* for child apps to copy.

For documentation surfaces that need styling (GitHub README badges, a future GitHub Pages site), iApp uses a warm orange on cream — consistent with the warm-minimal template default (`#E07A3C` on `#FAF4EC`), so the repo's public face matches what the scaffold ships.

For child apps, this ADR is the template. Each fills in a **light and a dark** token table — `Seed/Theme/AppTheme.swift` resolves them per appearance via `dynamic(light:dark:)`, and `/pick-palette` designs both (taste rule 5: dark is not an afterthought). The structure to fill in:

### Departure delta *(example: a hypothetical app picking Sage)*

```
Seed: Sage (#7A9B6E moss accent on #EAEBE0 surface)

Delta:
- Surface shifted 6° toward blue (cooler, less earthy)
- Accent saturation reduced 12% (less assertive)
- Added Surface tertiary token for sheet headers

Final — light tokens:
  Surface            #E8EBE3
  Surface secondary  #DADFD2
  Surface tertiary   #C8CFC0
  OnSurface          #21261E
  OnSurfaceSecondary #5A6051
  Accent             #7A9270
  AccentDeep         #4C5E44

Final — dark tokens (warm near-black, accent brightened — never #000):
  Surface            #161812
  Surface secondary  #21241C
  Surface tertiary   #2E3227
  OnSurface          #E9ECE2
  OnSurfaceSecondary #9DA593
  Accent             #9DB291
  AccentDeep         #BFCEB4

AAA contrast — light:
- OnSurface / Surface:            12.4:1 ✓
- OnSurfaceSecondary / Surface:    5.1:1 ✓ (large text)
- Accent / Surface:                4.6:1 ✓ (large text / UI)

AAA contrast — dark:
- OnSurface / Surface:            13.9:1 ✓
- OnSurfaceSecondary / Surface:    6.2:1 ✓ (large text)
- Accent / Surface:                6.8:1 ✓ (large text / UI)

ΔE2000 vs claimed palettes (full matrix — one row per palette
already claimed in your PORTFOLIO.md):
- Warm orange (App A):   38 ✓
- Pink-violet (App B):   42 ✓
- Warm light (App C):    31 ✓
- Yellow accent (App D): 33 ✓
- Warm brown (App E):    26 ✓
```

## Options considered

For iApp's own doc styling:

- **No styling at all** — rejected. README badge color and a future GitHub Pages site need *something*, and "system default GitHub gray" is the worst possible "no palette" choice.
- **A neutral grayscale** — rejected. Inconsistent with "warm palettes are the template default."
- **A unique claimed palette for iApp** — rejected. iApp isn't a product; it's infrastructure. Claiming a palette is overreach.
- **Match the template's warm-minimal default** — accepted. Visitors landing on iApp see the same warm-orange-on-cream feel the scaffold ships, which is honest advertising.

## Consequences

- **Unlocks:** this ADR's *shape* is what every child app's `DECISIONS/002-palette.md` fills in. The wizard's `/pick-palette` skill writes a file exactly like this.
- **Forecloses:** iApp can't claim a unique palette without superseding this ADR.
- **Cost to revisit:** small for iApp's borrowed styling; large for the *shape* (would require updating every child app's ADR 002).

## Verification

The `/pick-palette` skill produces a file with exactly the structure shown in the "Departure delta" section above. If it can't, fix the skill, not this ADR.

## Cross-references

- [portfolio/PALETTE_CATALOG.md](../portfolio/PALETTE_CATALOG.md) — the 10 seeds + ΔE2000 distance methodology
- [portfolio/PORTFOLIO.md](../portfolio/PORTFOLIO.md) — claimed palette names + anchor hex
- [docs/PHILOSOPHY.md](../docs/PHILOSOPHY.md) — palette rules (no `#000`/`#FFF`, AAA contrast, ΔE2000 ≥ 15)
- [docs/VISUAL_IDENTITIES.md](../docs/VISUAL_IDENTITIES.md) — palette ↔ identity consistency
