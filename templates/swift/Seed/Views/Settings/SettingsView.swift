// SOURCE: proven in a shipped production app.
// Standard Settings root: appearance, about, debug surfaces.

import SwiftUI

/// The standard Settings surface for any Seed-derived app.
///
/// Three sections by default:
/// - Appearance picker (system / light / dark, persisted via @AppStorage)
/// - About entry (deep links to AboutView, which carries the 7-tap
///   easter-egg recognizer per the dev premium toggle pattern)
/// - Developer entry (DEBUG-only — production unlocks via 7-tap on
///   AboutView's version string)
///
/// Apps customize by adding sections; never remove the Developer
/// section's DEBUG-only conditional — production reaches the Debug
/// menu through AboutView's gesture, never directly from Settings.
struct SettingsView: View {
    @AppStorage("settings.appearance") private var preferenceRaw: String = AppearancePreference.system.rawValue

    private var preferenceBinding: Binding<AppearancePreference> {
        Binding(
            get: { AppearancePreference(rawValue: preferenceRaw) ?? .system },
            set: { preferenceRaw = $0.rawValue }
        )
    }

    var body: some View {
        NavigationStack {
            List {
                appearanceSection
                aboutSection
                #if DEBUG
                developerSection
                #endif
            }
            .navigationTitle("settings.title")
            .background(AppTheme.surface)
            .scrollContentBackground(.hidden)
        }
    }

    private var appearanceSection: some View {
        Section("settings.appearance.section") {
            Picker(selection: preferenceBinding) {
                ForEach(AppearancePreference.allCases) { pref in
                    Text(pref.labelKey).tag(pref)
                }
            } label: {
                Text("settings.appearance.label")
            }
        }
        .listRowBackground(AppTheme.surfaceSecondary)
    }

    private var aboutSection: some View {
        Section {
            NavigationLink {
                AboutView()
            } label: {
                Label("settings.about", systemImage: "info.circle")
            }
        }
        .listRowBackground(AppTheme.surfaceSecondary)
    }

    #if DEBUG
    private var developerSection: some View {
        Section("settings.developer.section") {
            NavigationLink {
                DebugMenuView()
            } label: {
                Label("settings.developer.menu", systemImage: "hammer")
            }
        }
        .listRowBackground(AppTheme.surfaceSecondary)
    }
    #endif
}

#Preview {
    SettingsView()
}
