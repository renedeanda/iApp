// SOURCE: whole-data wipe pattern proven in shipped production apps,
// aligned with the Swift template's DataDeletionService counterpart.
//
// These apps have no accounts; App Review nevertheless expects in-app deletion
// of the user's iCloud-stored app data (a real App Review rejection cited 5.1.1(v)).
// This is DATA deletion / user control, not the account-deletion requirement.
//
// App-specific TODOs when graduating this template:
// - add every AsyncStorage/domain key the app owns to LOCAL_DATA_KEYS
// - clear SQLite mirrors, image folders, retry queues, widget snapshots,
//   notifications, app locks, AI caches, location caches, and export temps
// - keep only explicit non-user-data allowlist keys
// - call retryPendingCloudDeletionIfNeeded() at app start, BEFORE enabling
//   sync; keep sync disabled while PENDING_CLOUD_DELETION_KEY is 'true'

import AsyncStorage from '@react-native-async-storage/async-storage';
import { Directory, Paths } from 'expo-file-system';
import * as Notifications from 'expo-notifications';
import { Platform } from 'react-native';

import { createICloudSync } from '@/modules/icloud-sync';

export const PENDING_CLOUD_DELETION_KEY = 'seed:pendingCloudDeletion';
export const PENDING_CLOUD_DELETION_USER_KEY = 'seed:pendingCloudDeletionUserRecordName';
export const DELETION_IN_PROGRESS_KEY = 'seed:deletionInProgress';

/** The in-progress marker is a timestamp, not a latch: a crash mid-deletion
 * must not leave widget/snapshot intake disabled forever, so it self-expires. */
const DELETION_IN_PROGRESS_TIMEOUT_MS = 5 * 60 * 1000;

const sync = createICloudSync();

const LOCAL_DATA_KEYS = [
  'settings.iCloudSyncEnabled',
  // TODO(app-data): add app-owned AsyncStorage keys here.
];

const LOCAL_DATA_DIRECTORIES = [
  new Directory(Paths.document, 'cloud-assets'),
  // TODO(app-data): add image/blob/cache directories here.
];

/** What actually happened — the result alert must never overstate. */
export type DeletionOutcome =
  /** Local data and the iCloud zone are both gone. */
  | 'fullyDeleted'
  /** Local data is gone; the iCloud zone delete failed transiently and is
   * queued (account-verified) to retry on the next launch. Sync stays
   * disabled until the retry lands. */
  | 'cloudPending'
  /** Local data is gone, but no signed-in iCloud account could be verified —
   * nothing is queued, because a blind retry could fire against a DIFFERENT
   * account later. The alert tells the user how to finish. */
  | 'cloudUnavailable'
  /** The local wipe itself failed; data may remain. */
  | 'localFailed';

export async function deleteAllAppData(): Promise<DeletionOutcome> {
  await AsyncStorage.setItem(DELETION_IN_PROGRESS_KEY, String(Date.now()));
  try {
    // Identity captured UP FRONT, at explicit request time. A fresh request
    // re-baselines it: the account signed in right now is the one whose
    // data the user asked to erase.
    const identity = Platform.OS === 'ios' ? await currentAccountIdentity() : null;

    const localDeleted = await deleteLocalData();

    if (Platform.OS !== 'ios') {
      await clearPendingCloudDeletion();
      return localDeleted ? 'fullyDeleted' : 'localFailed';
    }
    if (!localDeleted) {
      return 'localFailed';
    }
    if (!identity) {
      // No signed-in account to verify — never queue a blind retry. A
      // pending marker without a captured identity can never be safely
      // resolved and would wedge sync off forever.
      await clearPendingCloudDeletion();
      return 'cloudUnavailable';
    }

    await AsyncStorage.setItem(PENDING_CLOUD_DELETION_USER_KEY, identity);
    if (await deleteCloudZone()) {
      await clearPendingCloudDeletion();
      return 'fullyDeleted';
    }
    await AsyncStorage.setItem(PENDING_CLOUD_DELETION_KEY, 'true');
    return 'cloudPending';
  } finally {
    await AsyncStorage.removeItem(DELETION_IN_PROGRESS_KEY);
  }
}

/**
 * Launch-time retry for a queued cloud deletion. Fires only when the
 * signed-in account matches the identity captured when the user asked —
 * a pending deletion must never touch a different account's data.
 */
export async function retryPendingCloudDeletionIfNeeded(): Promise<void> {
  const pending = await AsyncStorage.getItem(PENDING_CLOUD_DELETION_KEY);
  if (pending !== 'true') return;
  const expected = await AsyncStorage.getItem(PENDING_CLOUD_DELETION_USER_KEY);
  if (!expected) {
    // Pending state without a captured identity can never be safely verified
    // against any account — drop it instead of deadlocking the retry (and
    // the sync gate) forever. The user can always delete again while signed in.
    await clearPendingCloudDeletion();
    return;
  }
  const current = await currentAccountIdentity();
  if (!current || current !== expected) return;
  if (await deleteCloudZone()) {
    await clearPendingCloudDeletion();
  }
}

/** True while a deletion started recently and hasn't finished. A crash
 * mid-deletion leaves the key behind; the timestamp check keeps that from
 * bricking snapshot/intent intake forever. (A legacy 'true' value fails to
 * parse and reads as expired.) */
export async function isDeletionInProgress(): Promise<boolean> {
  const raw = await AsyncStorage.getItem(DELETION_IN_PROGRESS_KEY);
  if (!raw) return false;
  const startedAt = Number(raw);
  if (!Number.isFinite(startedAt) || startedAt <= 0) return false;
  return Math.abs(Date.now() - startedAt) < DELETION_IN_PROGRESS_TIMEOUT_MS;
}

// ── internals ──────────────────────────────────────────────────────────────

/** The signed-in iCloud account's stable user record name, or null when no
 * account is available or reachable. */
async function currentAccountIdentity(): Promise<string | null> {
  try {
    if (!(await sync.isAvailable())) return null;
    return (await sync.currentUserRecordName?.()) ?? null;
  } catch {
    return null;
  }
}

/** Custom zone + subscription + tokens; "already gone" counts as success. */
async function deleteCloudZone(): Promise<boolean> {
  try {
    return (await sync.deleteAllData()) === true;
  } catch {
    // Offline or CloudKit transient failure — caller queues an
    // account-verified retry.
    return false;
  }
}

async function deleteLocalData(): Promise<boolean> {
  try {
    await Notifications.cancelAllScheduledNotificationsAsync().catch(() => undefined);
    await Promise.all(LOCAL_DATA_DIRECTORIES.map((dir) => deleteDirectoryIfPresent(dir)));
    // NEVER remove PENDING_CLOUD_DELETION_* or DELETION_IN_PROGRESS_KEY here —
    // the retry bookkeeping must survive the local wipe.
    await AsyncStorage.multiRemove(LOCAL_DATA_KEYS);
    return true;
  } catch {
    return false;
  }
}

async function clearPendingCloudDeletion(): Promise<void> {
  await AsyncStorage.multiRemove([
    PENDING_CLOUD_DELETION_KEY,
    PENDING_CLOUD_DELETION_USER_KEY,
  ]);
}

async function deleteDirectoryIfPresent(directory: Directory): Promise<void> {
  try {
    if (directory.exists) {
      directory.delete();
    }
  } catch {
    // Best effort: local caches should never block the irreversible data wipe.
  }
}
