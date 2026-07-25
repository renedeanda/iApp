# What's Allowed — Engagement Done Right

> Sibling to [NOT_FOR.md](NOT_FOR.md). Read both. The anti-list rejects manipulative *implementations*, not the underlying mechanics. This doc shows the same mechanics done well, with pointers to where the pattern ships in the templates.

A coding agent that has read NOT_FOR.md must read this doc before refusing a feature request. Many primitives appear in both docs — the difference is framing, not category.

---

## ✅ Streaks-as-celebration

The mechanic of "you've done X for N consecutive days" is welcome when it's framed as acknowledgment, not punishment.

**Bad** ([NOT_FOR.md](NOT_FOR.md) §1): streak resets to zero on miss. UI screams about the loss. "Don't break your streak!" notification at 11 PM.

**Good:**
- The streak is shown when the user opens the app, but missing a day is silent.
- The next time the user returns, the message is *"welcome back"* — not *"you broke your N-day streak."*
- "Best streak ever" is tracked separately and never erased. The user always has *something* they're celebrating.
- On milestones (7, 30, 100 days): a celebration burst. On a miss: silence. Proven in a shipped daily-content app.

**Recipe:** `recipes/swift/streaks-as-celebration.md`

---

## ✅ Reminders / scheduled notifications

Reminders are welcome when the user explicitly asked for them and the content serves their stated intent.

**Bad** ([NOT_FOR.md](NOT_FOR.md) §5): push to drive opens. "You haven't opened the app in 3 days."

**Good:**
- *"Mom's birthday is in 2 days."* The user added Mom + her birthday. The notification is the product.
- *"Time for your evening session."* The user opted in to evening reminders during onboarding.
- Calendar-style scheduling, not engagement-loop scheduling.
- The RN template's notification service ships the production-proven pattern: rolling 64-notification window (iOS's scheduling limit), `setHours/setMinutes` iOS-compat date math, auto-reschedule on receive.

**Recipe:** `recipes/rn/notifications.md`, `recipes/swift/notifications.md`

---

## ✅ Milestones, badges, gentle gamification

Marking accomplishments is welcome when the accomplishment is meaningful and the marker is gentle.

**Bad**: badges that imply social standing or competition. Leaderboards. "You're in the top 10%."

**Good:**
- Completing 30 sessions unlocks an internal-only milestone view ("you've had 30 quiet moments this month"). No badge graphic. No social.
- A "100 entries" milestone shown as a one-time gentle moment. No collection screen, no "67/100" progress bar haunting the user.
- Cumulative-stat milestones shown inline in the relevant log, not in a separate gamification screen.
- The proven shape: a pure Sendable milestone enum where each milestone has an acknowledgment string and no public-facing badge.

**Recipe:** `recipes/swift/milestones.md`

---

## ✅ Engagement *for the right reasons*

Daily-use loops are welcome when each loop genuinely serves the user.

**Bad** ([NOT_FOR.md](NOT_FOR.md) §2): infinite scroll. Variable-reward feed. Algorithmic content selection optimized for time-in-app.

**Good:**
- Daily quote: one tap, see a quote, close the app. The loop is *over* in 4 seconds.
- Daily 90-second wellness flow: the app actively shows a "you're done" screen and dims the call-to-action.
- Daily check-in: see who's coming up this week. Done.
- The success metric is *did the user get what they came for*, not *how long did they stay*.

---

## ✅ Onboarding that asks for what's needed

Multi-screen onboarding is welcome when each screen earns its place.

**Bad** ([NOT_FOR.md](NOT_FOR.md) §9): 8 screens of forced data collection before the user can see any value.

**Good:**
- A 5-page onboarding where every page is necessary for the product to work: name + relationships + dates + notification opt-in + done.
- A 2-screen onboarding: one explaining the core flow, one asking for notifications. That's it.
- A 2-screen onboarding: pick your habit + pick your language.
- The RN template ships a production-proven multi-page onboarding scaffold with staged fade-in pacing.

---

## ✅ Notifications that respect attention

Push is welcome when the user opted in to that specific content.

**Bad** ([NOT_FOR.md](NOT_FOR.md) §10): permission ask on first launch with no context. Re-prompt every session. Bury the "no" path.

**Good:**
- Defer the permission ask until the user takes an action that *needs* a notification ("set a reminder for 9 AM" → "we'll need permission to notify you at 9 AM — okay?").
- One-shot. Never re-prompt unless the user goes to Settings themselves.
- Both templates' notification services ship this deferred-ask pattern.

---

## ✅ App Store review prompts

Asking for a review is welcome when the user has had a genuinely good moment.

**Bad** ([NOT_FOR.md](NOT_FOR.md) §8): review prompt on first launch. Pre-screening with a 1-star bypass.

**Good:**
- `SKStoreReviewController.requestReview()` after a success state (completed session, 100th entry, etc.).
- System-throttled (Apple caps to 3/year per app).
- No pre-screening, no bypass, no in-app survey trying to deflect low ratings.
- The Swift template's `Services/_Disabled/AppReviewService.swift` ships this pattern.

---

## ✅ Paywalls

Selling the app is welcome when the value is honest.

**Bad** ([NOT_FOR.md](NOT_FOR.md) §3): pre-checked trials, hidden dismiss, weighted annual-only display.

**Good:**
- Show monthly and annual side-by-side. Same weight.
- Trial state honestly: *"7 days free, then $X/year"* — not *"free trial!"* with the price buried.
- Restore Purchases button always visible.
- Dismiss path obvious.
- The Swift template's `Services/_Disabled/SubscriptionManager.swift` ships a clean StoreKit 2 baseline of this pattern.

---

## ✅ Subscriptions

Subscription pricing is welcome when the value is genuinely ongoing.

**Bad** ([NOT_FOR.md](NOT_FOR.md) §11): subscription pricing on a single-purchase value prop.

**Good:**
- Ongoing server costs (AI inference, sync infrastructure): subscription makes sense.
- Genuinely recurring value (daily new content, ongoing recommendations): subscription makes sense.
- Single-purchase value (one-shot utility, lifetime tool): one-time IAP.
- Decision tree: [MONETIZATION_MATRIX](../portfolio/MONETIZATION_MATRIX.md).

---

## ✅ Analytics

Knowing what's used is welcome when nothing personal is collected.

**Bad** ([NOT_FOR.md](NOT_FOR.md) §7): IDFA, cross-app tracking, fingerprinting, ad-targeting.

**Good:**
- TelemetryDeck (anonymous, EU-hosted, no PII, no tracking authorization required).
- Optional Sentry with PII scrubbing for crash reports.
- Privacy nutrition labels filled honestly: Diagnostics → Crash Data, Performance Data, Other Diagnostic Data; not linked to identity; not used for tracking.
- The template's `Services/_Disabled/AnalyticsService.swift` ships the signal taxonomy.

---

## ✅ Live Activities

Showing live state on the lock screen / Dynamic Island is welcome when the live state is genuinely useful.

**Bad**: Live Activity that's just promotional, or that fires for low-value events.

**Good:**
- A commute departure timer.
- A 90-second session countdown.
- Having no Live Activity at all is also fine — don't ship one without a qualifying use case.
- The template's widget/Live Activity scaffold is the gold-standard source; see [WIDGETS.md](WIDGETS.md).

---

## ✅ Developer-only debug easter eggs

Hidden testing menus in production builds are welcome when they're for the developer's own testing, time-bounded, and undetectable to general users + App Store Reviewers.

**Bad** ([NOT_FOR.md](NOT_FOR.md) — implicit): a hidden way for any user to bypass IAP / subscription paywall at scale. That's not an easter egg, that's a monetization circumvention.

**Good** (the dev premium toggle pattern):
- 7-tap gesture on version string in Settings → About unlocks a Debug menu.
- Menu contents: Force Premium toggle, Reset Onboarding, Clear Data, Simulate AI Unavailable, etc.
- Override auto-expires after 24 hours.
- Cleared on every app update.
- Suppressed when App Store Reviewer accounts are detected.
- Lets the dev test premium features in production after TestFlight's 90-day window expires.
- See [HOUSEKEEPING.md](HOUSEKEEPING.md) "Dev/Debug Premium Toggle" for the full template pattern.

The distinction from forbidden delights: user-facing easter eggs that nobody finds are noise. Developer-only debug eggs that *deliberately* nobody finds (except the dev) are infrastructure.

---

## ✅ Widgets

Widgets are welcome and treated as a first-class surface — see [WIDGETS.md](WIDGETS.md).

Every widget must:
- Use edge-to-edge `containerBackground(for: .widget)`.
- Localize strings via the widget extension's *own* `Localizable.xcstrings` (not the app's — see WIDGETS.md for the bundle-loading trap).
- Read shared data via `FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:)`, not raw `UserDefaults(suiteName:)`.

---

## How to use this doc

1. When a user asks for a feature that overlaps with [NOT_FOR.md](NOT_FOR.md), check here first.
2. If a positive framing exists, build that — and surface the distinction to the user in one sentence so they can correct you if their intent was the anti-pattern.
3. If no positive framing exists (e.g. "build infinite scroll"), surface NOT_FOR.md and ask what they actually want to accomplish.
4. New positive patterns shipped in one of your apps → add to this doc with a file path.

This doc evolves. The anti-list is conservative; the allow-list is expansive. The goal is apps that feel *alive* — not apps that feel timid.
