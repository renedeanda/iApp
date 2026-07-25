# Add timers (countdown / elapsed)

> **Source:** `templates/swift/Seed/Services/_Disabled/NotificationService.swift` (completion alert) + `templates/swift/Seed/Services/_Disabled/LiveActivityService.swift` (lock-screen countdown) — confirm against [`REUSE_INDEX`](../../portfolio/REUSE_INDEX.md). The in-app timer pattern below is inline (production-proven).
> **Platform:** Swift
> **Reliability:** ✅ for the cited services; in-app pattern proven in shipped timer-driven apps.

## What it adds

A correct in-app timer — countdown or elapsed — that survives backgrounding, never drifts, and alerts the user even when the app is closed. Timers show up in a huge share of app ideas (focus sessions, workouts, practice, chores, games), and almost everyone builds them wrong the same way: ticking an accumulator with `Timer` and losing time whenever iOS suspends the app.

## When to use

- A task in your app has a real duration the user cares about finishing.
- The user might leave the app mid-timer (they will) and must still be told when it ends.
- Pair with a Live Activity when glancing at remaining time *without opening the app* is the whole point.

## When NOT to use

- **As engagement pressure.** A countdown that exists to rush the user into a purchase or streak is a dark pattern — see [docs/NOT_FOR.md](../../docs/NOT_FOR.md). Timers serve the user's task, not your funnel.
- **Expecting to run code in the background.** iOS will not let an ordinary app tick while suspended. If your feature needs *continuous background computation* (not just an end-time alert), you're building against the platform — redesign around the end-date pattern below.
- **Sub-second display precision.** Driving a label at 60 fps from a `Timer` burns battery for nothing; `Text(timerInterval:)` lets the system render the countdown with zero timers of your own.

## How

### 1. Harvest

- `templates/swift/Seed/Services/_Disabled/NotificationService.swift` — move up + enable per its header; the timer's completion alert is one scheduled local notification.
- Optional glanceability: [add-live-activity](add-live-activity.md) with `templates/swift/Seed/Services/_Disabled/LiveActivityService.swift`.

### 2. Wire

**The one rule: store the end `Date`, never accumulate ticks.**

```swift
@Observable @MainActor
final class TimerSession {
    private(set) var endDate: Date?

    var isRunning: Bool { endDate.map { $0 > .now } ?? false }

    func start(minutes: Int) {
        let end = Date.now.addingTimeInterval(TimeInterval(minutes * 60))
        endDate = end
        Task { await NotificationService.shared.scheduleTimerDone(at: end) }  // fires even if the app dies
    }

    func cancel() {
        endDate = nil
        Task { await NotificationService.shared.cancelTimerDone() }
    }
}
```

- **Display without ticking:** `Text(timerInterval: .now...end, countsDown: true)` — the system updates it, including in widgets and Live Activities.
- **Backgrounding costs nothing:** on foreground return, the remaining time is just `end.timeIntervalSinceNow`. Persist `endDate` (UserDefaults or your model) so force-quit + relaunch restores the session.
- The scheduled notification *is* the completion signal; in-app, also observe `endDate` passing and fire your completion delight moment (`Theme/DelightMoments.swift`) + one earned haptic.

### 3. Verify

```sh
xcodebuild test -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Expected: build green; unit-test `TimerSession` with injected dates. Manual: start a 1-minute timer, background the app, lock the phone — the notification arrives on time; reopen mid-run — remaining time is correct to the second.

## Gotchas

- Every scheduled completion counts against the **64 pending-notification cap** — if your app also schedules reminders, route both through the one `NotificationService` so the rolling-window logic sees everything.
- Respect Reduce Motion on any animated ring/progress treatment — `motionSafeAnimation()` via `templates/swift/Seed/Theme/MotionSafe.swift`.
- Pausing a countdown = store remaining seconds and clear `endDate`; resuming = mint a fresh `endDate`. Don't try to "freeze" a date.
- Device clock changes (time zones, DST) are handled free when you compare against `Date.now`; they break accumulator timers.
