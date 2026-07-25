// SOURCE: proven in a shipped production app.
// Sheet-driven navigation state machine, proven in a shipped brutalist commute app.

import Observation
import SwiftUI

/// Single-screen + sheets navigation, centralized.
///
/// **Graduate** when DECISIONS/004-native-feature-checklist.md enables
/// the sheet-driven nav pattern. Move this file from Services/_Disabled/
/// to Services/ at /new-app --commit time, inject it at the app root
/// via `.environment(...)`, and drive `.sheet(item:)` from `presented`.
///
/// Pattern (per portfolio/REUSE_INDEX.md "Single-screen + sheets"):
/// one home screen plus sheets — no NavigationStack push trees deeper
/// than one level. See recipes/swift/add-sheet-navigation.md.
///
/// The router holds *navigation* state only — never subscription
/// state, data, or settings (one @Observable per concern).
@MainActor
@Observable
final class NavigationRouter {
    /// Every presentable secondary surface. One case per sheet.
    enum Destination: Identifiable, Hashable {
        case settings
        case paywall
        case onboarding

        var id: Self { self }
    }

    /// The currently presented sheet, or nil. Bind a single
    /// `.sheet(item: $router.presented)` to this at the app root.
    var presented: Destination?

    /// Present a destination. Replaces any currently-presented sheet
    /// (this pattern never stacks sheet-over-sheet).
    func present(_ destination: Destination) {
        presented = destination
    }

    /// Dismiss the current sheet. Views call this, not their own
    /// `@Environment(\.dismiss)`, so state stays centralized.
    func dismiss() {
        presented = nil
    }
}
