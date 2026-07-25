// SOURCE: harvested from a shipped production app's iCloud bridge
// (clean Expo module shape), genericized for reuse.
//
// Generic CloudKit private-database sync. Drop-in replacement: any
// record shape with a string `id` field syncs.
//
// Reusable across apps. Eventually publishable to npm as
// `@example/expo-icloud-sync`.

import { Platform } from 'react-native';
import { requireNativeModule } from 'expo-modules-core';

/**
 * A record that can sync via ICloudSync. The only requirement is a
 * string `id`. All other top-level fields must be JSON-serializable
 * primitives (string, number, boolean) — nested objects / arrays are
 * NOT synced and will be dropped silently.
 *
 * Special key: `__assetPath` is the absolute on-device file path to a
 * binary asset (e.g. cover photo). It's translated to a CKAsset
 * server-side and back to an absolute path on read.
 */
export interface SyncableRecord {
  id: string;
  [key: string]: string | number | boolean | undefined | null;
}

export interface SaveManyResult {
  saved: number;
  failed: number;
}

export interface FetchChangesResult<T extends SyncableRecord = SyncableRecord> {
  changed: T[];
  deleted: string[];
}

export interface ICloudSyncAPI<T extends SyncableRecord = SyncableRecord> {
  /**
   * Whether the user is signed into iCloud on this device.
   * Resolves false on non-iOS or when the user has signed out.
   */
  isAvailable(): Promise<boolean>;

  /**
   * Stable CloudKit user record name for the current iCloud account. Used to
   * keep pending deletion retries from targeting a different account after
   * an iCloud sign-out/sign-in.
   */
  currentUserRecordName?(): Promise<string | null>;

  /**
   * Create the custom record zone + silent-push subscription. Idempotent
   * — safe to call on every app launch.
   */
  setup(): Promise<boolean>;

  /**
   * Save a single record. Existing fields not present on the new record
   * are kept (CKModifyRecordsOperation .changedKeys policy).
   */
  saveOne(record: T): Promise<boolean>;

  /**
   * Save many. Chunked at 400/op per CloudKit's limit. Returns
   * aggregated counts.
   */
  saveMany(records: T[]): Promise<SaveManyResult>;

  /**
   * Initial pull: every record in the zone, regardless of change state.
   * Expensive — prefer `fetchChanges` after the first sync.
   */
  fetchAll(): Promise<T[]>;

  /**
   * Incremental pull using the persisted server change token. First
   * call (no token yet) returns everything; subsequent calls return
   * only what changed. Token-expired errors clear the token so the
   * next call does a full re-pull.
   */
  fetchChanges(): Promise<FetchChangesResult<T>>;

  /**
   * Delete by id. "Already gone" is treated as success (idempotent).
   */
  deleteOne(id: string): Promise<boolean>;

  /**
   * Delete the custom CloudKit zone, silent-push subscription, and
   * local sync tokens. Call before wiping local state so old cloud data
   * cannot later resurrect. Treats "already gone" as success.
   */
  deleteAllData(): Promise<boolean>;

  /**
   * Drop the change token + zone-created flag. Next setup() recreates
   * the zone; next fetch* does a full pull. Useful for sign-out flows.
   */
  resetSyncState(): Promise<boolean>;

  /**
   * Subscribe to remote-change events. The native side fires `onChange`
   * for CKAccountChanged + any silent push delivered via the
   * subscription. Returns an unsubscribe function.
   */
  addChangeListener(cb: () => void): () => void;
}

// ─── Stub implementation for non-iOS + missing-native fallbacks ──────

function noopUnsubscribe(): void {}

const stub: ICloudSyncAPI = {
  isAvailable: async () => false,
  currentUserRecordName: async () => null,
  setup: async () => false,
  saveOne: async () => false,
  saveMany: async () => ({ saved: 0, failed: 0 }),
  fetchAll: async () => [],
  fetchChanges: async () => ({ changed: [], deleted: [] }),
  deleteOne: async () => false,
  deleteAllData: async () => false,
  resetSyncState: async () => false,
  addChangeListener: () => noopUnsubscribe,
};

// ─── Native binding ──────────────────────────────────────────────────

// In Expo SDK 54+ a native module returned by `requireNativeModule` is
// itself the event emitter — it exposes `addListener` directly, which
// returns a subscription with `.remove()`. (The old
// `new EventEmitter(nativeModule)` wrapper was removed.)
type NativeICloudSync = Omit<ICloudSyncAPI, 'addChangeListener'> & {
  addListener(event: string, listener: () => void): { remove(): void };
};

let native: NativeICloudSync | null = null;

if (Platform.OS === 'ios') {
  try {
    native = requireNativeModule('ICloudSync') as NativeICloudSync;
  } catch (e) {
    // The native module is wired via `expo-modules-autolinking`. If the
    // pod hasn't been installed yet (fresh checkout, no `pod install`),
    // the require throws — fall back to the stub so JS doesn't crash.
    // eslint-disable-next-line no-console
    console.warn(
      '[ICloudSync] Native module not available. Run `pod install` in ios/ and rebuild. iCloud sync disabled.',
      e
    );
  }
}

/**
 * Factory: build a typed sync client for a specific record shape.
 *
 * @example
 * type Note = SyncableRecord & { title: string; body: string };
 * const sync = createICloudSync<Note>();
 * await sync.setup();
 * await sync.saveOne({ id: 'abc', title: 'Hi', body: 'There' });
 */
export function createICloudSync<T extends SyncableRecord = SyncableRecord>(): ICloudSyncAPI<T> {
  const impl = native ?? stub;

  const addChangeListener = (cb: () => void): (() => void) => {
    if (!native) return noopUnsubscribe;
    const sub = native.addListener('onChange', cb);
    return () => sub.remove();
  };

  return {
    isAvailable: () => impl.isAvailable(),
    setup: () => impl.setup(),
    saveOne: (record) => impl.saveOne(record),
    saveMany: (records) => impl.saveMany(records as unknown as SyncableRecord[]) as Promise<SaveManyResult>,
    fetchAll: () => impl.fetchAll() as Promise<T[]>,
    fetchChanges: () => impl.fetchChanges() as Promise<FetchChangesResult<T>>,
    deleteOne: (id) => impl.deleteOne(id),
    deleteAllData: () => impl.deleteAllData(),
    resetSyncState: () => impl.resetSyncState(),
    addChangeListener,
  };
}

// Default untyped export for callers that don't need generics.
export default createICloudSync();
