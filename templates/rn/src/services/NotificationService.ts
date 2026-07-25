// SOURCE: harvested from a shipped production reminders app.
// Genericized: domain-specific birthday logic replaced with a generic
// Reminder shape so any app can schedule recurring or one-shot
// notifications while staying inside the iOS 64-notification limit.
//
// Why this exists: iOS caps each app at 64 pending local notifications.
// Apps that schedule recurring reminders (birthdays, anniversaries,
// habit pings, refill dates) routinely exceed this naively. The
// rolling-window pattern below uses a year-bounded horizon (default
// 2 years on iOS, 3 on Android) per reminder, then reschedules the
// next occurrence inside the notification-received handler.

import * as Notifications from 'expo-notifications';
import { Platform } from 'react-native';

const ROLLING_WINDOW_YEARS_IOS = 2;
const ROLLING_WINDOW_YEARS_ANDROID = 3;
const DEFAULT_HOUR = 9;
const DEFAULT_MINUTE = 0;

/** Recurrence cadence. */
export type Recurrence = 'once' | 'yearly' | 'monthly' | 'daily';

/**
 * One scheduled reminder. Identifier convention: `<prefix>-<entityId>`
 * so an app can cancel everything for an entity via prefix match
 * without tracking system identifiers.
 */
export interface Reminder {
  /** Stable identifier; used as the notification prefix. */
  id: string;
  /** Notification title (localized by the caller via i18next). */
  title: string;
  /** Notification body (localized by the caller). */
  body: string;
  /** First fire date. Must be in the future for `once` reminders. */
  date: Date;
  /** Cadence; `yearly` is the most common. */
  recurrence: Recurrence;
  /** Optional hour-of-day override (defaults to 9 AM local). */
  hour?: number;
  /** Optional minute-of-hour override (defaults to 0). */
  minute?: number;
  /**
   * Optional metadata round-tripped through the OS so the
   * notification-received handler can identify the source entity.
   */
  data?: Record<string, string | number | boolean>;
}

const PREFIX_SEPARATOR = '::';

function buildIdentifier(prefix: string, occurrenceYear: number): string {
  return `${prefix}${PREFIX_SEPARATOR}${occurrenceYear}`;
}

function entityPrefixFromIdentifier(identifier: string): string {
  const idx = identifier.indexOf(PREFIX_SEPARATOR);
  return idx === -1 ? identifier : identifier.slice(0, idx);
}

function computeWindowYears(): number {
  return Platform.OS === 'android'
    ? ROLLING_WINDOW_YEARS_ANDROID
    : ROLLING_WINDOW_YEARS_IOS;
}

/**
 * Compute the next N occurrence dates for a reminder inside the
 * rolling window. Pure function — no Notifications side effects.
 *
 * NOTE: built with `setHours/setMinutes` (not the `new Date(y,m,d,h,m)`
 * constructor) because the constructor's TZ behavior on iOS is
 * inconsistent with what users expect — `9 AM local` is the goal and
 * the setter approach reliably lands there.
 */
export function computeOccurrences(reminder: Reminder, now: Date = new Date()): Date[] {
  const hour = reminder.hour ?? DEFAULT_HOUR;
  const minute = reminder.minute ?? DEFAULT_MINUTE;

  const seed = new Date(reminder.date.getTime());
  seed.setHours(hour, minute, 0, 0);

  if (reminder.recurrence === 'once') {
    return seed > now ? [seed] : [];
  }

  const yearsAhead = computeWindowYears();
  const occurrences: Date[] = [];

  if (reminder.recurrence === 'yearly') {
    for (let yearOffset = 0; yearOffset < yearsAhead; yearOffset++) {
      const candidate = new Date();
      candidate.setFullYear(now.getFullYear() + yearOffset);
      candidate.setMonth(seed.getMonth());
      candidate.setDate(seed.getDate());
      candidate.setHours(hour, minute, 0, 0);
      if (candidate > now) occurrences.push(candidate);
    }
  } else if (reminder.recurrence === 'monthly') {
    // 24 months on iOS (= 64 / 2 with budget left over for daily).
    const monthsAhead = yearsAhead * 12;
    for (let monthOffset = 0; monthOffset < monthsAhead; monthOffset++) {
      const candidate = new Date(now.getTime());
      candidate.setMonth(now.getMonth() + monthOffset);
      candidate.setDate(seed.getDate());
      candidate.setHours(hour, minute, 0, 0);
      if (candidate > now) occurrences.push(candidate);
    }
  } else if (reminder.recurrence === 'daily') {
    // 14-day rolling window — short enough to coexist with other
    // recurring reminders within the 64-notification cap.
    for (let dayOffset = 0; dayOffset < 14; dayOffset++) {
      const candidate = new Date(now.getTime());
      candidate.setDate(now.getDate() + dayOffset);
      candidate.setHours(hour, minute, 0, 0);
      if (candidate > now) occurrences.push(candidate);
    }
  }

  return occurrences;
}

export class NotificationService {
  /**
   * Schedule a reminder's rolling-window occurrences. Cancels any
   * existing notifications with the same `id` prefix before scheduling
   * so calling this twice in a row is idempotent.
   */
  static async schedule(reminder: Reminder): Promise<string[]> {
    await this.cancelByPrefix(reminder.id);

    const occurrences = computeOccurrences(reminder);
    const identifiers: string[] = [];

    for (const date of occurrences) {
      const identifier = buildIdentifier(reminder.id, date.getFullYear());
      try {
        await Notifications.scheduleNotificationAsync({
          identifier,
          content: {
            title: reminder.title,
            body: reminder.body,
            data: {
              ...reminder.data,
              __reminderPrefix: reminder.id,
              __reminderRecurrence: reminder.recurrence,
            },
          },
          trigger: { type: Notifications.SchedulableTriggerInputTypes.DATE, date },
        });
        identifiers.push(identifier);
      } catch (error) {
        // eslint-disable-next-line no-console
        console.warn(`[NotificationService] schedule failed for ${identifier}:`, error);
      }
    }
    return identifiers;
  }

  /**
   * Cancel every pending notification whose identifier shares this
   * prefix. Cheaper than tracking system identifiers in app state.
   */
  static async cancelByPrefix(prefix: string): Promise<void> {
    const scheduled = await Notifications.getAllScheduledNotificationsAsync();
    const toCancel = scheduled.filter(
      (n) => entityPrefixFromIdentifier(n.identifier) === prefix
    );
    await Promise.all(
      toCancel.map((n) => Notifications.cancelScheduledNotificationAsync(n.identifier))
    );
  }

  /** Cancel everything. Useful for sign-out flows. */
  static async cancelAll(): Promise<void> {
    await Notifications.cancelAllScheduledNotificationsAsync();
  }

  /**
   * Called from the foreground notification-received handler (or the
   * background-task handler). Looks at the recurrence metadata and
   * schedules the next year/month/day so the rolling window stays
   * topped up. Without this, the window drains over time and the user
   * stops getting reminders.
   */
  static async handleReceived(
    notification: Notifications.Notification,
    rebuild: (prefix: string) => Reminder | null
  ): Promise<void> {
    const data = notification.request.content.data as Record<string, unknown> | undefined;
    const prefix = data?.__reminderPrefix as string | undefined;
    const recurrence = data?.__reminderRecurrence as Recurrence | undefined;
    if (!prefix || !recurrence || recurrence === 'once') return;

    const reminder = rebuild(prefix);
    if (!reminder) return;
    await this.schedule(reminder);
  }

  /**
   * Count of pending notifications. Use to check headroom before
   * scheduling a new reminder; abort + warn the caller when within
   * 8 slots of the 64-limit.
   */
  static async pendingCount(): Promise<number> {
    const scheduled = await Notifications.getAllScheduledNotificationsAsync();
    return scheduled.length;
  }
}
