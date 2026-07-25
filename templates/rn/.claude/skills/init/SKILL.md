---
name: init
description: Re-seed this app's CLAUDE.md when `{{PLACEHOLDERS}}` leaked through, or after a major ADR addendum that changes the inherited frame. Inherits taste rules from Kindling + substitutes per-app values (mission, palette, motion, haptics, etc.) from DECISIONS/.
---

> SOURCE: pattern adapted from `Kindling:.claude/skills/init`.

# /init

Render `CLAUDE.md` from the template + the ADR values captured in `DECISIONS/`.

## When to use

- Right after `/new-app --commit` if the wizard's substitution missed a placeholder.
- After a significant ADR addendum (e.g., visual identity change, monetization tier flip) — the inherited frame stays correct only if `CLAUDE.md` is re-rendered.

## When NOT to use

- For routine edits to `CLAUDE.md` — edit it directly. `/init` is destructive: it overwrites the file.
- For child apps that have substantially diverged from the template — manual merge is safer.

## Steps

1. Locate the upstream template (the Kindling repo's `templates/rn/CLAUDE.md`, or the locally cached copy if working offline).
2. Read every `DECISIONS/000-*.md` … `DECISIONS/015-*.md` to collect the substitution map:

   | Placeholder | Source ADR |
   |---|---|
   | `{{APP_NAME}}` | `app.json` `expo.name` |
   | `{{MISSION}}` | `DECISIONS/000-mission.md` |
   | `{{VISUAL_IDENTITY}}` | `DECISIONS/015-visual-identity.md` |
   | `{{PALETTE_SEED}}` | `DECISIONS/002-palette.md` |
   | `{{PALETTE_TOKENS}}` | derived: read `theme/AppTheme.ts` and emit the markdown table |
   | `{{SIGNATURE_MOTION}}` | `DECISIONS/009-signature-motion.md` |
   | `{{TYPOGRAPHY_SPECIMEN}}` | `DECISIONS/011-typography.md` |
   | `{{HAPTIC_NAMES}}` | `DECISIONS/012-haptic-vocabulary.md` (joined by `, `) |
   | `{{DELIGHT_MOMENTS}}` | `DECISIONS/014-delight-moments.md` (rendered as bullet list) |
   | `{{TIER}}` | `DECISIONS/003-monetization.md` (the tier label) |

3. Substitute, write to `CLAUDE.md`.
4. Grep for any remaining `{{` — if found, list them with the ADR they should have read from.

## Output

```
/init

Read CLAUDE.md template (124 lines).
Read 16 DECISIONS/ files.
Substituted: 10 placeholders.
No stray {{...}} tokens.

Diff: `git diff CLAUDE.md` to review before committing.
```

## Forbidden

- Do NOT pull live values from `https://` while substituting — use the cached template only. Otherwise a Kindling template revision silently changes this app's CLAUDE.md.
