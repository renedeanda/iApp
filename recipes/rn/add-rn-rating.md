# Add rating prompts (RN)

> **Source:** *pattern described inline* — happy-moment scoring + happy-gate pre-prompt + throttling, proven in shipped production RN apps (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** React Native (Expo)
> **Reliability:** ✅ gold-standard — native `expo-store-review`, happy-moment scoring, happy-gate pre-prompt, throttling.

## What it adds

A review flow over `expo-store-review`: it tracks **happy moments**, and once enough accrue (plus install-age + cadence gates), shows a **happy-gate** pre-prompt ("Enjoying {App}?" → *I love it* / *Could be better* / *Maybe later*). Only *I love it* triggers the native `StoreReview.requestReview()`; *Could be better* routes to a `mailto:` feedback path. The user is asked when they feel good — never on launch, never mid-task, never after an error.

## When to use

- The app has a clear **success moment** — a task completed, a streak hit, a thing saved-and-synced.
- The user has used the app enough that a rating would be informed (several sessions in).
- You want the ask centralized, scored, and throttled — not sprinkled across screens.

## When NOT to use

- **On launch or on a timer.** Asking before the user has succeeded earns 1-stars. The ask is *earned*.
- **After a failure.** Never prompt on a path where something went wrong.
- **A *deceptive* pre-modal.** A pre-modal that imitates or fakes the system rating sheet, or that hides the "no" option, games the store throttle and is a dark pattern. The **happy-gate is different and allowed**: it asks sentiment first and routes unhappy users to *feedback* instead of burning a system prompt — Apple-compliant and shipped across multiple production apps. The system sheet is still the only thing that can submit a rating.
- **Interrupting a flow.** The pre-prompt appears after the success UI has settled, not on top of it.
- **More often than the platform allows.** iOS throttles to ~3/year system-side; the service tracks its own counter so it asks at the *best* moments within that.

## How

### 1. Harvest

- The scoring util (proven in production): happy-moment scoring (`recordHappyMoment`), eligibility gates (≥3 score, ≥7 days installed, ≥90 days since last prompt, max 2 prompts ever), and a serial mutation queue so double-fired moments in one frame don't race.
- The UI (proven in production): a happy-gate sheet + `subscribeReviewPrompt`/`emitShow` listener pattern (Set-based for React 18 strict mode).
- Create: `utils/reviewPrompt.ts` + `components/ReviewPromptModal.tsx`. Depends on [add-rn-storage](add-rn-storage.md) for persisting state (one AsyncStorage JSON blob).

### 2. Wire

- **Record:** call `recordHappyMoment('share')` (etc.) from success moments — after the completion animation, not during.
- **Gate:** the util decides eligibility; when ready it emits → `ReviewPromptModal` shows the happy-gate.
- **Outcomes:** *I love it* → `StoreReview.requestReview()`; *Could be better* → `Linking.openURL('mailto:…')`; *Maybe later* → no completion, eligible again after the cooldown.
- **Availability:** `StoreReview.isAvailableAsync()` gates the native call — false on some platforms; handle silently. Web is a no-op.
- **Persistence:** throttle state lives under one namespaced AsyncStorage key; **not** reset on app update.

### 3. Verify

```sh
npx jest
npm run typecheck
```

Expected: type-clean; eligibility returns false until score + elapsed-days + version/cooldown all hold, true exactly once per qualifying window. The native prompt is mocked — test the *decision logic*.

## Gotchas

- `StoreReview.requestReview()` may show nothing even when called (the platform's own throttle) — never depend on the prompt actually appearing.
- In Expo Go the prompt often doesn't appear — verify decision logic in tests; verify the real prompt in a TestFlight/internal build.
- Don't reset throttle counters on app update — that re-pesters the user every release.
- Android's Play In-App Review has its own quota and may silently no-op — same rule.
