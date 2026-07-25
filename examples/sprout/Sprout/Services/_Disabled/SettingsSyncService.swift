// SOURCE: proven in a shipped production app.
// Syncs lightweight user preferences across the user's devices via
// NSUbiquitousKeyValueStore (iCloud key-value store).

import Foundation
import Observation

/// Cross-device sync for *small* user settings — appearance choice,
/// the reduceHaptics flag, feature toggles. NOT for app data (that's
/// DataController + CloudKit) and NOT for secrets (that's KeychainService).
///
/// **Graduate** when DECISIONS/004-native-feature-checklist.md enables
/// settings sync. Move this file from Services/_Disabled/ to Services/
/// at /new-app --commit time. Requires the iCloud KVS entitlement
/// (already in Sprout.entitlements via the ubiquity-kvstore identifier).
///
/// NSUbiquitousKeyValueStore caps at 1 MB total / 1024 keys — it is
/// for preferences, not data. Exceed that and writes silently fail.
@MainActor
@Observable
final class SettingsSyncService {
    static let shared = SettingsSyncService()

    private let store = NSUbiquitousKeyValueStore.default

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(storeChangedExternally),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: store
        )
        store.synchronize()
    }

    /// Read a synced bool (defaults to `false` when unset).
    func bool(forKey key: String) -> Bool {
        store.bool(forKey: key)
    }

    /// Write a synced bool. Mirror it to UserDefaults too if the UI
    /// reads synchronously — KVS reads can lag a fresh launch.
    func set(_ value: Bool, forKey key: String) {
        store.set(value, forKey: key)
        store.synchronize()
    }

    @objc private func storeChangedExternally(_ note: Notification) {
        // A peer device changed a setting — observers of this
        // @Observable re-read. Post an app-level notification here if
        // non-SwiftUI code needs to react.
    }
}
