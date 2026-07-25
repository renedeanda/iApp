# Add onboarding (RN)

> **Source:** *pattern described inline* — a 5-page, ~18 KB onboarding flow proven in a shipped production RN app (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** React Native (Expo)
> **Reliability:** ✅ gold-standard — the steps below carry the shipped implementation's structure.

## What it adds

A multi-screen onboarding flow with a measured fade-in cadence: each screen reveals its title first, then its body content a beat later. The pacing tells the user "we'll go at your speed." Shown once, on first launch, then never again.

## When to use

- The app has a **genuine first-run concept to teach** — a mental model, a permission to explain, a one-time setup.
- The flow is **short** — 3 to 5 screens. The proven production flow runs 5; that's the ceiling.
- Each screen earns its place: it teaches one thing or asks for one thing.

## When NOT to use

- **The app is self-evident.** A timer, a single-purpose utility — drop the user straight in. Onboarding for an obvious app is a tax on every new user.
- **As a feature tour.** Don't walk through every screen. Teach the *model*, not the UI — the UI should be discoverable on its own.
- **To front-load every permission request.** Ask for notifications/iCloud/etc. at the moment they're needed, not in a permission gauntlet on screen 2.
- **More than ~5 screens.** Past that, completion rates fall off a cliff. Cut it down.
- **Without a skip path** (unless a screen is a hard requirement like a legal gate).

## How

### 1. Harvest

- The shape (proven in production): an `expo-router` route with a two-stage fade cadence per screen and an `AsyncStorage` "seen" flag gating it from the root layout.
- Create: `app/onboarding.tsx`. It's an `expo-router` route.

### 2. Wire

- **Route gating:** the root layout checks an `AsyncStorage` flag (`<app>.onboarding.completed`). Unset → redirect to `/onboarding`; set → straight to `(tabs)`.
- **Cadence:** each screen uses `react-native-reanimated` to fade the title in (~400 ms), then the body content (~300 ms later). This is the signature — keep the stagger.
- **Reduce Motion:** when `AccessibilityInfo.isReduceMotionEnabled` is true, content appears immediately (no fade). Every motion site respects this — see the [review](../../templates/rn/.claude/skills/review/SKILL.md) skill's category 5.
- **Theme:** screens use `useTheme()` tokens — no color or font literals. The onboarding is the user's first impression of the palette.
- **i18n:** every string goes through `t()`. Onboarding copy is tier-1 localized like everything else.
- **Completion:** the last screen's CTA sets the flag and routes to `(tabs)`. A `Skip` control (top-right) does the same from any screen.

### 3. Verify

```sh
npx jest
npm run typecheck
# then: clear the app's storage in the simulator, relaunch — onboarding shows once, not on the second launch.
```

Expected: type-clean; on a fresh install onboarding appears, completes to the tabs, and never reappears; with Reduce Motion on, content is instant.

## Gotchas

- The `AsyncStorage` flag read is async — the root layout must handle the "still loading the flag" state (a splash hold), or it'll flash the tabs then redirect.
- Don't animate `layout` — animate `opacity`/`transform`. Layout animations during a route transition fight `expo-router`.
- Test the skip path as carefully as the complete path — a skip that doesn't set the flag re-shows onboarding forever.
- Keep the onboarding route out of the `(tabs)` group so it has no tab bar.
