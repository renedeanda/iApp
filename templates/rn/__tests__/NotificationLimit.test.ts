// SOURCE: iApp template — verifies the rolling-window math in
//         NotificationService stays inside iOS's 64-notification cap
//         across realistic reminder counts.

import { Platform } from 'react-native';
import { computeOccurrences, Reminder } from '@/src/services/NotificationService';

const IOS_LIMIT = 64;

// Jest's react-native preset defaults Platform.OS to 'ios'; tests below
// assume iOS unless they explicitly mock Android.
beforeAll(() => {
  Object.defineProperty(Platform, 'OS', { get: () => 'ios' });
});

function reminderForYearly(monthsFromNow: number, id: string): Reminder {
  const date = new Date();
  date.setMonth(date.getMonth() + monthsFromNow);
  return {
    id,
    title: 'Test',
    body: 'Test body',
    date,
    recurrence: 'yearly',
  };
}

describe('Notification rolling window', () => {
  test('yearly reminder produces at most 2 occurrences on iOS', () => {
    const occurrences = computeOccurrences(reminderForYearly(2, 'r1'));
    expect(occurrences.length).toBeLessThanOrEqual(2);
  });

  test('30 yearly reminders fit within the 64-notification iOS cap', () => {
    let total = 0;
    for (let i = 0; i < 30; i++) {
      const reminder = reminderForYearly((i % 12) + 1, `r${i}`);
      total += computeOccurrences(reminder).length;
    }
    expect(total).toBeLessThanOrEqual(IOS_LIMIT);
  });

  test('a one-shot reminder in the past produces zero occurrences', () => {
    const past = new Date();
    past.setFullYear(past.getFullYear() - 1);
    const occurrences = computeOccurrences({
      id: 'past',
      title: 'a',
      body: 'b',
      date: past,
      recurrence: 'once',
    });
    expect(occurrences).toEqual([]);
  });

  test('a one-shot reminder in the future produces exactly one', () => {
    const future = new Date();
    future.setMonth(future.getMonth() + 1);
    const occurrences = computeOccurrences({
      id: 'future',
      title: 'a',
      body: 'b',
      date: future,
      recurrence: 'once',
    });
    expect(occurrences.length).toBe(1);
  });

  test('default hour is 9 AM local', () => {
    const future = new Date();
    future.setDate(future.getDate() + 30);
    const occurrences = computeOccurrences({
      id: 'morning',
      title: 'a',
      body: 'b',
      date: future,
      recurrence: 'once',
    });
    expect(occurrences[0]?.getHours()).toBe(9);
    expect(occurrences[0]?.getMinutes()).toBe(0);
  });

  test('explicit hour/minute overrides the 9 AM default', () => {
    const future = new Date();
    future.setDate(future.getDate() + 30);
    const occurrences = computeOccurrences({
      id: 'evening',
      title: 'a',
      body: 'b',
      date: future,
      recurrence: 'once',
      hour: 20,
      minute: 30,
    });
    expect(occurrences[0]?.getHours()).toBe(20);
    expect(occurrences[0]?.getMinutes()).toBe(30);
  });

  test('daily reminder caps at 14 occurrences (rolling fortnight)', () => {
    const start = new Date();
    const occurrences = computeOccurrences({
      id: 'daily',
      title: 'a',
      body: 'b',
      date: start,
      recurrence: 'daily',
    });
    expect(occurrences.length).toBeLessThanOrEqual(14);
  });
});
