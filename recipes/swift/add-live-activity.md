# Add a Live Activity

> **Source:** `templates/swift/SeedWidgets/SeedLiveActivity.swift` (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** Swift
> **Reliability:** ✅ gold-standard for the LA *views* — all five presentations proven in production. For the *service layer* (start/update/end plumbing), `templates/swift/Seed/Services/_Disabled/LiveActivityService.swift` is the reference (a 120s stale window and a guarded past-date countdown, both hard-won production lessons).

## What it adds

An `ActivityKit` Live Activity: a live, glanceable status surface on the lock screen and in the Dynamic Island, updated in real time while a task is in flight (a timer running, a trip in progress, a reset underway). It ends on the natural completion event.

## When to use

- The app has a **bounded, in-progress activity** the user wants to track without opening the app — a countdown, a trip, a session.
- The activity has a clear, single **completion event** that ends it.
- The status fits in a glance: one or two numbers, a short label, a simple progress indicator.

## When NOT to use

- **There's no natural end.** A Live Activity that lingers until the 8-hour system timeout is worse than no Live Activity. If you can't name the event that ends it, don't ship it.
- **The update cadence is sub-second.** ActivityKit throttles updates; a stopwatch ticking every 10ms will look broken. Use a `Text(timerInterval:)` self-updating view instead of pushing updates.
- **It's really a notification.** One-shot "your thing is done" is a notification, not a Live Activity.
- **It would clutter the Lock Screen without earning it.** One shipped production app had a "logged for today" activity that just restated a saved fact — it lingered, was awkward to dismiss, and was eventually removed entirely. If the activity isn't tracking something genuinely *in flight* that the user wants to watch, it's clutter. A static info card is not a Live Activity.
- **Battery-cost denial.** Frequent updates cost power. If the activity updates more than ~once a minute, document the justification in `DECISIONS/004-native-feature-checklist.md`.
- **Harvesting LA *views* from a source flagged WIP.** Views whose strings resolve from the wrong bundle break on device. Use the template's `SeedLiveActivity.swift` for the views.

## How

### 1. Harvest

- Source: `templates/swift/SeedWidgets/SeedLiveActivity.swift` — the `ActivityConfiguration` with all five presentations. Also read `templates/swift/Seed/Services/_Disabled/LiveActivityService.swift` for the start/update/end service.
- Copy the LA view into `<App>/Widgets/<App>LiveActivity.swift`; copy the service into `<App>/Services/LiveActivityService.swift`.

> **Dark Lock Screen safety (hard-won production lesson).** The LA renders on the Lock Screen, which is usually dark. `WidgetTheme` MUST be appearance-adaptive (resolve a light/dark pair via a `UIColor { traits in … }` dynamic provider) — a fixed light-only widget palette paints dark-on-dark and reads as **black/blank** there; this shipped as a real focus-timer bug. Also guard `Text(timerInterval: Date()...endDate)` against a past `endDate` (invalid range → empty render). See `templates/swift/SeedWidgets/WidgetTheme.swift` — the template's version is appearance-adaptive.

### 2. Wire

- **Activity attributes:** define your `ActivityAttributes` struct with a `ContentState` carrying only what the surface shows.
- **All five presentations** (see [docs/WIDGETS.md](../../docs/WIDGETS.md) rule 4): compact leading, compact trailing, expanded, minimal, lock screen. Ship all five — `LiveActivityViewTests.swift` snapshots each.
  - Compact leading/trailing: an SF Symbol on leading, a tiny number on trailing. Never text labels in compact.
- **Localization:** strings load from the **widget extension's** bundle. Key them in `Widgets/Resources/Localizable.xcstrings`, not the app's.
- **Info.plist:** add `NSSupportsLiveActivities = YES` to the app target.
- **End it right:** call `activity.end(...)` on the real completion event with a final content state and `.immediate` dismissal policy. Don't rely on the system timeout.

### 3. Verify

```sh
xcodebuild test -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:<App>Tests/LiveActivityViewTests
```

Expected: all five presentations snapshot-match localized fixtures for `en es de fr pt ja zh-Hans`.

## Gotchas

- The Dynamic Island expanded layout has hard region size limits — test on the smallest device (iPhone 17, not Pro Max).
- `Activity.request(...)` throws if the user disabled Live Activities for the app — handle it, don't force-try.
- A stale `ContentState` after app termination: update from a background task or a push so the surface doesn't freeze mid-activity.
