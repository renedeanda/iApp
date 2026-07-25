# Add local notifications (RN)

> **Source:** `templates/rn/src/services/NotificationService.ts` (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** React Native (Expo)
> **Reliability:** ✅ gold-standard — the rolling 64-limit window pattern, harvested verbatim from a shipped production app and genericized.

## What it adds

A `NotificationService` (already in the template at `src/services/NotificationService.ts`) that schedules one-shot and recurring local notifications via `expo-notifications`, while staying inside iOS's 64-pending-notification cap using a rolling-window horizon that auto-reschedules from the notification-received handler.

## When to use

- The app has a **user-set, time-anchored reason** to reach the user — a reminder they created, a date that matters to them.
- The reminder is **recurring** (yearly, monthly, daily) and naive scheduling would blow past 64 pending slots.
- The content is specific and actionable — not "come back".

## When NOT to use

- **Engagement / retention pings.** "You haven't opened the app in 3 days" is the dark pattern `docs/NOT_FOR.md` forbids.
- **Requesting permission at launch.** Ask at the moment the user sets their first reminder, not before they understand why.
- **Scheduling unboundedly.** iOS silently drops past 64 pending. The whole point of this service is the rolling window — don't bypass `NotificationService.schedule()` with raw `scheduleNotificationAsync` calls.
- **Notifications with no off switch.** Each category maps to a setting the app actually respects.

## How

### 1. Harvest

- Already in the template: `src/services/NotificationService.ts` (genericized from a shipped production app). The pure scheduling math is `computeOccurrences()`; the side-effecting layer is the `NotificationService` class.
- If you need richer reminder modeling, see [add-rn-reminders](add-rn-reminders.md) for the fuller domain layer.

### 2. Wire

- **Authorization:** request via `Notifications.requestPermissionsAsync()` at the first-reminder moment. Handle denial gracefully — the feature degrades, the app doesn't break.
- **Schedule:** build a `Reminder` (`id`, `title`, `body`, `date`, `recurrence`, optional `hour`/`minute`) and call `NotificationService.schedule(reminder)`. It cancels the prior occurrences for that `id` prefix first, so the call is idempotent.
- **Rolling window:** `computeOccurrences` bounds each recurring reminder (2 years iOS / 3 Android for yearly, 24 months for monthly, 14 days for daily). The received-handler calls `NotificationService.handleReceived(...)` to top the window back up.
- **Headroom check:** call `NotificationService.pendingCount()` before adding a new reminder; abort + warn the caller when within ~8 slots of 64.
- **Localization:** `title`/`body` are localized by the **caller** via `t()` before being passed in — the service is i18n-agnostic.
- **Cancellation:** `cancelByPrefix(id)` when the user deletes the underlying reminder; `cancelAll()` for sign-out.

### 3. Verify

```sh
npx jest NotificationLimit
```

Expected: green — yearly reminders produce ≤ 2 occurrences, 30 yearly reminders stay ≤ 64 total, past one-shots produce zero, the 9 AM default and explicit hour/minute overrides both resolve correctly.

## Gotchas

- The Simulator delivers local notifications but timing is unreliable — verify date-anchored triggers on a device.
- `computeOccurrences` takes an injectable `now` parameter — that's what makes it unit-testable. Don't add a bare `new Date()` inside it.
- `SchedulableTriggerInputTypes.DATE` triggers fire once; recurrence is *simulated* by scheduling N future occurrences, which is why the rolling-window top-up matters.
- Android's notification limit is effectively higher, hence the 3-year window there — but the code path is shared; don't special-case it beyond `computeWindowYears()`.
