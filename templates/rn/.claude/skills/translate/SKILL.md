---
name: translate
description: Translate missing localization keys for a specific tier-1 language. Diffs en.json against the target locale, translates only the missing values, validates format specifiers (`{{var}}` and `%@`/`%lld` parity), and writes back. Use before App Store submission and any time new keys land in en.
---

> SOURCE: pattern adapted from `iApp:.claude/skills/translate` (originally for `Localizable.xcstrings`); retargeted to flat-JSON i18next.

# /translate

Fill missing translations in `i18n/locales/<lang>.json`.

## When to use

- After adding new keys to `i18n/locales/en.json`.
- Before App Store submission (every tier-1 locale must be real, not English-fallback).
- When `/l10n-audit`'s "Bulk prefix-group leak" check flags a locale as Critical.

## When NOT to use

- For brand names (app name, Claude, ChatGPT, etc.) — these stay English in every locale.
- For format-only patches (whitespace, ordering) — touch the JSON directly.

## Args

`/translate <lang>` where `<lang>` ∈ `es de fr pt ja zh-Hans`.

## Steps

1. Read `i18n/locales/en.json` (the source of truth) and `i18n/locales/<lang>.json`.
2. Build a flat map of keys → values for both. The target file ships as a copy of `en.json`, so "missing" here means "value equals the en value AND the en value is a real word, not a brand/symbol".
3. For each candidate key:
   - If the value is a brand name (matches a small allowlist: app name, "Claude", "ChatGPT", "GPT-5", "iCloud", "AirPods", etc.) → skip.
   - If the value is a pure symbol / number / URL → skip.
   - Otherwise: translate using the locale's native conventions.
4. **Validate format specifiers**: every `{{var}}` in the source must appear (count + names) in the translation. Every `%@` / `%lld` / `%s` / `%d` must too.
5. Write the updated JSON back, sorted by key for diff stability.
6. Run `npx jest LocalizationParity` to confirm structural parity didn't drift.

## Output

```
/translate es

Source: i18n/locales/en.json (17 keys)
Target: i18n/locales/es.json
  - Skipped (brand names): 2
  - Skipped (already translated): 0
  - Translated this run: 15

Format-specifier validation: PASSED
Parity test: PASSED

Run `git diff i18n/locales/es.json` to review.
```

## Conventions

- Tone: match the brand voice declared in `CLAUDE.md`. Warm-minimal apps stay warm; brutalist apps stay terse.
- Length: avoid translations that 2x the English length — they wreck button layouts. Prefer concision over literal translation when the meaning is preserved.
- Punctuation: respect locale norms (Japanese: 「」 not "" for quotes; French: NBSP before `:` and `?`).
