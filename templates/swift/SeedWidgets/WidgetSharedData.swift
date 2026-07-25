// SOURCE: proven in a shipped production app.
//
// The App Group bridge between the host app and the widget extension.
// Per docs/WIDGETS.md rule 3: read via `containerURL(forSecurity...)`,
// NEVER `UserDefaults(suiteName:)` — the latter fails silently on an
// entitlement misconfig; the container URL returns nil immediately so
// you know the entitlement is wrong.

import Foundation

/// Small, stable-schema payload the host app writes and the widget reads.
/// Keep it tiny — the widget process has a 16 MB memory ceiling and a
/// cold SwiftData open is expensive (docs/WIDGETS.md performance budget).
struct WidgetPayload: Codable, Sendable {
    var headline: String
    var detail: String
    var updatedAt: Date

    static let placeholder = WidgetPayload(
        headline: "—",
        detail: "—",
        updatedAt: .now
    )
}

enum WidgetSharedData {
    // Wizard substitutes the app name at /new-app --commit.
    static let appGroupIdentifier = "group.com.example.seed"
    private static let fileName = "widget-data.json"
    /// Must match DataDeletionService.deletionInProgressMarkerName — the
    /// host app writes this marker (a timestamp) around Delete All Data.
    private static let deletionMarkerName = "accountDeletion.deletionInProgress"
    /// The marker is a timestamp, not a latch: a crash mid-deletion must
    /// not leave widget/intent intake disabled forever, so it self-expires.
    /// Keep the timeout in lockstep with DataDeletionService.
    private static let deletionInProgressTimeout: TimeInterval = 5 * 60

    private static var containerURL: URL? {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        )
    }

    /// True while a deletion started recently and hasn't finished.
    /// (A legacy non-numeric marker fails to parse and reads as expired.)
    static var deletionInProgress: Bool {
        guard let url = containerURL?.appendingPathComponent(deletionMarkerName),
              let raw = try? String(contentsOf: url, encoding: .utf8),
              let startedAt = TimeInterval(raw.trimmingCharacters(in: .whitespacesAndNewlines)),
              startedAt > 0 else { return false }
        return abs(Date().timeIntervalSince1970 - startedAt) < deletionInProgressTimeout
    }

    static func setDeletionInProgress(_ active: Bool) {
        guard let url = containerURL?.appendingPathComponent(deletionMarkerName) else { return }
        if active {
            try? Data(String(Date().timeIntervalSince1970).utf8).write(to: url, options: .atomic)
        } else {
            try? FileManager.default.removeItem(at: url)
        }
    }

    /// Called by the host app after any state change the widget shows.
    /// Pair with `WidgetCenter.shared.reloadAllTimelines()`.
    static func write(_ payload: WidgetPayload) {
        guard !deletionInProgress else { return }
        guard let url = containerURL?.appendingPathComponent(fileName) else { return }
        guard let data = try? JSONEncoder().encode(payload) else { return }
        try? data.write(to: url, options: .atomic)
    }

    /// Called by the widget's timeline provider. Returns a placeholder
    /// when the app hasn't written yet (fresh install) so the widget
    /// gallery still renders.
    static func read() -> WidgetPayload {
        guard !deletionInProgress else { return .placeholder }
        guard
            let url = containerURL?.appendingPathComponent(fileName),
            let data = try? Data(contentsOf: url),
            let payload = try? JSONDecoder().decode(WidgetPayload.self, from: data)
        else {
            return .placeholder
        }
        return payload
    }

    /// Remove the snapshot during Delete All Data. Named files only —
    /// never sweep the whole container (it holds `Library/`, the App Group
    /// UserDefaults plist, and possibly the live store).
    static func clearAllForDeletion() {
        guard let url = containerURL?.appendingPathComponent(fileName) else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
