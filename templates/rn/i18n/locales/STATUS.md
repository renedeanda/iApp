# Locale status — Seed template

Tier-1 locales: `en es de fr pt ja zh-Hans`.

The 6 non-English files ship as **exact copies of `en.json`**. This guarantees:

- i18next never misses a key at runtime — fallback is the same string.
- Format-specifier parity passes (every locale has the same `{{var}}` slots).
- `/l10n-audit`'s structural check passes.

But it also means **every non-English file is 100% leaked English** until a real translation lands. Run `/translate <lang>` per locale to fill in real translations.

```
/translate es
/translate de
/translate fr
/translate pt
/translate ja
/translate zh-Hans
```

The skill diffs `en.json` against the target file, translates only the un-translated values, validates format specifiers, and writes back.

Until then, expect `/l10n-audit`'s "Bulk prefix-group leak" check to flag every group as Critical. That's the correct signal — fix it before App Store submission.
