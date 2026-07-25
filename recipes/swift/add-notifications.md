# Add local notifications

> **Source:** `templates/swift/Seed/Services/_Disabled/NotificationService.swift` (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** Swift
> **Reliability:** ✅ gold-standard — a clean, opt-in pattern proven in production.

## What it adds

A `NotificationService` that requests authorization at the right moment, schedules local notifications, and stays inside iOS's 64-pending-notification cap. Opt-in, throttled, and framed as utility/care — never as a re-engagement nag.

## When to use

- The app has a **genuinely time-anchored reason** to reach the user — a reminder they set, a session they scheduled, a date that matters to *them*.
- Notifications are **user-initiated** — the user asked for this reminder.
- The content is **specific and actionable**, not "come back!".

## When NOT to use

- **Engagement / retention notifications.** "You haven't opened the app in 3 days" is exactly the dark pattern `docs/NOT_FOR.md` forbids. Read NOT_FOR.md and WHATS_ALLOWED.md before adding any notification.
- **Requesting authorization at launch.** Asking for notification permission before the user understands why tanks the grant rate. Request it at the moment the user sets their first reminder.
- **Scheduling unboundedly.** iOS caps pending notifications at 64. Recurring reminders need a rolling window (see the RN `NotificationService` for the same discipline) — don't schedule 200 and let the OS silently drop them.
- **Notifications the user can't turn off.** Every notification category maps to a Settings toggle the app actually respects.

## How

### 1. Harvest

- Source: `templates/swift/Seed/Services/_Disabled/NotificationService.swift` — read it for the authorization-timing and scheduling shape.
- In a generated app it ships in `Services/_Disabled/` — move it up to `<App>/Services/NotificationService.swift`.

### 2. Wire

- **Authorization:** request at the *use* moment (first reminder set), not at launch. Handle `.denied` gracefully — the feature degrades, it doesn't break.
- **Scheduling:** `UNUserNotificationCenter` with `UNCalendarNotificationTrigger` for date-anchored reminders. Content strings come from `Localizable.xcstrings`.
- **64-cap discipline:** before scheduling, check `getPendingNotificationRequests` count. For recurring reminders, schedule a bounded window and top it up — never assume infinite slots.
- **Settings:** each notification type respects a Settings toggle. A toggle that doesn't actually gate the notification is a bug.
- **Cancellation:** removing the underlying reason (deleting the reminder) cancels its pending notifications by identifier.

### 3. Verify

```sh
xcodebuild test -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:<App>Tests/NotificationServiceTests
```

Expected: tests green — scheduling math stays ≤ 64 pending across realistic reminder counts; cancellation removes the right identifiers; denied-authorization path doesn't crash.

## Gotchas

- The Simulator delivers local notifications but timing can be unreliable — verify date-anchored triggers on a device.
- `UNCalendarNotificationTrigger` with `repeats: true` counts as **one** pending slot but only the *next* fire — fine for a simple daily, not enough for "every birthday in my list".
- Notification content is localized from the **app** bundle (unlike widgets) — but if a notification deep-links into a Live Activity, that surface's strings still come from the extension bundle.
- Provisional authorization (`.provisional`) delivers quietly to Notification Center without a prompt — useful, but the user still needs a clear way to promote or silence it.
