// SOURCE: Kindling template
// Placeholder root view; /new-app --commit replaces with the app-specific entry surface.

import SwiftUI

/// Placeholder root view. The `/new-app --commit` wizard replaces this
/// with the chosen first-screen pattern per
/// `DECISIONS/010-first-sixty-seconds.md`.
///
/// Ships a TabView shell so the Settings entry point works out of the
/// box — apps that don't want tabs replace the whole view.
struct ContentView: View {
    var body: some View {
        TabView {
            HomePlaceholderView()
                .tabItem {
                    Label("home.tab", systemImage: "house.fill")
                }

            SettingsView()
                .tabItem {
                    Label("settings.tab", systemImage: "gearshape.fill")
                }
        }
        .tint(AppTheme.accent)
    }
}

private struct HomePlaceholderView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text("home.placeholder.title")
                .font(Typography.title)
                .foregroundStyle(AppTheme.onSurface)

            Text("home.placeholder.body")
                .font(Typography.body)
                .foregroundStyle(AppTheme.onSurfaceSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxl)
        }
        // The signature motion (DECISIONS/009). /wire-first-screen
        // re-applies this to the real first screen it generates.
        .signatureMotion()
        // Delight moments (DECISIONS/014) ride in Theme/DelightMoments.swift
        // — .resultReveal() / .celebrationPop(_:). They are action-tied,
        // so /wire-first-screen applies them to the real first screen's
        // result + milestone surfaces, not to this static placeholder.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.surface.ignoresSafeArea())
    }
}

#Preview {
    ContentView()
}
