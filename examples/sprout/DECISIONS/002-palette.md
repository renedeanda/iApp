# ADR 002 — Palette

- **Status:** Accepted
- **App:** Sprout
- **Authors:** worked example (Kindling)

## Decision

Seed: **Sage** (portfolio/PALETTE_CATALOG.md #1) — "quiet competence" matches a tool about small true things.

Departure delta:
- Surface cooled ~6° toward blue: `#EAEBE0` → `#E8EBE3` (less earthy, calmer).
- Accent desaturated ~12% from seed moss: `#7A9B6E` → `#5F7A55`, deepened to keep AAA on the cooled surface.
- Added dark set anchored at `#181B14` (green-black, not neutral black — rule: no pure `#000`).

## Final tokens

See `Sprout/Theme/AppTheme.swift` — surface `#E8EBE3`/`#181B14`, onSurface `#21261E`/`#E4E8DF` (contrast 12.1:1 / 11.8:1 ✓ AAA), accent `#5F7A55`/`#93AC89`, accentDeep `#46603F`/`#B2C7A9`.

## Clash check

First app in this worked portfolio — no claimed palettes to clash with. Claim recorded in PORTFOLIO.md on ship.
