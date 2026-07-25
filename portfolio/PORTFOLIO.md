# Portfolio

The single source of truth for **your** shipped (or shipping) apps. Kindling ships this file as a starter — fill it in as your apps ship. `/new-app --commit` updates it via PR whenever a new app ships, and several skills read it:

- `/pick-palette` checks new palette picks against your **claimed palettes** below (ΔE2000 ≥ 15 rule).
- `/positioning-check` compares a new app's mission against every mission below.
- `/pick-visual-identity` and `/pick-signature-motion` use this table to keep the portfolio diverse (no two apps sharing an identity + motion combo without cause).
- `/pick-monetization` reads the tier distribution to suggest where a new app should price.

The other portfolio docs are slices of this one:

- [PALETTE_CATALOG.md](PALETTE_CATALOG.md) — the palette seeds. Claimed palettes live here.
- [MONETIZATION_MATRIX.md](MONETIZATION_MATRIX.md) — the 5-tier pricing ladder + your per-app pricing decisions.
- [REUSE_INDEX.md](REUSE_INDEX.md) — feature → gold-standard-source map with reliability flags.
- [RECENT_LEARNINGS.md](RECENT_LEARNINGS.md) — lesson changelog.

---

## At a glance

*(Starter state: empty. Add a row per app as it ships.)*

| App | Mission | Tech | Visual identity | Status |
|---|---|---|---|---|
| — | — | — | — | — |

> The **Visual identity** column should name one of the eight canonical identities (or a proven ninth) per [docs/VISUAL_IDENTITIES.md](../docs/VISUAL_IDENTITIES.md).

---

## Per-app entry template

Copy this block for each shipped app. The detail level matters — skills quote these fields verbatim.

```markdown
## <App Name> — `<github-owner>/<repo>`

- **Mission:** <one sentence, ≤14 words>
- **Tech:** Swift / SwiftUI / SwiftData …  — or —  Expo / RN …
- **Palette:** <claimed name> — <accent description> on <surface description>. No `#FFF`.
- **Typography:** <specimen + hierarchy note>
- **Signature motion:** <the one motion principle>
- **Visual identity:** <one of the eight>
- **Delight moments:** <the 3–5 picked moments>
- **Monetization:** <tier + prices + what's gated. Core mission is always free.>
- **Native features enabled:** <the explicit yes-list from DECISIONS/004>
- **Localization:** <locales>
- **Reliability flag:** <✅ gold-standard for X / ⚠️ WIP for Y — feeds REUSE_INDEX.md>
```

---

## Claimed palettes

*(Starter state: empty. `/pick-palette` reads this table.)*

| App | Seed departed | Final accent | Final surface (light/dark) | Claim note |
|---|---|---|---|---|
| — | — | — | — | — |

When an app ships, record: which seed it departed from, the final accent hex, both surface anchors, and the departure direction — so future apps know which directions remain open for that seed.

---

## Claimed signature motions

*(Starter state: empty. `/pick-signature-motion` removes claimed motions from the picker.)*

| App | Motion | Timing curve | Reduce Motion fallback |
|---|---|---|---|
| — | — | — | — |
