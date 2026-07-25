---
name: translate
description: Translate missing localization keys for a specific tier-1 language. Diffs the en entries in Localizable.xcstrings against the target locale, translates only the missing values, validates format specifiers, and writes back. Use before App Store submission and any time new keys land.
---

> SOURCE: pattern adapted from the iApp root skill `translate`.

# /translate

Fill missing translations in `Seed/Localizable.xcstrings` (and `InfoPlist.xcstrings`) for one locale.

## When to use

- After adding new keys (a new key starts with only an `en` entry).
- Before App Store submission — every tier-1 locale must be real, not stale.
- When `LocalizationParityTests` fails for a locale.

## When NOT to use

- For brand names (app name, "Claude", "iCloud", etc.) — these stay English; mark them `state: translated` with the English value or leave them, but don't "translate" them.
- For format-only edits — touch the xcstrings directly.

## Args

`/translate <lang>` where `<lang>` ∈ `es de fr pt ja zh-Hans`.

## Steps

1. Read `Seed/Localizable.xcstrings` (JSON). For each key, find entries missing the target locale, or whose target localization has `state: "new"` / is absent.
2. For each missing value:
   - Brand name / pure symbol / number → skip (or copy verbatim, `state: translated`).
   - Otherwise translate using the locale's native conventions and the brand voice declared in `CLAUDE.md`.
3. **Validate format specifiers**: `%@`, `%lld`, `%d`, `%f` counts and order must match the `en` source exactly. A mismatch is a crash waiting to happen.
4. Write the entry back with `state: "translated"`.
5. Repeat for `InfoPlist.xcstrings` (localized display name + permission strings).
6. Run `xcodebuild test -only-testing:SeedTests/LocalizationParityTests` to confirm parity.

## Conventions

- Tone: match the brand voice in `CLAUDE.md`. Warm-minimal stays warm; brutalist stays terse.
- Length: avoid translations that 2× the English — they break button layouts.
- Punctuation: respect locale norms (Japanese 「」 not ""; French NBSP before `: ; ? !`).

## Output

```
/translate es

Localizable.xcstrings: 17 keys, 15 missing es
  - Skipped (brand names): 2
  - Translated: 15
InfoPlist.xcstrings: 3 keys, 3 translated
Format-specifier validation: PASSED
LocalizationParityTests: PASSED
```
