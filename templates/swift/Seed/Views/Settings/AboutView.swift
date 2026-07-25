// SOURCE: proven in a shipped production app.
// About surface + 7-tap easter egg (gesture spec in docs/HOUSEKEEPING.md).

import SwiftUI

/// The About surface — app metadata + the dev-premium-toggle 7-tap easter
/// egg on the version string.
///
/// The recognizer:
/// - Resets the tap count after 2 seconds of inactivity.
/// - On 7 taps, checks `DebugUnlock.canUnlockDebugMenu` (suppresses
///   reviewer accounts per HOUSEKEEPING.md) and pushes DebugMenuView
///   silently — no UI feedback either way.
/// - Cross-references HOUSEKEEPING.md "Dev/Debug Premium Toggle"
///   and DELIGHT_REEL.md "Forbidden delights" (dev easter eggs are
///   a SEPARATE category from user-facing delights — see WHATS_ALLOWED.md).
struct AboutView: View {
    @State private var tapCount: Int = 0
    @State private var lastTapTime: Date?
    @State private var showDebugMenu: Bool = false
    @State private var showingOnboarding = false

    private var marketingVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
    }

    private var versionDisplay: String {
        "\(marketingVersion) (\(buildNumber))"
    }

    /// Reads the app's display name from the bundle so the value
    /// reflects post-wizard substitution + locale-specific overrides
    /// (CFBundleDisplayName lives in InfoPlist.xcstrings). Avoids the
    /// `Text("Seed")` trap where SwiftUI treats the literal as a
    /// localization key.
    private var appName: String {
        Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String
        ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        ?? ""
    }

    var body: some View {
        List {
            Section {
                LabeledContent("about.app.name") {
                    Text(appName)
                }
                LabeledContent("about.app.tagline") {
                    Text("about.app.tagline.value")
                }
            }
            .listRowBackground(AppTheme.surfaceSecondary)
            Section {
                Button { showingOnboarding = true } label: {
                    Label("settings.replayOnboarding", systemImage: "sparkles.rectangle.stack")
                }
            }
            .listRowBackground(AppTheme.surfaceSecondary)
            Section {
                versionRow
            }
            .listRowBackground(AppTheme.surfaceSecondary)
        }
        .navigationTitle("settings.about")
        .background(AppTheme.surface)
        .scrollContentBackground(.hidden)
        .navigationDestination(isPresented: $showDebugMenu) {
            DebugMenuView()
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView { showingOnboarding = false }
        }
    }

    private var versionRow: some View {
        LabeledContent("about.version") {
            Text(versionDisplay)
                .font(Typography.bodyEmphasized.monospacedDigit())
                .foregroundStyle(AppTheme.onSurfaceSecondary)
        }
        .contentShape(.rect)
        .accessibilityHint("about.version.a11yHint")
        .onTapGesture {
            handleVersionTap()
        }
    }

    private func handleVersionTap() {
        let now = Date()
        if let last = lastTapTime, now.timeIntervalSince(last) > 2 {
            tapCount = 0
        }
        tapCount += 1
        lastTapTime = now

        guard tapCount >= 7 else { return }
        tapCount = 0
        // Silent on reviewer suppression — no UI feedback either way,
        // so reviewers can't infer the gesture exists.
        if DebugUnlock.canUnlockDebugMenu {
            showDebugMenu = true
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
