// SOURCE: proven in a shipped production app — the iCloud
// data-deletion pattern, generalized for the iApp template.
//
// These apps have no accounts; App Review nevertheless expects in-app deletion
// of the user's iCloud-stored app data (a real App Review rejection we hit cited 5.1.1(v)).
// This is DATA deletion / user control, not the account-deletion requirement.
//
// Graduate this file when DECISIONS/004-native-feature-checklist.md enables
// SwiftData + CloudKit, together with DataDeletionSettingsSection.swift.
// Wiring checklist (all three are load-bearing — see docs/ICLOUD_DATA_DELETION.md):
//   1. Replace Item.self with every app-owned @Model type, add every
//      blob/cache/export directory, keep only explicit non-user-data
//      allowlist keys.
//   2. Gate the CloudKit ModelConfiguration on
//      `!UserDefaults.standard.bool(forKey: DataDeletionService.pendingCloudDeletionKey)`
//      so the store opens LOCAL-ONLY while a cloud deletion is pending —
//      see the matching comment in Services/_Disabled/DataController.swift.
//   3. Call `retryPendingCloudDeletionIfNeeded()` from the app's launch
//      `.task` (after the container exists, before sync is re-enabled).

import CloudKit
import CoreSpotlight
import Foundation
import SwiftData
import UserNotifications
import WidgetKit

@MainActor
enum DataDeletionService {
    static let pendingCloudDeletionKey = "accountDeletion.pendingCloudDeletion"
    private static let pendingCloudDeletionUserRecordNameKey = "accountDeletion.pendingCloudDeletionUserRecordName"
    /// Shared with SeedWidgets/WidgetSharedData.swift — same marker name,
    /// same timestamp semantics. Keep the two in lockstep.
    static let deletionInProgressMarkerName = "accountDeletion.deletionInProgress"

    private static let cloudKitContainerIdentifier = "iCloud.com.example.seed"
    /// NSPersistentCloudKitContainer mirrors every SwiftData record into this
    /// single private-database zone; deleting the zone is the server-side
    /// "erase everything" for this app.
    private static let swiftDataZoneName = "com.apple.coredata.cloudkit.zone"
    private static let appGroupIdentifier = "group.com.example.seed"

    /// The in-progress marker is a timestamp, not a latch: a crash
    /// mid-deletion must not leave widget/intent intake disabled forever,
    /// so the flag self-expires. Mirrored in WidgetSharedData.
    private static let deletionInProgressTimeout: TimeInterval = 5 * 60

    /// What actually happened — the result alert must never overstate.
    enum Outcome: Sendable {
        /// Local store and the iCloud zone are both gone.
        case fullyDeleted
        /// Local store is gone; the iCloud zone delete failed transiently and
        /// is queued (account-verified) to retry on the next launch. Sync
        /// stays disabled until the retry lands.
        case cloudPending
        /// Local store is gone, but no signed-in iCloud account could be
        /// verified — nothing is queued, because a blind retry could fire
        /// against a DIFFERENT account later. The alert tells the user how
        /// to finish (sign in and delete again).
        case cloudUnavailable
        /// The local wipe itself failed; data may remain.
        case localFailed
    }

    static func deleteAllData(modelContext: ModelContext) async -> Outcome {
        setDeletionInProgress(true)
        defer {
            setDeletionInProgress(false)
            WidgetCenter.shared.reloadAllTimelines()
        }

        // Local wipe FIRST: while the CloudKit mirror is still attached,
        // these row deletes export as tombstones. Deleting the zone
        // afterwards makes the zone delete the last server-side word — from
        // the post-wipe state the live mirror can at worst re-create an
        // EMPTY zone, never resurrect rows. (The mirror detaches fully on
        // the next launch: the store must open local-only while
        // `pendingCloudDeletionKey` is set or the sync preference is off —
        // see wiring step 2 in the header.)
        let localDeleted = deleteLocalSwiftData(in: modelContext)

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        try? await CSSearchableIndex.default().deleteAllSearchableItems()

        clearUserDefaults()
        clearKeyValueStore()
        clearWidgetSnapshots()
        clearBlobDirectories()

        // AFTER the defaults sweep, so the flag sticks: sync stays off until
        // the user deliberately re-enables it.
        // TODO(app-data): use the app's real sync-preference key.
        UserDefaults.standard.set(false, forKey: "settings.iCloudSyncEnabled")

        // Cloud wipe LAST — and only against a verified account identity,
        // captured at explicit request time. A fresh request re-baselines
        // the identity: the account signed in right now is the one whose
        // data the user asked to erase.
        if !localDeleted {
            // Don't touch the cloud while local rows survive: the mirror
            // would re-export them and resurrect the zone we just deleted.
            return .localFailed
        }
        guard let identity = await currentAccountIdentity() else {
            // No signed-in account to verify — never queue a blind retry.
            // A pending marker without a captured identity can never be
            // safely resolved and would wedge sync off forever.
            clearPendingCloudDeletion()
            return .cloudUnavailable
        }
        UserDefaults.standard.set(identity, forKey: pendingCloudDeletionUserRecordNameKey)
        if await deleteCloudZone() {
            clearPendingCloudDeletion()
            return .fullyDeleted
        }
        UserDefaults.standard.set(true, forKey: pendingCloudDeletionKey)
        return .cloudPending
    }

    /// Launch-time retry for a queued cloud deletion. Fires only when the
    /// signed-in account matches the identity captured when the user asked —
    /// a pending deletion must never touch a different account's data.
    static func retryPendingCloudDeletionIfNeeded() async {
        guard UserDefaults.standard.bool(forKey: pendingCloudDeletionKey) else { return }
        guard let expected = UserDefaults.standard.string(forKey: pendingCloudDeletionUserRecordNameKey) else {
            // Pending state without a captured identity can never be safely
            // verified against any account — drop it instead of deadlocking
            // the retry (and the sync gate) forever. The user can always run
            // Delete All Data again while signed in.
            clearPendingCloudDeletion()
            return
        }
        guard let current = await currentAccountIdentity(), current == expected else { return }
        if await deleteCloudZone() {
            clearPendingCloudDeletion()
        }
    }

    // MARK: - Local

    /// Row-by-row wipe. Deliberately NOT `modelContext.delete(model:)`: that
    /// issues a batch delete, which CloudKit-backed stores reject — and even
    /// where it succeeds, batch deletes bypass the CloudKit mirror, so the
    /// server would never learn about them and sync would resurrect every row.
    private static func deleteLocalSwiftData(in modelContext: ModelContext) -> Bool {
        do {
            // TODO(app-data): one deleteAll(...) line per app-owned @Model,
            // children before parents so relationship rules don't resurrect.
            try deleteAll(Item.self, in: modelContext)
            try modelContext.save()
            return true
        } catch {
            modelContext.rollback()
            assertionFailure("Delete All Data local SwiftData wipe failed: \(error)")
            return false
        }
    }

    private static func deleteAll<Model: PersistentModel>(
        _ type: Model.Type, in modelContext: ModelContext
    ) throws {
        for object in try modelContext.fetch(FetchDescriptor<Model>()) {
            modelContext.delete(object)
        }
    }

    // MARK: - Cloud

    private static func clearPendingCloudDeletion() {
        UserDefaults.standard.removeObject(forKey: pendingCloudDeletionKey)
        UserDefaults.standard.removeObject(forKey: pendingCloudDeletionUserRecordNameKey)
    }

    /// The signed-in iCloud account's stable user record name, or nil when no
    /// account is available or reachable.
    private static func currentAccountIdentity() async -> String? {
        let container = CKContainer(identifier: cloudKitContainerIdentifier)
        guard let status = try? await container.accountStatus(), status == .available else {
            return nil
        }
        return try? await container.userRecordID().recordName
    }

    private static func deleteCloudZone() async -> Bool {
        let zoneID = CKRecordZone.ID(
            zoneName: swiftDataZoneName,
            ownerName: CKCurrentUserDefaultName
        )
        do {
            let container = CKContainer(identifier: cloudKitContainerIdentifier)
            _ = try await container.privateCloudDatabase.modifyRecordZones(
                saving: [],
                deleting: [zoneID]
            )
            return true
        } catch let error as CKError {
            switch error.code {
            case .zoneNotFound, .unknownItem:
                return true // already gone — that's the goal state
            case .partialFailure:
                return partialFailureOnlyMeansAlreadyDeleted(error)
            default:
                return false
            }
        } catch {
            return false
        }
    }

    private static func partialFailureOnlyMeansAlreadyDeleted(_ error: CKError) -> Bool {
        guard let failures = error.userInfo[CKPartialErrorsByItemIDKey] as? [AnyHashable: Error],
              !failures.isEmpty else { return false }
        return failures.values.allSatisfy { failure in
            let code = (failure as? CKError)?.code
            return code == .zoneNotFound || code == .unknownItem
        }
    }

    // MARK: - Local surfaces

    private static func clearUserDefaults() {
        let defaults = UserDefaults.standard
        let preservedKeys = Set([
            pendingCloudDeletionKey,
            pendingCloudDeletionUserRecordNameKey,
            // DebugUnlock's version-change clearer must not loop
            // (same allowlist as DebugMenuView's Clear All Data).
            "debug.lastSeenBundleVersion",
            "debug.firstLaunchDate",
            // TODO(allowlist): analytics opt-out, onboarding-seen flags —
            // explicit NON-user-data keys only.
        ])

        for key in defaults.dictionaryRepresentation().keys where !preservedKeys.contains(key) {
            defaults.removeObject(forKey: key)
        }
    }

    private static func clearKeyValueStore() {
        let store = NSUbiquitousKeyValueStore.default
        for key in store.dictionaryRepresentation.keys {
            store.removeObject(forKey: key)
        }
        store.synchronize()
    }

    /// Remove KNOWN app-owned files from the App Group container — never a
    /// container-wide sweep. The container also holds `Library/` (the App
    /// Group UserDefaults plist) and, in apps that keep their store or
    /// `.externalStorage` blobs in the group, the LIVE database files;
    /// deleting those out from under an open store corrupts it and can kill
    /// the pending-deletion marker itself.
    private static func clearWidgetSnapshots() {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else { return }

        // Matches SeedWidgets/WidgetSharedData.swift's fileName.
        let knownFiles = [
            "widget-data.json",
            // TODO(app-data): every other app-written App Group file
            // (pending intent queues, cover images, watch snapshots, …).
        ]
        for name in knownFiles {
            try? FileManager.default.removeItem(at: containerURL.appendingPathComponent(name))
        }
    }

    private static func clearBlobDirectories() {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }

        for directory in [
            documents.appendingPathComponent("Attachments", isDirectory: true),
            documents.appendingPathComponent("CloudAssets", isDirectory: true),
            documents.appendingPathComponent("Exports", isDirectory: true),
            // TODO(app-data): every app-owned blob/cache/export directory.
        ] {
            try? FileManager.default.removeItem(at: directory)
        }
    }

    // MARK: - In-progress marker (self-expiring)

    private static func setDeletionInProgress(_ active: Bool) {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else { return }

        let markerURL = containerURL.appendingPathComponent(deletionInProgressMarkerName)
        if active {
            let stamp = String(Date().timeIntervalSince1970)
            try? Data(stamp.utf8).write(to: markerURL, options: .atomic)
        } else {
            try? FileManager.default.removeItem(at: markerURL)
        }
    }

    /// True while a deletion started recently and hasn't finished. A crash
    /// mid-deletion leaves the marker file behind; the timestamp check keeps
    /// that from bricking widget/intent intake forever. (A legacy "true"
    /// marker fails to parse and reads as expired.)
    static var deletionInProgress: Bool {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else { return false }
        let markerURL = containerURL.appendingPathComponent(deletionInProgressMarkerName)
        guard let raw = try? String(contentsOf: markerURL, encoding: .utf8),
              let startedAt = TimeInterval(raw.trimmingCharacters(in: .whitespacesAndNewlines)),
              startedAt > 0 else { return false }
        return abs(Date().timeIntervalSince1970 - startedAt) < deletionInProgressTimeout
    }
}
