---
name: review
description: Auto-healing code review for this RN app. Scans 12 RN-flavored categories (hardcoded strings, theme leaks, a11y on Pressable, hook deps, etc.), fixes what can be auto-fixed, reports what remains. Use after completing a feature or before opening a PR.
---

> SOURCE: pattern adapted from `Kindling:.claude/skills/review`, retargeted from Swift/SwiftUI to Expo/RN/TS.

# /review

Auto-healing audit pass. After a feature's commits land, run `/review` to catch consistency bugs before merging.

## When to use

- After pushing a feature branch's commits.
- Before opening a PR to `main`.
- When you suspect drift between docs and code.

## When NOT to use

- Mid-feature — wait until the feature is logically complete.
- Inside Kindling itself — use that repo's `/review`.

## The 12 audit categories

1. **Hardcoded English strings** — every `<Text>literal</Text>`, `accessibilityLabel="literal"`, `placeholder="literal"` must go through `t('key')`.
2. **Theme leaks** — color literals (`'#XXX'`, `'#XXXXXX'`), raw `fontSize:` / `fontWeight:` outside `theme/Typography.ts`, raw spacing numbers ≠ `spacing.*`.
3. **A11y on `Pressable`** — every `Pressable` needs `accessibilityRole="button"` + an `accessibilityLabel` if its child is icon-only.
4. **Touch targets** — `Pressable` / `TouchableOpacity` `minHeight` ≥ 44 (iOS HIG).
5. **Reduce Motion** — every `useSharedValue`/`withTiming`/`withSpring` site should respect `AccessibilityInfo.isReduceMotionEnabled` or short-circuit.
6. **Reduce Haptics** — every `Haptics.*` call should be wrapped in a check the user can disable.
7. **Hook deps** — every `useEffect`/`useCallback`/`useMemo` dep list is complete; no missing or stale deps.
8. **i18n parity** — keys added to `en.json` are also added to es/de/fr/pt/ja/zh-Hans (use `/translate <lang>` if values are empty).
9. **`any` / `!` smell** — no `: any`, no non-null `!` assertions; use `unknown` + narrowing or `??`.
10. **Files > 250 lines** — extract subcomponents.
11. **NotificationService caps** — every `Notifications.scheduleNotificationAsync` goes through `NotificationService.schedule()` (which guards the 64 cap).
12. **iCloud sync** — every `createICloudSync()` consumer checks `await sync.isAvailable()` first.

## Auto-fix

Mechanically obvious fixes (apply directly):
- Replace `Text>literal</Text>` with `Text>{t('key')}</Text>` + add `key: "literal"` to `en.json` + copy to non-en locales as English-fallback stubs.
- Replace color literals with the closest `colors.*` token.
- Add `accessibilityRole="button"` where missing.
- Set `minHeight: 44` on touch-target Pressables.

Don't fix (report only):
- Architectural changes, UX flow changes, navigation refactors.
- Anything that needs design judgment.

## Build / test loop

After fixes:
1. `npm run typecheck`
2. `npm test`
3. `npm run lint`

Heal up to 5 iterations. If still red, stop and report the failure with file:line.

## Output

```
## Review: <scope>

Fixed
  - <what>, <file:line>

Remaining
  - <issue that needs input>

Tests: PASSED (N) / N failed
Typecheck: PASSED / FAILED
Heal iterations: N/5
```
