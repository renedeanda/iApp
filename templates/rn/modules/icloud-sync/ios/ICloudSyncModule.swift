// SOURCE: harvested from a shipped production app's iCloud bridge,
// genericized for reuse.
//
// Generic CloudKit private-database sync. Genericized from an
// event-specific bridge — record type + zone name + subscription id
// + UserDefaults keys are configurable via the SyncConfig struct
// below so this module can be lifted to npm verbatim and consumed by
// any app.

import CloudKit
import ExpoModulesCore
import Foundation

/// Customization surface. Override these constants when forking the
/// module per app; the wizard's `/new-app --commit` substitutes the
/// `appNamespace` token automatically.
private enum SyncConfig {
    /// Used to derive zone / subscription / UserDefaults keys.
    /// Must be a single token (no spaces, no dots).
    static let appNamespace = "Seed"

    static var zoneName: String { "\(appNamespace)SyncZone" }
    static var recordType: String { "\(appNamespace)Record" }
    static var subscriptionId: String { "\(appNamespace.lowercased())-sync-subscription" }
    static var changeTokenDefaultsKey: String { "\(appNamespace.lowercased()).icloud.zone_change_token" }
    static var zoneCreatedDefaultsKey: String { "\(appNamespace.lowercased()).icloud.zone_created" }
    static var assetDirectoryName: String { "cloud-assets" }
}

public class ICloudSyncModule: Module {
    private let database = CKContainer.default().privateCloudDatabase
    private var accountObserver: NSObjectProtocol?

    private var zoneId: CKRecordZone.ID {
        CKRecordZone.ID(zoneName: SyncConfig.zoneName, ownerName: CKCurrentUserDefaultName)
    }

    public func definition() -> ModuleDefinition {
        Name("ICloudSync")
        Events("onChange")

        OnCreate {
            self.accountObserver = NotificationCenter.default.addObserver(
                forName: .CKAccountChanged,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.sendEvent("onChange", [:])
            }
        }

        OnDestroy {
            if let observer = self.accountObserver {
                NotificationCenter.default.removeObserver(observer)
                self.accountObserver = nil
            }
        }

        // ────────────────────────────────────────────────────────────
        // Availability
        // ────────────────────────────────────────────────────────────

        AsyncFunction("isAvailable") { (promise: Promise) in
            let token = FileManager.default.ubiquityIdentityToken
            promise.resolve(token != nil)
        }

        AsyncFunction("currentUserRecordName") { (promise: Promise) in
            CKContainer.default().userRecordID { recordID, error in
                if let error {
                    promise.reject("user_record_failed", error.localizedDescription)
                } else {
                    promise.resolve(recordID?.recordName)
                }
            }
        }

        // ────────────────────────────────────────────────────────────
        // Setup: create zone + subscribe (idempotent)
        // ────────────────────────────────────────────────────────────

        AsyncFunction("setup") { (promise: Promise) in
            let defaults = UserDefaults.standard
            if defaults.bool(forKey: SyncConfig.zoneCreatedDefaultsKey) {
                promise.resolve(true)
                return
            }
            let zone = CKRecordZone(zoneID: self.zoneId)
            let zoneOp = CKModifyRecordZonesOperation(
                recordZonesToSave: [zone],
                recordZoneIDsToDelete: nil
            )
            zoneOp.modifyRecordZonesResultBlock = { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    defaults.set(true, forKey: SyncConfig.zoneCreatedDefaultsKey)
                    let subscription = CKRecordZoneSubscription(
                        zoneID: self.zoneId,
                        subscriptionID: SyncConfig.subscriptionId
                    )
                    let info = CKSubscription.NotificationInfo()
                    info.shouldSendContentAvailable = true
                    subscription.notificationInfo = info
                    let subOp = CKModifySubscriptionsOperation(
                        subscriptionsToSave: [subscription],
                        subscriptionIDsToDelete: nil
                    )
                    subOp.modifySubscriptionsResultBlock = { _ in
                        // Subscription failure isn't fatal — user can still
                        // pull-to-refresh; foreground triggers fetchChanges.
                        promise.resolve(true)
                    }
                    self.database.add(subOp)
                case .failure(let error):
                    promise.reject("setup_failed", error.localizedDescription)
                }
            }
            self.database.add(zoneOp)
        }

        // ────────────────────────────────────────────────────────────
        // Save / delete
        // ────────────────────────────────────────────────────────────

        AsyncFunction("saveOne") { (record: [String: Any], promise: Promise) in
            guard let id = record["id"] as? String else {
                promise.reject("invalid", "missing id")
                return
            }
            let ckRecord = self.makeRecord(id: id, dict: record)
            let op = CKModifyRecordsOperation(
                recordsToSave: [ckRecord],
                recordIDsToDelete: nil
            )
            op.savePolicy = .changedKeys
            op.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    promise.resolve(true)
                case .failure(let error):
                    promise.reject("save_failed", error.localizedDescription)
                }
            }
            self.database.add(op)
        }

        AsyncFunction("saveMany") { (records: [[String: Any]], promise: Promise) in
            let ckRecords: [CKRecord] = records.compactMap { dict in
                guard let id = dict["id"] as? String else { return nil }
                return self.makeRecord(id: id, dict: dict)
            }
            // CloudKit caps a single operation at 400 records.
            let chunks = ckRecords.chunked(into: 400)
            var totalSaved = 0
            var totalFailed = 0
            let group = DispatchGroup()

            for chunk in chunks {
                group.enter()
                let op = CKModifyRecordsOperation(
                    recordsToSave: chunk,
                    recordIDsToDelete: nil
                )
                op.savePolicy = .changedKeys
                op.modifyRecordsResultBlock = { result in
                    switch result {
                    case .success: totalSaved += chunk.count
                    case .failure: totalFailed += chunk.count
                    }
                    group.leave()
                }
                self.database.add(op)
            }

            group.notify(queue: .main) {
                promise.resolve(["saved": totalSaved, "failed": totalFailed])
            }
        }

        AsyncFunction("deleteOne") { (id: String, promise: Promise) in
            let recordId = CKRecord.ID(recordName: id, zoneID: self.zoneId)
            let op = CKModifyRecordsOperation(
                recordsToSave: nil,
                recordIDsToDelete: [recordId]
            )
            op.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    promise.resolve(true)
                case .failure(let error):
                    // "already gone" is idempotent success for callers.
                    if let ckError = error as? CKError, ckError.code == .unknownItem {
                        promise.resolve(true)
                    } else {
                        promise.reject("delete_failed", error.localizedDescription)
                    }
                }
            }
            self.database.add(op)
        }

        /// In-app deletion of the user's CloudKit-backed app data (App
        /// Review expects this for iCloud-stored data — see
        /// docs/ICLOUD_DATA_DELETION.md). JS owns local cleanup; native
        /// owns the custom zone, silent-push subscription, and tokens.
        AsyncFunction("deleteAllData") { (promise: Promise) in
            let zoneOp = CKModifyRecordZonesOperation(
                recordZonesToSave: nil,
                recordZoneIDsToDelete: [self.zoneId]
            )
            zoneOp.modifyRecordZonesResultBlock = { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.deleteSubscriptionAndReset(promise: promise)
                case .failure(let error):
                    if self.isIdempotentMissingError(error) {
                        self.deleteSubscriptionAndReset(promise: promise)
                    } else {
                        promise.reject("delete_all_data_failed", error.localizedDescription)
                    }
                }
            }
            self.database.add(zoneOp)
        }

        // ────────────────────────────────────────────────────────────
        // Fetch (initial + incremental)
        // ────────────────────────────────────────────────────────────

        AsyncFunction("fetchAll") { (promise: Promise) in
            let query = CKQuery(
                recordType: SyncConfig.recordType,
                predicate: NSPredicate(value: true)
            )
            let op = CKQueryOperation(query: query)
            op.zoneID = self.zoneId
            var results: [[String: Any]] = []
            op.recordMatchedBlock = { [weak self] _, result in
                guard let self = self else { return }
                if case .success(let record) = result {
                    results.append(self.recordToDict(record))
                }
            }
            op.queryResultBlock = { result in
                switch result {
                case .success: promise.resolve(results)
                case .failure(let error):
                    promise.reject("fetch_failed", error.localizedDescription)
                }
            }
            self.database.add(op)
        }

        AsyncFunction("fetchChanges") { (promise: Promise) in
            let token = self.loadChangeToken()
            let config = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
            config.previousServerChangeToken = token
            let op = CKFetchRecordZoneChangesOperation(
                recordZoneIDs: [self.zoneId],
                configurationsByRecordZoneID: [self.zoneId: config]
            )

            var changed: [[String: Any]] = []
            var deleted: [String] = []

            op.recordWasChangedBlock = { [weak self] _, result in
                guard let self = self else { return }
                if case .success(let record) = result {
                    changed.append(self.recordToDict(record))
                }
            }
            op.recordWithIDWasDeletedBlock = { recordId, _ in
                deleted.append(recordId.recordName)
            }
            op.recordZoneFetchResultBlock = { [weak self] _, result in
                guard let self = self else { return }
                if case .success(let zoneResult) = result {
                    self.saveChangeToken(zoneResult.serverChangeToken)
                }
            }
            op.fetchRecordZoneChangesResultBlock = { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    promise.resolve(["changed": changed, "deleted": deleted])
                case .failure(let error):
                    if let ckError = error as? CKError, ckError.code == .changeTokenExpired {
                        // Clear and let the JS layer retry — next call
                        // returns the full set.
                        self.saveChangeToken(nil)
                    }
                    promise.reject(
                        "fetch_changes_failed",
                        error.localizedDescription
                    )
                }
            }
            self.database.add(op)
        }

        AsyncFunction("resetSyncState") { (promise: Promise) in
            self.resetLocalSyncState()
            promise.resolve(true)
        }
    }

    // ──────────────────────────────────────────────────────────────────
    // Whole-data deletion helpers
    // ──────────────────────────────────────────────────────────────────

    private func deleteSubscriptionAndReset(promise: Promise) {
        let op = CKModifySubscriptionsOperation(
            subscriptionsToSave: nil,
            subscriptionIDsToDelete: [SyncConfig.subscriptionId]
        )
        op.modifySubscriptionsResultBlock = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.resetLocalSyncState()
                promise.resolve(true)
            case .failure(let error):
                if self.isIdempotentMissingError(error) {
                    self.resetLocalSyncState()
                    promise.resolve(true)
                } else {
                    promise.reject("delete_subscription_failed", error.localizedDescription)
                }
            }
        }
        self.database.add(op)
    }

    private func resetLocalSyncState() {
        self.saveChangeToken(nil)
        UserDefaults.standard.removeObject(forKey: SyncConfig.zoneCreatedDefaultsKey)
    }

    private func isIdempotentMissingError(_ error: Error) -> Bool {
        guard let ckError = error as? CKError else { return false }
        if ckError.code == .zoneNotFound || ckError.code == .unknownItem {
            return true
        }
        if ckError.code == .partialFailure,
           let partial = ckError.userInfo[CKPartialErrorsByItemIDKey] as? [AnyHashable: Error],
           !partial.isEmpty {
            return partial.values.allSatisfy { itemError in
                guard let itemCKError = itemError as? CKError else { return false }
                return itemCKError.code == .zoneNotFound || itemCKError.code == .unknownItem
            }
        }
        return false
    }

    // ──────────────────────────────────────────────────────────────────
    // Record <-> dict mapping
    // ──────────────────────────────────────────────────────────────────

    private func makeRecord(id: String, dict: [String: Any]) -> CKRecord {
        let recordId = CKRecord.ID(recordName: id, zoneID: self.zoneId)
        let record = CKRecord(recordType: SyncConfig.recordType, recordID: recordId)

        for (key, value) in dict {
            // "id" is stored as recordName, not a field.
            // "__assetPath" is a JS-side absolute file URL; we convert
            // to a CKAsset below.
            if key == "id" || key == "__assetPath" { continue }
            if let v = value as? String {
                record[key] = v as CKRecordValue
            } else if let v = value as? Bool {
                record[key] = NSNumber(value: v)
            } else if let v = value as? NSNumber {
                record[key] = v
            }
            // Nested objects / arrays / nulls drop silently — they're
            // not CKRecord-compatible primitives.
        }

        if let assetPath = dict["__assetPath"] as? String,
           !assetPath.isEmpty,
           FileManager.default.fileExists(atPath: assetPath) {
            let url = URL(fileURLWithPath: assetPath)
            record["asset"] = CKAsset(fileURL: url)
        }

        return record
    }

    private func recordToDict(_ record: CKRecord) -> [String: Any] {
        var dict: [String: Any] = ["id": record.recordID.recordName]
        for key in record.allKeys() {
            let value = record[key]
            if key == "asset",
               let asset = value as? CKAsset,
               let url = asset.fileURL {
                let ext = url.pathExtension.isEmpty ? "bin" : url.pathExtension
                if let dest = self.copyAssetToDocuments(
                    from: url,
                    recordId: record.recordID.recordName,
                    ext: ext
                ) {
                    dict["__assetPath"] = dest
                }
            } else if let s = value as? String {
                dict[key] = s
            } else if let n = value as? NSNumber {
                dict[key] = n
            }
        }
        return dict
    }

    private func copyAssetToDocuments(
        from src: URL,
        recordId: String,
        ext: String
    ) -> String? {
        guard let docs = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else { return nil }
        let dir = docs.appendingPathComponent(
            SyncConfig.assetDirectoryName,
            isDirectory: true
        )
        do {
            try FileManager.default.createDirectory(
                at: dir,
                withIntermediateDirectories: true
            )
            let dest = dir.appendingPathComponent("\(recordId).\(ext)")
            // Always overwrite — asset may have been replaced.
            if FileManager.default.fileExists(atPath: dest.path) {
                try FileManager.default.removeItem(at: dest)
            }
            try FileManager.default.copyItem(at: src, to: dest)
            return dest.path
        } catch {
            return nil
        }
    }

    // ──────────────────────────────────────────────────────────────────
    // Change token persistence
    // ──────────────────────────────────────────────────────────────────

    private func loadChangeToken() -> CKServerChangeToken? {
        guard let data = UserDefaults.standard.data(
            forKey: SyncConfig.changeTokenDefaultsKey
        ) else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(
            ofClass: CKServerChangeToken.self,
            from: data
        )
    }

    private func saveChangeToken(_ token: CKServerChangeToken?) {
        if let token = token,
           let data = try? NSKeyedArchiver.archivedData(
               withRootObject: token,
               requiringSecureCoding: true
           ) {
            UserDefaults.standard.set(
                data,
                forKey: SyncConfig.changeTokenDefaultsKey
            )
        } else {
            UserDefaults.standard.removeObject(
                forKey: SyncConfig.changeTokenDefaultsKey
            )
        }
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
