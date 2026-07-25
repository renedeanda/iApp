---
name: test
description: Run the Swift Testing suite via xcodebuild. Optionally filter by suite or test name. Reports pass/fail with structured output and suggests fixes. Includes the 8 housekeeping tests. Use after every non-trivial change.
---

> SOURCE: pattern adapted from the Kindling root skill `phase` (the test subset).

# /test

Run the test suite. Default: everything. With arg: `-only-testing:SeedTests/<SuiteName>`.

## When to use

- After a feature lands, before pushing.
- After fixing a bug, to confirm the regression test catches it.
- As part of `/review`'s build/test/heal loop.

## When NOT to use

- For pure visual regressions — tests don't render. Use the simulator.
- When the failure is clearly a build/project issue — `/build` first.

## Steps

1. `xcodegen generate` if files changed.
2. Run:
   ```sh
   xcodebuild test -scheme Seed -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
   ```
   (or `-only-testing:SeedTests/<Suite>` to filter.)
3. For each failure, print: suite + test name, top-of-stack `file:line`, probable cause (stale expectation vs. real regression).

## The 8 housekeeping tests

These ship with the template and run first; fix any failure before adding new tests.

1. `AppIconAssetTests` — every required AppIcon size present (or none — partial is failure).
2. `PrivacyManifestTests` — `PrivacyInfo.xcprivacy` declares every required-reason API the code uses.
3. `LocalizationParityTests` — every `Localizable.xcstrings` key has all 7 tier-1 locales.
4. `WidgetLocalizationParityTests` — widget-surface strings live in the widget extension's own xcstrings (a trap we hit in production). Skips gracefully if no widget extension yet.
5. `ThemeContrastTests` — AAA contrast on text/background palette pairs.
6. `HapticPatternTests` — exactly the earned haptic patterns compile in (3 + addenda in `DECISIONS/012`).
7. `WidgetEdgeToEdgeTests` — widget root uses `containerBackground(for: .widget)`. Conditional on widgets enabled.
8. `LiveActivityViewTests` — all five LA presentations render. Conditional on Live Activities enabled.

## Output

```
Test Suite 'SeedTests' — 8 housekeeping + N feature tests
  ✓ ThemeContrastTests          (4 tests)
  ✓ LocalizationParityTests     (7 tests)
  ✗ MyFeatureTests.handlesEmpty — expected ... got ... at Seed/Feature.swift:88

Executed N tests, 1 failure
```
