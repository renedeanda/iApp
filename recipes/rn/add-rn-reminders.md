# Add reminder scheduling (RN)

> **Source:** *pattern described inline* — a ~30 KB reminder-domain service proven in a shipped production RN app (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** React Native (Expo)
> **Reliability:** ✅ gold-standard — ships whole; apps that don't need it delete it.

## What it adds

A `ReminderService` — the full reminder-modeling layer above raw notifications. Where [add-rn-notifications](add-rn-notifications.md) handles *scheduling* (the 64-cap rolling window), `ReminderService` handles the *domain*: reminder entities, recurrence rules, snooze, per-reminder enable/disable, and persistence.

## When to use

- Reminders are a **core feature**, not a side capability — the app is partly *about* reminders (a birthday-reminder app, a habit app, a medication tracker).
- Users **create, edit, snooze, and toggle** individual reminders — there's real CRUD, not just "fire at time X".
- You need reminders to **persist and survive** app restarts, with their schedules rebuilt on launch.

## When NOT to use

- **One or two fixed notifications.** If the app just needs "remind me at 9 AM daily", use `NotificationService` directly (see [add-rn-notifications](add-rn-notifications.md)). `ReminderService` is 30 KB — don't pull it in for two notifications.
- **Engagement reminders.** Same `docs/NOT_FOR.md` rule as all notifications — reminders are user-set utility/care, never retention nags.
- **As a general scheduler.** It models *reminders*. Background sync, periodic refresh — that's `expo-background-task`, not this.
- **Keeping it when it's unused.** The recipe says "ships whole; apps that don't need it delete it." A dormant 30 KB service is dead weight — delete it if reminders aren't core.

## How

### 1. Harvest

- The shape (proven in production): a domain service composing `NotificationService` (scheduling) + `StorageService` (persistence) — the Wire section below carries the structure.
- Create: `src/services/ReminderService.ts`. It depends on [add-rn-storage](add-rn-storage.md) and [add-rn-notifications](add-rn-notifications.md) — wire those first.

### 2. Wire

- **Reminder entity:** a typed `Reminder` model (id, title, body, schedule rule, enabled flag, snooze state) persisted via `StorageService` under a namespaced key.
- **Recurrence:** the service translates a reminder's recurrence rule into the `Reminder` shape `NotificationService.schedule()` expects, then delegates — it does **not** reimplement the 64-cap math.
- **Rebuild on launch:** on app start, the service reads all persisted reminders and re-syncs their notifications (the OS may have dropped them, or the rolling window needs topping up).
- **Snooze:** snoozing cancels the current occurrence and schedules a one-shot at `now + snoozeInterval`, without disturbing the recurring schedule.
- **Toggle:** disabling a reminder cancels its notifications by prefix but keeps the entity; enabling re-schedules.
- **i18n:** titles/bodies are localized by the caller via `t()` before scheduling.

### 3. Verify

```sh
npx jest
npm run typecheck
```

Expected: type-clean; tests cover create → persists + schedules, toggle off → cancels but keeps entity, snooze → one-shot without breaking recurrence, relaunch → schedules rebuilt. The underlying `NotificationLimit` test still passes (the 64-cap holds across realistic reminder counts).

## Gotchas

- `ReminderService` is a *composition* — its correctness depends on `NotificationService` and `StorageService` being correct first. Don't debug it in isolation.
- The launch-time rebuild must be idempotent — running it twice (cold start + a quick background/foreground) must not double-schedule.
- Snooze state is per-occurrence, not per-reminder — persist it carefully or a snoozed reminder "un-snoozes" on relaunch.
- 30 KB is a lot of surface; if the app only uses a third of it, that's a signal to delete the unused two-thirds rather than carry them.
