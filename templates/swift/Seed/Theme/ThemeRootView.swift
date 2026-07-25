// SOURCE: proven in a shipped production app.
// Wraps app root with theme + appearance preference; apply at sheet/cover root too.

import SwiftUI

/// Wraps the app root with theme + appearance preference. Apply once
/// at the top of the scene in SeedApp; per-view styling goes through
/// `AppTheme` + `Typography` directly.
///
/// Source pattern: proven in a shipped production app (simplified —
/// no theme switching since the template ships a single palette; a
/// multi-theme registry is a documented extension if the app needs it).
struct ThemeRootView<Content: View>: View {
    @AppStorage("settings.appearance") private var preferenceRaw: String = AppearancePreference.system.rawValue

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    private var preference: AppearancePreference {
        AppearancePreference(rawValue: preferenceRaw) ?? .system
    }

    var body: some View {
        content
            .tint(AppTheme.accent)
            .background(AppTheme.surface.ignoresSafeArea())
            .preferredColorScheme(preference.colorScheme)
    }
}
