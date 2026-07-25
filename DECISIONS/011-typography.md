# ADR 011 — Typography

- **Status:** Accepted
- **Date:** 2026-05-08
- **App:** iApp
- **Authors:** iApp maintainers

## Context

Typography is the second-most-important felt decision after motion. The Swift template ships **three specimens** (rounded-system, serif, mono-leaning) at `Theme/_TypographySpecimens/` and the wizard picks one to land at `Theme/Typography.swift` based on the visual identity.

This ADR documents iApp's typography choice (for README + docs) and templates the structure for child apps.

## Decision

**iApp repo (README, docs):** GitHub-rendered Markdown. GitHub picks the typeface; iApp doesn't override. The rendered docs use GitHub's default sans (system UI font on each platform). No custom CSS.

For a future GitHub Pages site (if iApp ever has one): match the warm-minimal template default → the rounded-system specimen (SF Pro Rounded). Consistent with ADR 002.

### Child app ADR 011 shape

```markdown
# ADR 011 — Typography

- Status: Accepted
- Date: YYYY-MM-DD
- App: <name>

## Decision

Specimen (pick one — filtered by visual identity per VISUAL_IDENTITIES.md):

☐ Rounded-system  — SF Pro Rounded family. Warm, friendly.
                    Identity match: warm-minimal, glassmorphic.
                    Template file: Theme/_TypographySpecimens/Typography.rounded.swift

☐ Serif           — New York family (system) or custom (Lora, Source Serif).
                    Identity match: typographic-led, monochrome-luxe.
                    Template file: Theme/_TypographySpecimens/Typography.serif.swift

☐ Mono-leaning    — SF Mono for body; SF Pro Display Condensed for headings.
                    Identity match: brutalist, kinetic-type.
                    Template file: Theme/_TypographySpecimens/Typography.mono.swift

☐ Hybrid         — write addendum justifying which surfaces use which specimen.
                    e.g. "Rounded in body, mono for code blocks inside note bodies"

## Token table (filled in based on specimen)

| Token | Size | Weight | Tracking | Use |
|---|---|---|---|---|
| display | 34 pt | bold | 0 | hero numbers / app-defining text |
| title | 28 pt | semibold | 0 | screen titles |
| headline | 17 pt | semibold | 0 | section headers |
| body | 17 pt | regular | 0 | primary content |
| body-emphasized | 17 pt | semibold | 0 | inline emphasis |
| caption | 13 pt | regular | 0 | secondary metadata |
| caption-emphasized | 13 pt | semibold | 0 | label-style chips |

## Departure delta (if any)

<one paragraph if specimen tokens differ from the template defaults — most apps don't deviate>

## Constraint

- No .system(size:) directly in views — always go through Typography protocol
- Reduce Motion does NOT affect type weight transitions (only timing)
- Dynamic Type respected — every token scales correctly
```

## Options considered

For iApp itself:

- **Custom typography for the README** — rejected. GitHub's default is honest for the audience. Custom Markdown CSS is over-engineering.
- **Ship a GitHub Pages site immediately** — rejected. README does the job.

For the *shape* of child app ADR 011:

- **Free-form specimen description** — rejected. The token table is the *test surface* for the wizard's `/pick-typography` skill + `ThemeContrastTests` verification.
- **Token table only, no specimen selection** — rejected. The specimen choice is the felt decision; the tokens are derived.

## Consequences

- **Unlocks:** Swift template ships three specimens in `_TypographySpecimens/` and the wizard moves the chosen one to `Theme/Typography.swift`. Token table written here verifies against the template at build time.
- **Forecloses:** ad-hoc `Text(...).font(.system(size: 17))` in views. Hard rule.
- **Cost to revisit:** small per-app (swap specimen file, rewrite token table).

## Cross-references

- [docs/VISUAL_IDENTITIES.md](../docs/VISUAL_IDENTITIES.md) — identity ↔ specimen mapping
- [docs/PHILOSOPHY.md](../docs/PHILOSOPHY.md) — "No `.system(size:)` in views" rule
- [portfolio/REUSE_INDEX.md](../portfolio/REUSE_INDEX.md) — Theme + Liquid Glass row
- ADR 015 (visual identity) — which specimens are valid per chosen identity
