---
name: design-icon
description: Generate an icon_master.svg seed for a new app, sized for Assets.xcassets/AppIcon.appiconset, styled to match the chosen visual identity + palette. Runs before tech is picked so the user sees the icon early.
---

# /design-icon

Produces a single `seed-icon.svg` at 1024×1024 that's the source-of-truth for all icon variants. The wizard runs this in `/new-app --draft` step 8 — *before* tech is picked, so the icon is part of the felt-quality assessment alongside palette and motion.

## When to use

- During `/new-app --draft` step 8, after palette is set.
- Re-generating the icon if visual identity or palette changes.
- Regenerating for an existing app whose icon has drifted (write an addendum).

## When NOT to use

- For producing the *full* icon variant set (1024 + 60@2x/3x + 76@2x + 83.5@2x + 167 + 152, etc.) — that's `generate-icons` (a downstream skill in templates' `.claude/skills/`).

## Inputs

- `DECISIONS/015-visual-identity.md` — chosen identity (determines visual vocabulary)
- `DECISIONS/002-palette.md` — final hex tokens
- `DECISIONS/000-mission.md` — one-sentence mission (for thematic alignment)

## Output

`drafts/<app-name>/seed-icon.svg` — 1024×1024 SVG with:
- Solid surface background (per palette `Surface` token — no gradient unless identity specifies)
- One primary visual element (the "thing") in the accent color
- No text (icon is glyphic, not lettered)
- No gradients unless identity is glassmorphic
- No drop shadows (Apple icon mask handles its own)
- Geometry from a 90×90 inner safe area (1024 × ~88%)

## Identity-specific guidance

| Identity | Icon vocabulary |
|---|---|
| Brutalist | thick rule shape, monospaced glyph, single accent — no curves |
| Glassmorphic | layered translucent disks, soft accent gradient OK, edge-light glow |
| Warm-minimal | one rounded shape, gentle curve, generous negative space |
| Typographic-led | a single letterform or ligature in the serif specimen |
| Hand-drawn | one shape with intentionally imperfect SVG stroke (hand-traced) |
| Maximalist-collage | 2–3 overlapping shapes, multiple accents, asymmetric |
| Kinetic-type | a single dynamic numeral or letter in heavy weight |
| Monochrome-luxe | precise geometric shape, metal accent, no chromatic color |

## Forbidden agent behavior

**Never pick the icon direction or final SVG on the user's behalf when this skill runs inside `/new-app`.** The icon is a felt-quality decision — it must be the user's pick, not the agent's. The agent produces candidate sketches; the user picks via `AskUserQuestion`; the user names the refinements.

## Steps with the user

1. Read identity + palette + mission from ADRs 015 / 002 / 000.
2. Generate 3 candidate SVG sketches matching the identity vocabulary. Save each to `drafts/<app-name>/seed-icon-candidate-{1,2,3}.svg` so the user can preview them in a viewer.

3. **`AskUserQuestion` #1 — Candidate pick.**
   - Question: *"Pick the icon direction. Three candidates saved at `drafts/<app-name>/seed-icon-candidate-{1,2,3}.svg`. Each follows the <identity> vocabulary; descriptions below."*
   - Options: "Candidate 1 — <description>" / "Candidate 2 — <description>" / "Candidate 3 — <description>" / "None — try a different direction"
   - Each option's `description` describes the visual ("rounded blob, accent fill, centered" etc.) so the user can read without needing to open the SVG, though opening it is encouraged.
   - If "None": loop once with 3 fresh candidates in a different vocabulary. Do not loop indefinitely — after 2 rounds, ask if the identity itself needs revisiting.

4. **`AskUserQuestion` #2 — Refinement (single round).**
   - Question: *"Refinements to the picked icon? Pick one or 'Looks good'."*
   - Options: "Larger primary element" / "Smaller / more negative space" / "Shift accent saturation" / "Looks good — finalize"
   - If user picks a refinement: agent edits the chosen SVG and saves the refined version. Then asks one more time with "Looks good" + "One more tweak" + "Try a fresh candidate."

5. Save final to `drafts/<app-name>/seed-icon.svg`. Delete the candidate-{1,2,3} files.

6. Run `AppIconAssetTests` style checks now (do all required sizes render at usable detail when scaled to 60×60 and 40×40?). Report results to user.

7. Final confirmation message (not a question): *"Icon saved. Sleep on it. The icon is part of the design felt-quality; review tomorrow before `--commit`."*

## Constraints

- 1024×1024, square, no transparency on background (Apple requirement).
- No `#FFF` background. Use the palette's surface token.
- No `#000` shapes either — use the OnSurface token.
- All hex colors come from `DECISIONS/002-palette.md`. No ad-hoc colors.

## Cross-references

- [DECISIONS/015-visual-identity.md](../../../DECISIONS/015-visual-identity.md) — identity → icon vocabulary mapping
- [DECISIONS/002-palette.md](../../../DECISIONS/002-palette.md) — only colors that can appear in the icon
- [docs/APP_STORE_CHECKLIST.md](../../../docs/APP_STORE_CHECKLIST.md) — full icon size requirements (used downstream by `generate-icons`)
