---
name: pick-typography
description: Pick a typography specimen for the new app, filtered by visual identity. Three specimens ship in the Swift template (rounded-system / serif / mono-leaning); the wizard moves the chosen one to Theme/Typography.swift. Writes DECISIONS/011-typography.md.
---

# /pick-typography

Typography is the second-most-important felt decision after motion. Pick one specimen; the other two stay as swappable references in the template.

## When to use

- During `/new-app --draft` step 12, after motion + delight are picked.

## When NOT to use

- For an existing app's restyle — that's an addendum to the existing ADR 011, not a new pick.

## The three specimens

Each Swift template ships all three at `Theme/_TypographySpecimens/`:

| Specimen | Family | Identity match |
|---|---|---|
| **Rounded-system** | SF Pro Rounded | warm-minimal, glassmorphic |
| **Serif** | New York (system) or custom (Lora, Source Serif) | typographic-led, monochrome-luxe |
| **Mono-leaning** | SF Mono body + SF Pro Display Condensed headings | brutalist, kinetic-type |

A fourth option is **Hybrid** — e.g., Rounded in body while glassmorphic chrome carries its own type weight. Hybrid requires an addendum justifying the surfaces.

## Token table

Every specimen produces this 7-token table. Sizes are baseline; specimen-specific tweaks captured in the ADR.

| Token | Default size | Default weight | Use |
|---|---|---|---|
| display | 34 pt | bold | hero numbers / app-defining text |
| title | 28 pt | semibold | screen titles |
| headline | 17 pt | semibold | section headers |
| body | 17 pt | regular | primary content |
| body-emphasized | 17 pt | semibold | inline emphasis |
| caption | 13 pt | regular | secondary metadata |
| caption-emphasized | 13 pt | semibold | label-style chips |

## Forbidden agent behavior

**Never pick the specimen on the user's behalf when this skill runs inside `/new-app`.** Even when identity narrows the choice to one obvious specimen, the user clicks via `AskUserQuestion`. The agent walks the token table fields with the user; the user accepts defaults or specifies deltas.

## Steps with the user

0. **Mockup check:** if `drafts/<app-name>/mockups/` exists, view the images first and match their type feel to the nearest shipped specimen (rounded-system / serif / mono-leaning). Lead with that match and say what drove it (letterforms, weight contrast, density). If the mockups use a custom brand font, note that the specimen system can host it later — the *hierarchy* decision is what's being made here.

1. Read chosen visual identity from `DECISIONS/015-visual-identity.md`.
2. Filter the 3 specimens to those matching the identity.

3. **`AskUserQuestion` #1 — Specimen pick.**
   - Question: *"Pick the typography specimen. Identity is <X>. Recommended: <Y> because <reason>. Hybrid is allowed but requires an addendum."*
   - Options: up to 3 specimens drawn from the filtered list, with identity-fit rationale shown in each option's description. Recommended labeled "(Recommended)". Plus "Other" for the Hybrid path.
   - If user picks "Other / Hybrid": surface the addendum requirement and ask the user to either confirm Hybrid (with intent to write the addendum at end of step) or fall back to a pure specimen.

4. **`AskUserQuestion` #2 — Token deltas.**
   - Question: *"Accept default token sizes/weights from the table above, or capture deltas for any tokens?"*
   - Options: "Accept defaults" (Recommended for new apps) / "Adjust display + title only" / "Adjust full token table"
   - If user picks adjust: follow up with free-form per-token capture (1 `AskUserQuestion` per adjusted token).

5. Confirm Dynamic Type scales correctly (every token must respect user-preferred text size — this is a check, not a user-facing question; the agent verifies the specimen's `Font` usage supports it).

6. Write `DECISIONS/011-typography.md` with:
   - Chosen specimen
   - Token table (defaults or user's deltas)
   - One-sentence why this specimen fits the identity (from the AskUserQuestion option descriptions, or captured separately if Hybrid).

7. After Phase B commit: wizard moves chosen specimen to `Seed/Theme/Typography.swift`; other two stay in `_TypographySpecimens/`. This is mechanical work, no user question needed — but the wizard *shows* the move ("Moving Rounded.swift → Typography.swift; leaving Serif.swift + Mono.swift under _TypographySpecimens/. OK?") so it's visible.

## Constraint enforced

- **No `.system(size:)` direct calls in views.** Always go through `Typography.<token>`.
- Verified by `ThemeContrastTests.swift` and template linting.

## Cross-references

- [docs/VISUAL_IDENTITIES.md](../../../docs/VISUAL_IDENTITIES.md) — identity ↔ specimen mapping
- [docs/PHILOSOPHY.md](../../../docs/PHILOSOPHY.md) — typography rules
- [portfolio/REUSE_INDEX.md](../../../portfolio/REUSE_INDEX.md) — Theme + Liquid Glass row (template's full theme suite)
- [DECISIONS/011-typography.md](../../../DECISIONS/011-typography.md) — worked example shape
