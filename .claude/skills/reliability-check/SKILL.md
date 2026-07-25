---
name: reliability-check
description: Enforce the Reliability Matrix from REUSE_INDEX before harvesting code. For each enabled native feature, confirm the gold-standard source and REFUSE harvesting from sources flagged WIP or legacy in your matrix.
---

# /reliability-check

The gate that prevents propagating WIP / broken patterns into new child apps. Runs automatically inside `/new-app --draft` step 17 (after `/pick-tech` and feature toggles) and inside `/sync-from-portfolio` (before any harvest).

## When to use

- Automatic — inside `/new-app` step 17.
- Automatic — inside `/sync-from-portfolio` before any source file read.
- Manually — when a developer asks "where do I copy this from?"
- Manually — when a PR reviewer suspects the wrong source was used.

## When NOT to use

- For features not in the REUSE_INDEX matrix — those are novel, not harvested.
- For pure-template iApp code — those have `// SOURCE:` headers, not REUSE_INDEX lookups.

## The matrix (lives in portfolio/REUSE_INDEX.md)

For every harvestable capability, the matrix has:
- ✅ Gold-standard source (template path, or one of *your* shipped apps once it's proven a pattern)
- ⚠️ Avoid (WIP or broken sources, with reason)
- Notes

This skill enforces both columns. Out of the box, the templates in this repo are the gold-standard source for every row — as you ship apps, you'll add rows pointing at your own repos, and (inevitably) flag some of them ⚠️ when a pattern turns out to be half-done.

## Starter enforcement rows

(The template ships proven scaffolds for these; harvest from the template until one of your own apps supersedes it.)

| Feature | ✅ Use |
|---|---|
| Native widgets | `templates/swift/SeedWidgets/` |
| Live Activities | `templates/swift/SeedWidgets/` |
| Apple Intelligence gating | `templates/swift/Seed/Services/_Disabled/OnDeviceAIService.swift` |
| RN iCloud sync | `templates/rn/modules/icloud-sync/` |
| Haptic vocabulary | `templates/swift/Seed/Utilities/_HapticVocabulary/` |
| StoreKit 2 paywall | `templates/swift/Seed/Services/_Disabled/` (SubscriptionManager) |

(Full matrix in REUSE_INDEX.md — this skill reads the live file each invocation.)

## Steps

1. Identify the feature being harvested (from the wizard's step 17 enabled list, or from the user's explicit request).
2. Look up the row in `portfolio/REUSE_INDEX.md`.
3. If feature not in matrix: surface — *"No gold-standard yet for [feature]. Either propose a new row to REUSE_INDEX (if one of your apps has proven it) or write it as novel (ADR-driven)."*
4. If feature has ✅ source: confirm — *"Harvesting [feature] from [path]. Proceed?"*
5. If feature also has ⚠️ source that the user *thinks* they want: **refuse** with the reason.
   - *"Cannot harvest [feature] from `<repo>:...` — that source is flagged WIP for [reason] per REUSE_INDEX. Use [the ✅ source] instead."*
6. Log the enforcement decision in `DECISIONS/004-native-feature-checklist.md` (the per-feature row gets the source path filled in).

## The widget-l10n trap specifically

A trap we hit in production: widget extensions load strings from the *extension's own bundle*, not the host app's. Widget code whose strings are keyed only in the app bundle looks fine in development and ships broken. When a harvest source has this problem:

1. Refuse the widget extension code as-is.
2. The *logic* (providers, App Intents) may be harvestable if its strings load from the correct bundle.
3. The *animation* parts may be harvestable — but flag that any strings on that surface need to be rewritten in the new app's xcstrings.

The template's widget scaffold ships its own `Localizable.xcstrings` and is verified by `WidgetLocalizationParityTests.swift`, so harvesting from the template is always safe.

## Cross-references

- [portfolio/REUSE_INDEX.md](../../../portfolio/REUSE_INDEX.md) — the full matrix
- [portfolio/RECENT_LEARNINGS.md](../../../portfolio/RECENT_LEARNINGS.md) — record the reason whenever you flag a source WIP/legacy
- [docs/WIDGETS.md](../../../docs/WIDGETS.md) — the widget l10n trap explained
- [DECISIONS/004-native-feature-checklist.md](../../../DECISIONS/004-native-feature-checklist.md) — where the enforcement decision lands
