// SOURCE: proven in a shipped production app.
// 4-icon long-press menu on the app icon.

import Foundation
import UIKit

/// Home-screen Quick Actions (the long-press app icon menu).
///
/// **Graduate** when DECISIONS/004-native-feature-checklist.md enables
/// `quick-actions`. Cap at 4 actions (Apple's limit on the long-press
/// menu); the wizard suggests the most-used user paths from
/// DECISIONS/010-first-sixty-seconds.md.
///
/// Source pattern: proven in a shipped production app.
///
/// Each action's title goes through `LocalizedStringResource` so
/// the quick-action menu respects the user's locale.
@MainActor
final class QuickActionService {
    static let shared = QuickActionService()

    /// App-defined action types. Wizard replaces these per app.
    enum ActionType: String {
        case primary   = "com.example.sprout.action.primary"
        case secondary = "com.example.sprout.action.secondary"
    }

    private init() {}

    /// Install the static quick actions on the home-screen icon.
    /// Call once on app launch after authorization (or unconditionally
    /// for actions that don't need auth).
    func installDefaults() {
        let items: [UIApplicationShortcutItem] = [
            UIApplicationShortcutItem(
                type: ActionType.primary.rawValue,
                localizedTitle: String(localized: "quickAction.primary.title"),
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "plus.circle"),
                userInfo: nil
            ),
            UIApplicationShortcutItem(
                type: ActionType.secondary.rawValue,
                localizedTitle: String(localized: "quickAction.secondary.title"),
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "clock"),
                userInfo: nil
            ),
        ]
        UIApplication.shared.shortcutItems = items
    }

    /// Resolve a shortcut item to a routing action. Apps customize
    /// this to dispatch into their navigation router.
    func resolve(_ item: UIApplicationShortcutItem) -> ActionType? {
        ActionType(rawValue: item.type)
    }
}
