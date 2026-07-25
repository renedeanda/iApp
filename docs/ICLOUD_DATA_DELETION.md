# iCloud Data Deletion Template

Use this when a generated app enables CloudKit, SwiftData CloudKit mirroring,
NSUbiquitousKeyValueStore, iCloud Drive, CKShare, or app-group/widget snapshots
derived from iCloud-backed data.

Framing: accountless apps mean Guideline 5.1.1(v)'s account-deletion
requirement doesn't strictly apply — but App Review has cited it for
iCloud-stored app data anyway (a real rejection we ate). Ship it as DATA
deletion / user control; never call it "account deletion" in UX copy.

Reference implementations:
`templates/swift/Seed/Services/_Disabled/DataDeletionService.swift` (Swift) +
`templates/rn/src/services/DataDeletionService.ts` (RN) — both distilled from
a shipped production implementation.

## When NOT to use

- Local-only apps with no iCloud footprint (no CloudKit, no KVS, no iCloud
  Drive): a plain local wipe + the Debug "Clear All Data" pattern is enough —
  don't ship the pending-cloud retry machinery for data that never leaves the
  device.
- Deleting a single record or a user-picked subset: that's ordinary CRUD, not
  this whole-data pattern (no confirmation ladder, no zone delete).
- CKShare *participant* data you don't own: never claim to delete another
  user's private zone — detach the local copy and subscriptions instead (see
  Deletion order, step 4).

## UX contract

- Add Settings -> Data -> Data & Backup -> Delete All Data. The root Settings
  page should show a neutral row; the destructive red row lives one level
  deeper to avoid accidental data loss.
- Keep it visible signed in, signed out, free, and paid.
- Use one destructive confirmation: "This cannot be undone." For SwiftUI apps,
  use a centered `.alert` for the final full-wipe confirmation; do not use
  `.confirmationDialog`, because on iPhone it can render as an anchored popover
  behind or over sheets and makes a dangerous action feel casual. Contextual
  per-item deletes may still use menus/dialogs where the platform pattern fits.
- Attach the full-wipe confirmation and result alerts to the visible Data/Delete
  destination that owns the destructive row. Do not keep the alert modifier on
  the parent Settings list while the button lives inside a pushed screen, or the
  alert can appear behind the destination after back navigation.
- Avoid "Data" -> "Data" navigation. Use a neutral root section such as Data and
  a specific destination label such as Data Controls, Delete Data, or Data &
  Backup only when that screen actually contains backup controls.
- Write app-scoped copy: name the app-owned records/files/preferences being
  deleted, and explicitly say what is not touched when confusion is likely
  (Photos library, Contacts, Calendar, Reminders, Health, Files outside the app,
  system Location history, partner-owned CloudKit zones, or other apps' data).
- Match purchase wording to the product: no purchase line for free/tip-jar apps;
  one-time IAP copy says it is not refunded/removed; subscription copy says
  subscriptions are not canceled/refunded and links to Manage Subscription.
- Offer export/backup before deletion for valuable user-created data.
- Add stable test identifiers such as `settings.data.open` and
  `settings.data.deleteAllData`.

## Deletion order

1. Set `deletionInProgress` in app-group/shared state so widgets, intents,
   watch apps, and share extensions stop writing stale snapshots. The marker
   is a SELF-EXPIRING TIMESTAMP (template uses 5 minutes), never a boolean
   latch — a crash mid-deletion must not brick widget/intent intake forever.
2. Capture the CloudKit account identity UP FRONT, at explicit request time
   (`accountStatus == .available` + `userRecordID().recordName`). A fresh
   request re-baselines the identity: the account signed in right now is the
   one whose data the user asked to erase. If no account can be verified, do
   the local wipe, queue NOTHING, and tell the user honestly how to finish
   ("sign in to iCloud and delete again") — a pending marker without a
   captured identity can never be safely resolved and wedges sync off forever.
3. Wipe LOCAL data first: models, KVS, app-group snapshot files (by NAME —
   never a container-wide sweep: the App Group also holds `Library/` with the
   group UserDefaults plist, and possibly the live store / `.externalStorage`
   blobs), Spotlight, notifications, badges, image/blob directories, retry
   queues, AI/location caches, and export temp files. SwiftData local wipes
   are row-by-row fetch-and-delete — `modelContext.delete(model:)` issues a
   batch delete, which CloudKit-backed stores reject and which bypasses the
   mirror, so sync would resurrect every row.
4. Delete CloudKit data LAST, against the verified identity:
   - SwiftData/NSPersistentCloudKitContainer: local-first ordering is
     load-bearing — the row deletes export as tombstones through the
     still-attached mirror, and the zone delete
     (`com.apple.coredata.cloudkit.zone`) is the last server-side word. If
     the zone were deleted first, the live mirror would re-export local rows
     and resurrect it. The store must also re-open LOCAL-ONLY on next launch
     while `pendingCloudDeletion` is set or sync is off (gate the CloudKit
     `ModelConfiguration` on the pending key).
   - RN custom zones: `ICloudSync.deleteAllData()` deletes the zone,
     subscription, change token, and zone-created flag (no auto-mirror, but
     keep the same order for a uniform pattern).
   - CKShare apps: owners delete owned private zones; participants detach local
     shared data and subscriptions without claiming to delete someone else's
     private records.
5. If the zone delete fails transiently, store only tiny non-user-data retry
   state: `pendingCloudDeletion = true` plus the identity captured in step 2.
   Retry at launch BEFORE enabling sync or re-opening the cloud-backed store;
   fire only on an exact identity match; drop an identity-less legacy pending
   marker instead of deadlocking (the user can always delete again).
6. Disable iCloud sync and reload the UI to the empty state. Report the ACTUAL
   outcome (full / cloud-pending / no-account / failed) — and present the
   result alert from a surface that survives any post-deletion container
   rebuild / `.id()` view reset, or it vanishes with the state that owned it.

## Verification

- Create synced data, including at least one attachment/photo/blob.
- Export/backup, then delete.
- Relaunch and confirm no resurrection.
- Verify CloudKit zones/subscriptions are gone in Dashboard.
- Run delete again immediately to prove idempotency.
- Test offline/pending deletion, then switch iCloud accounts and confirm the app
  does not delete the second account's zone — and that the second account can
  still sync after running its own deletion (no permanent sync-off deadlock).
- Test signed out of iCloud: local wipe still succeeds, the alert says how to
  finish the iCloud part, and NO pending retry is queued.
- Kill the app mid-deletion; relaunch after 5+ minutes and confirm widgets and
  intents work again (the in-progress marker self-expired).
- Check widgets, intents, watch, Spotlight, notifications, and app badges show
  empty/default state.
