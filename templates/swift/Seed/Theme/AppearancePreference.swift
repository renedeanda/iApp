// SOURCE: proven in a shipped production app.
// system / light / dark preference persisted via @AppStorage.

import SwiftUI

/// User-facing light / dark / system appearance preference.
/// Persisted via @AppStorage so the value lives in UserDefaults and
/// follows the user across launches.
///
/// Pattern: this is a value-type enum, not an @Observable service —
/// @AppStorage handles persistence and observation in views. Adding
/// state beyond a single picker doesn't belong here; that goes in a
/// proper @MainActor service per CLAUDE.md.
enum AppearancePreference: String, CaseIterable, Identifiable, Codable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var labelKey: LocalizedStringResource {
        switch self {
        case .system: "appearance.system"
        case .light:  "appearance.light"
        case .dark:   "appearance.dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light:  .light
        case .dark:   .dark
        }
    }
}
