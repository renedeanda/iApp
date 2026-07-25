# Add i18n (RN)

> **Source:** `templates/rn/i18n/` (multi-locale pattern) (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** React Native (Expo)
> **Reliability:** ✅ gold-standard — tier-1 locales from day one.

## What it adds

`i18next` + `react-i18next` + `expo-localization`, wired so every user-facing string resolves from a per-locale JSON file. The template already ships this (`i18n/index.ts` + `i18n/locales/*.json` for the 7 tier-1 locales). This recipe is for understanding the setup, adding keys correctly, and keeping locale parity.

## When to use

- Always — i18n is **day-one, not later**. Every portfolio app ships tier-1 localized (`en es de fr pt ja zh-Hans`).
- Whenever you add a new user-facing string — it goes through `t()`, with the key added to `en.json` and propagated.

## When NOT to use

- **Hardcoding "just this one" English string.** There is no "just one". A literal `<Text>Save</Text>` is a localization bug. The `/review` skill flags every one.
- **Localizing brand names.** The app name, "Claude", "iCloud", "AirPods" — these stay as-is in every locale. Don't translate them.
- **Localizing developer-facing strings.** Console logs, error messages only seen in dev, debug menu labels — not user-facing, don't burn translation effort on them.
- **Adding a locale outside tier-1 without a reason.** Tier-1 is the committed set. A tier-2 locale is a real maintenance cost — justify it.

## How

### 1. Harvest

- Already in the template: `i18n/index.ts` (the i18next bootstrap + locale detection) and `i18n/locales/{en,es,de,fr,pt,ja,zh-Hans}.json`. The pattern is proven in shipped production RN apps.

### 2. Wire (adding strings)

- **Add to `en.json`** first — it's the source of truth. Use a nested key structure (`settings.appearance.title`).
- **Use `t()`** at the call site: `const { t } = useTranslation(); ... <Text>{t('settings.appearance.title')}</Text>`. Never a literal.
- **Propagate the key** to all 6 non-English files. They ship as English-fallback stubs; run `/translate <lang>` per locale to fill real translations before App Store submission. See `i18n/locales/STATUS.md`.
- **Interpolation:** i18next uses `{{var}}` — `t('greeting', { name })`. The `LocalizationParity` test checks `{{var}}` count + named-specifier parity across locales.
- **Locale detection:** `i18n/index.ts` picks the first OS-preferred locale that matches tier-1, with explicit `zh-Hans` vs `zh-Hant` handling. Don't bypass it.

### 3. Verify

```sh
npx jest LocalizationParity
```

Expected: green — every tier-1 locale has exactly the same key set as `en.json` (no missing, no extra) and matching format-specifier counts. A new key added to `en.json` but not the others fails this test.

## Gotchas

- The non-English files ship as **exact copies of `en.json`** — that's deliberate (guarantees structural parity + no runtime missing-key fallback), but it means `/l10n-audit`'s bulk-leak check correctly flags every group until `/translate` runs. That's the signal working, not a bug.
- `returnNull: false` in the i18next config means a missing key returns the key string, not `null` — so a typo'd key shows the raw key in the UI rather than crashing. Useful, but it means typos are silent — the parity test is your real safety net.
- French requires a NBSP before `: ; ? !`; Japanese uses 「」 not `""` — `/translate` handles these, hand-edits often don't.
- Don't `t()` outside a component without care — `i18n.t()` works but won't re-render on locale change; inside components always use the `useTranslation()` hook.
