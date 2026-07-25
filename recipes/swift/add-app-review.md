# Add review prompts

> **Source:** `templates/swift/Seed/Services/_Disabled/AppReviewService.swift` (canonical, self-contained) — modeled on a gold-standard implementation proven in production (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md)).
> **Platform:** Swift
> **Reliability:** ✅ gold-standard — happy-moment scoring + optional happy-gate around a throttled `AppStore.requestReview`, with TestFlight/sandbox suppression.

## What it adds

An `AppReviewService` that asks for an App Store rating **only** after a genuine success moment, and **only** within Apple's throttling rules. The user is asked when they're most likely to feel good about the app — never mid-task, never on launch.

## When to use

- The app has a clear **success moment** — a reset completed, a note saved-and-synced, a milestone reached.
- The user has used the app enough that a rating would be informed (a few sessions, not the first run).
- You want the ask centralized and throttled, not sprinkled.

## When NOT to use

- **On launch or on a timer.** Asking before the user has succeeded at anything is the fastest way to a 1-star. The ask is *earned* by a success moment.
- **After a failure or an error.** Never ask for a review on a path where something went wrong.
- **More than the OS allows.** `SKStoreReviewController` is throttled to ~3 prompts/year by the system — but don't even *call* it more than that; the service tracks its own counter so it asks at the *best* moments, not just whenever it's allowed.
- **With a *deceptive* pre-modal.** A modal that imitates/fakes the system rating sheet, or hides the "no", games the throttle and is a dark pattern. The **happy-gate is different and allowed**: "Enjoying {App}?" → *I love it* (system sheet) / *Could be better* (mailto feedback) / *Not now*. It filters unhappy users to feedback instead of burning a system prompt — Apple-compliant and shipped across multiple production apps. The system sheet is still the only thing that submits a rating. Direct (no pre-modal) is also fine for quiet apps.
- **Interrupting a flow.** The prompt appears *after* the success moment's UI has settled, not on top of it.

## How

### 1. Harvest

- Source: `templates/swift/Seed/Services/_Disabled/AppReviewService.swift` — read it for the throttle bookkeeping (last-asked date, success-count threshold, version-gating).
- In a generated app it ships in `Services/_Disabled/` — move it up to `<App>/Services/AppReviewService.swift`.

### 2. Wire

- **Trigger:** call `AppReviewService.shared.requestReviewIfAppropriate()` from the success moment — after the completion animation, not during.
- **Throttle:** the service checks: enough successes since last ask? enough days elapsed? not already asked this app version? Only then does it call `SKStoreReviewController.requestReview(in:)`.
- **No custom UI:** the service only ever triggers the *system* prompt. No pre-modal, no "enjoying the app?" gate.
- **Version-gating:** don't re-ask on every point release — gate on meaningful version jumps or a fresh success streak.

### 3. Verify

```sh
xcodebuild test -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:<App>Tests/AppReviewServiceTests
```

Expected: tests green — `requestReviewIfAppropriate()` returns false until the success-count + elapsed-days + version conditions are all met, and true exactly once per qualifying window.

## Gotchas

- `SKStoreReviewController.requestReview` does nothing in DEBUG/TestFlight against the throttle in unpredictable ways — test the *service's decision logic* in unit tests, not the actual prompt appearance.
- The system may show nothing even when you call it (its own throttle on top of yours) — that's expected; never build logic that depends on the prompt actually appearing.
- Don't reset the throttle counters on app update — that would let every release re-pester the user.
