// SOURCE: proven in a shipped production app.
//
// Locale-aware relative date formatting. The formatter is a
// `static let` — never create RelativeDateTimeFormatter per call
// (it's expensive; the perf rule in /review catches this).

import Foundation

extension Date {
    /// One shared formatter — created once, reused. A formatter built
    /// inside a computed property or a loop is a performance bug.
    ///
    /// `nonisolated(unsafe)`: `RelativeDateTimeFormatter` isn't
    /// `Sendable`, but it's configured once here and only ever read —
    /// the standard escape hatch for an immutable shared formatter
    /// under `SWIFT_STRICT_CONCURRENCY: complete` + warnings-as-errors.
    nonisolated(unsafe) private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    /// A localized relative description — "2 hours ago", "in 3 days".
    /// Locale-aware: respects the user's language + region automatically.
    var relativeDescription: String {
        Self.relativeFormatter.localizedString(for: self, relativeTo: .now)
    }
}
