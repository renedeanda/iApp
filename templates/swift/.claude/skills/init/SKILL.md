---
name: init
description: Re-seed this app's CLAUDE.md when {{PLACEHOLDERS}} leaked through, or after a major ADR addendum that changes the inherited frame. Inherits taste rules from Kindling + substitutes per-app values from DECISIONS/.
---

> SOURCE: pattern adapted from the Kindling root skill `init`.

# /init

Render `CLAUDE.md` from the template + the ADR values captured in `DECISIONS/`.

## When to use

- Right after `/new-app --commit` if the wizard's substitution missed a placeholder.
- After a significant ADR addendum (visual identity change, monetization tier flip) — the inherited frame stays correct only if `CLAUDE.md` is re-rendered.

## When NOT to use

- For routine edits to `CLAUDE.md` — edit it directly. `/init` is destructive: it overwrites the file.
- For apps that have substantially diverged from the template — manual merge is safer.

## Steps

1. Locate the cached upstream template (the one bundled with this app at `bin/_claude-md.template`, or copy fresh from `templates/swift/CLAUDE.md` in the Kindling repo this app was generated from, if the cache is absent).
2. Read every `DECISIONS/000-*.md` … `DECISIONS/016-*.md` to collect the substitution map:

   | Placeholder | Source |
   |---|---|
   | `{{APP_NAME}}` | `project.yml` target name / `DECISIONS/006` |
   | `{{MISSION}}` | `DECISIONS/000-mission.md` |
   | `{{VISUAL_IDENTITY}}` | `DECISIONS/015-visual-identity.md` |
   | `{{PALETTE_SEED}}` | `DECISIONS/002-palette.md` |
   | `{{PALETTE_TOKENS}}` | derived: read `Seed/Theme/AppTheme.swift`, emit the markdown table |
   | `{{SIGNATURE_MOTION}}` | `DECISIONS/009-signature-motion.md` |
   | `{{TYPOGRAPHY_SPECIMEN}}` | `DECISIONS/011-typography.md` |
   | `{{HAPTIC_NAMES}}` | `DECISIONS/012-haptic-vocabulary.md` (joined by `, `) |
   | `{{DELIGHT_MOMENTS}}` | `DECISIONS/014-delight-moments.md` (bullet list) |
   | `{{TIER}}` | `DECISIONS/003-monetization.md` |
   | `{{UNIVERSAL}}` | `DECISIONS/001-tech-choice.md` (Universal Purchase yes/no) |

3. Invoke `bin/init-claude-md.sh` with the substitution map:
   ```sh
   bin/init-claude-md.sh CLAUDE.md \
     APP_NAME="<app name>" \
     MISSION="<one-sentence mission>" \
     VISUAL_IDENTITY="<identity>" \
     PALETTE_SEED="<seed name>" \
     PALETTE_TOKENS="<markdown table>" \
     SIGNATURE_MOTION="<motion principle>" \
     TYPOGRAPHY_SPECIMEN="<rounded-system|serif|mono-leaning>" \
     HAPTIC_NAMES="<haptic1, haptic2, haptic3>" \
     DELIGHT_MOMENTS="<bullet list>" \
     TIER="<0|1|2|3|4>" \
     UNIVERSAL="<yes|no>"
   ```
   The script does the sed substitution and exits nonzero if any unfilled `{{KEY}}` remains. The literal `{{PLACEHOLDERS}}` in the file header is documentation and is preserved.

4. If the script exits nonzero, it prints the unfilled placeholder names — return to step 2 and fill in the missing ADRs.

## Output

```
/init

Read CLAUDE.md template + 17 DECISIONS/ files (000–016).
✓ CLAUDE.md — all placeholders substituted

Diff: `git diff CLAUDE.md` to review before committing.
```

## Forbidden

- Do NOT pull live values from `https://` while substituting — use the cached template only, so an Kindling revision doesn't silently change this app's CLAUDE.md.
- Do NOT call `sed` directly to substitute placeholders — use `bin/init-claude-md.sh` so the validation step runs.
