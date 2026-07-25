---
name: init
description: Seed CLAUDE.md in a newly-generated child app repo. Inherits taste rules from iApp + substitutes per-app values (mission, palette tokens, signature motion, chosen haptics). Used by /new-app --commit during repo creation.
---

> SOURCE: universal init skill, scoped to iApp's child-app CLAUDE.md template assembly

# /init

Seed a child app's `CLAUDE.md` from iApp's template + the ADR values the user picked during `/new-app --draft`.

## When to use

- During `/new-app --commit` — this is one of the file-rendering steps.
- When a child app needs its `CLAUDE.md` regenerated (e.g., after a major ADR addendum that changes the inherited frame).

## When NOT to use

- Inside iApp itself — iApp's CLAUDE.md is bespoke (the constitution).
- For non-portfolio apps — `init` substitutes claimed-portfolio values.

## Inputs

- `drafts/<app-name>/DECISIONS/*.md` — the 17 ADRs (000–016) filled in during `/new-app --draft`
- `templates/swift/CLAUDE.md` or `templates/rn/CLAUDE.md` — the assembled template (per Pass C in the plan)

## Steps

1. After `rename-template.sh` renames `Seed → AppName`, the child app's tree contains `bin/init-claude-md.sh` (copied from `templates/swift/bin/`). The CLAUDE.md in the child app still has `{{PLACEHOLDER}}` tokens.

2. Read the 17 ADRs in `drafts/<app-name>/DECISIONS/` (000–016) to assemble the substitution map. The placeholder → ADR mapping is documented in `templates/swift/.claude/skills/init/SKILL.md`.

3. Invoke the child app's `bin/init-claude-md.sh` with the assembled key=value pairs:
   ```sh
   <child-app>/bin/init-claude-md.sh <child-app>/CLAUDE.md \
     APP_NAME="<name>" \
     MISSION="<one-sentence>" \
     VISUAL_IDENTITY="<identity>" \
     PALETTE_SEED="<seed>" \
     PALETTE_TOKENS="<markdown table from AppTheme.swift>" \
     SIGNATURE_MOTION="<principle>" \
     TYPOGRAPHY_SPECIMEN="<rounded-system|serif|mono-leaning>" \
     HAPTIC_NAMES="<h1, h2, h3>" \
     DELIGHT_MOMENTS="<bullet list>" \
     TIER="<0|1|2|3|4>" \
     UNIVERSAL="<yes|no>"
   ```
   The script does sed substitution and validates no unfilled `{{KEY}}` remains. If any do, it exits nonzero with the missing names — fix the ADR or the invocation.

4. Commit message: `init: seed CLAUDE.md from iApp template`.

## Cross-references

- [docs/ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) "Pass C — child app CLAUDE.md template"
- [DECISIONS/](../../../DECISIONS/) — every ADR feeds a substitution
- [templates/swift/bin/init-claude-md.sh](../../../templates/swift/bin/init-claude-md.sh) — the substitution script
- [CLAUDE.md Maturity matrix](../../../CLAUDE.md) — this script is the ⬜ Automation layer that enforces the substitution; the SKILL.md is the 🟡 guidance
