// SOURCE: proven in a shipped production app.
// Pure Sendable enum pattern — milestone-as-acknowledgment.

import Foundation

/// Milestones the app quietly acknowledges — framed as celebration /
/// care, never as a shame-driven streak (see docs/WHATS_ALLOWED.md).
///
/// **Graduate** when DECISIONS/004 enables milestones. Move this file
/// from Services/_Disabled/ to Services/ at /new-app --commit time.
///
/// The pattern (per portfolio/REUSE_INDEX.md "MilestoneCatalog"):
/// a pure `Sendable` value type — no UI imports, no stored state, no
/// `@Observable`. The catalog is a lookup; a separate `@MainActor`
/// service decides *when* a milestone fires and how it's surfaced.
enum MilestoneCatalog {
    /// One milestone definition. Pure value type.
    struct Milestone: Identifiable, Sendable, Hashable {
        let id: String
        /// Localization key — resolved by the UI, never English here.
        let titleKey: String
        let bodyKey: String
        /// The count at which this milestone fires.
        let threshold: Int
        /// SF Symbol for the acknowledgment surface.
        let symbol: String
    }

    /// The catalog. The wizard replaces these with the app's real
    /// milestones at /new-app --commit time.
    static let all: [Milestone] = [
        Milestone(id: "first", titleKey: "milestone.first.title",
                  bodyKey: "milestone.first.body", threshold: 1, symbol: "sparkle"),
        Milestone(id: "tenth", titleKey: "milestone.tenth.title",
                  bodyKey: "milestone.tenth.body", threshold: 10, symbol: "star"),
        Milestone(id: "hundredth", titleKey: "milestone.hundredth.title",
                  bodyKey: "milestone.hundredth.body", threshold: 100, symbol: "crown"),
    ]

    /// The milestone newly reached at `count`, or nil. Pure function —
    /// no side effects, fully testable.
    static func milestone(reachedAt count: Int) -> Milestone? {
        all.first { $0.threshold == count }
    }
}
