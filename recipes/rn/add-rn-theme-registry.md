# Add a multi-theme registry (RN)

> **Source:** *pattern described inline* — a 12-theme registry (~12.3 KB) proven in a shipped production RN app (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md)); the template's `theme/` + `contexts/ThemeContext.tsx` are the starting point.
> **Platform:** React Native (Expo)
> **Reliability:** ✅ gold-standard — the 12-theme registry pattern, proven in production.

## What it adds

A registry of multiple named themes the user can switch between at runtime — not just light/dark, but a catalog (the proving app ships 12). Each theme is a full palette token set; some also carry a signature micro-animation. The template's single-palette `theme/` is replaced by a registry + a selected-theme context.

## When to use

- Theme choice is a **core part of the product** — the app is partly *about* personalization (the proving app's whole identity is theme expression).
- You have a **real, curated set** of themes — each one designed, each one passing the contrast tests. Not "infinite color picker".
- The user genuinely benefits from switching — it's expression, not decoration.

## When NOT to use

- **The app has one visual identity.** Most portfolio apps do — they pick a palette in `DECISIONS/002-palette.md` and commit. A multi-theme registry dilutes a strong identity. The template's single `theme/AppTheme.ts` is the right default.
- **As a substitute for getting one palette right.** Twelve mediocre themes are worse than one excellent one. Earn the first palette before adding a second.
- **An open-ended color picker.** Every theme must pass the AAA contrast test (`ThemeContrast.test.ts`). A user-built arbitrary palette can't be guaranteed to — so don't offer it.
- **Themes that are just hue rotations.** If theme B is theme A with the hue spun, it's not a theme, it's a filter. The proven registry's themes differ in *behavior* too.

## How

### 1. Harvest

- The shape (proven in production): a `constants/themes.ts` registry — each theme a full token set — plus a selected-theme provider (extend the template's `contexts/ThemeContext.tsx`).
- This **replaces** the template's `theme/AppTheme.ts` single-palette export. Adapt rather than add alongside.

### 2. Wire

- **Registry:** `themes.ts` exports a typed `Record<ThemeId, Palette>` — every entry has the same token shape (`bg`, `surface`, `text`, `accent`, …, `onAccent`).
- **Context:** `ThemeContext` holds the selected `ThemeId`, persists it via `StorageService` (see [add-rn-storage](add-rn-storage.md)), and resolves the active `Palette`. `useTheme()` returns the active tokens — call sites don't change.
- **Per-theme motion (optional):** if themes carry signature animations (e.g. a dawn-shift, an ocean-ripple), the registry entry includes an animation descriptor and components read it from `useTheme()`.
- **Contrast gate:** extend `ThemeContrast.test.ts` to iterate **every** theme in the registry — `bg`/`text` AAA, `textSecondary` AA-large, no pure #000/#FFF — for all of them. A new theme that fails the test doesn't ship.
- **Settings UI:** a theme picker in settings, each option a live swatch.

### 3. Verify

```sh
npx jest ThemeContrast
npm run typecheck
```

Expected: type-clean; the contrast suite passes **for every theme in the registry**, not just one. Adding a 13th theme that fails AAA fails CI.

## Gotchas

- The contrast test must iterate the registry dynamically (`Object.values(themes)`) — a hardcoded list of themes to test will silently skip the next one added.
- Persisting the selected theme: a missing/invalid stored `ThemeId` must fall back to a default, not crash. Validate on read.
- Per-theme animations are easy to over-do — they still answer to Reduce Motion. A theme's signature motion has a static fallback like any other.
- Replacing the single-palette `theme/` touches every `useTheme()` consumer's assumptions only if the token *shape* changes — keep the `Palette` type identical and the migration is invisible.
