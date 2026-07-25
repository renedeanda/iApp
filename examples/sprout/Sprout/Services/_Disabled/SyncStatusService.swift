// SOURCE: proven in a shipped production app.
// Observable CloudKit sync state — drives the "syncing…" UI affordance.

import Foundation
import Observation

/// Publishes the current iCloud sync state so the UI can show a
/// loading/syncing indicator instead of rendering an empty list as if
/// it were the truth (the UX rule for iCloud data).
///
/// **Graduate** alongside DataController when DECISIONS/004 enables
/// CloudKit. Move this file from Services/_Disabled/ to Services/ at
/// /new-app --commit time. Wire it to the
/// `NSPersistentCloudKitContainer.eventChangedNotification` (or the
/// SwiftData equivalent) in DataController.
@MainActor
@Observable
final class SyncStatusService {
    static let shared = SyncStatusService()

    enum State: Equatable {
        case idle
        case syncing
        case succeeded(Date)
        case failed(String)
    }

    private(set) var state: State = .idle

    /// True while a sync is in flight — bind a ProgressView to this.
    var isSyncing: Bool {
        if case .syncing = state { return true }
        return false
    }

    func beginSync() {
        state = .syncing
    }

    func finishSync(success: Bool, error: String? = nil) {
        state = success ? .succeeded(.now) : .failed(error ?? "sync.error.unknown")
    }
}
