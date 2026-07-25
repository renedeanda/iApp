---
name: test
description: Run the jest test suite. Optionally filter by file name or test name. Reports pass/fail with structured output and suggests fixes for failures. Use after every non-trivial change.
---

> SOURCE: pattern adapted from `iApp:.claude/skills/phase` (the test subset).

# /test

Run jest. Default: full suite. With arg: a filename pattern (`/test Theme`) or test-name regex (`/test --testNamePattern="rolling"`).

## When to use

- After a feature lands, before pushing.
- After fixing a bug, to confirm the regression test you wrote catches it.
- As part of `/review`'s build/test/heal loop.

## When NOT to use

- For pure visual regressions — jest doesn't render. Use Storybook or the simulator.
- When the failure is clearly a config plugin / native-side issue — `/build` first.

## Steps

1. Verify `node_modules/` is present (`npm ci` if not).
2. Run `npx jest` (or `npx jest <pattern>`).
3. Parse the output. For each failure, print:
   - Test file + name.
   - Top-of-stack file:line.
   - Probable cause (stale snapshot vs. real regression).
4. If snapshots are stale and the underlying behavior is intentionally new, suggest `npx jest -u`.

## Housekeeping suite

This template ships 5 housekeeping tests under `__tests__/`:

- `AppIconAsset.test.ts` — icon set is complete (or empty; partial is failure).
- `LocalizationParity.test.ts` — every tier-1 locale has the same key set + format specifiers as `en.json`.
- `NotificationLimit.test.ts` — rolling-window math stays inside iOS's 64-notification cap.
- `PrivacyManifest.test.ts` — `app.json.expo.ios.privacyManifests` declares every required-reason API.
- `ThemeContrast.test.ts` — AAA contrast on text/bg pairs in both schemes + no pure #000/#FFF.

These run first; if any fails, fix it before adding new tests.

## Output

```
PASS  __tests__/Theme.test.ts (5 tests)
PASS  __tests__/Locale.test.ts (8 tests)
FAIL  __tests__/MyFeature.test.ts
  expected ... but got ...
  at src/MyFeature.ts:42

Result: 12 passed, 1 failed
```
