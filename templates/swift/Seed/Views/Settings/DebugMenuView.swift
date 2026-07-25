// SOURCE: iApp template
// Dev-premium-toggle debug menu reached via 7-tap from AboutView. Spec in docs/HOUSEKEEPING.md.

import SwiftUI

/// The dev-premium-toggle debug menu — reachable from Settings → Developer
/// in DEBUG builds, or via 7-tap on AboutView's version string in
/// RELEASE builds (gated by DebugUnlock).
///
/// Apps wire in what's relevant per service — the menu shell ships
/// with the portfolio-wide testing primitives from HOUSEKEEPING.md
/// "Debug menu contents."
///
/// Cross-reference: docs/HOUSEKEEPING.md "Dev/Debug Premium Toggle"
/// for the full pattern + Apple Review safety rationale.
struct DebugMenuView: View {
    @State private var forcePremium: Bool = DebugUnlock.isForcedPremium
    @AppStorage("debug.simulate.aiUnavailable")    private var simulateAIUnavailable: Bool = false
    @AppStorage("debug.simulate.cloudKitFailure")  private var simulateCloudKitFailure: Bool = false
    @AppStorage("debug.revealAllEasterEggs")       private var revealAllEasterEggs: Bool = false
    @State private var confirmingClearData: Bool = false

    var body: some View {
        List {
            premiumSection
            simulateSection
            resetSection
        }
        .navigationTitle("debug.title")
        .background(AppTheme.surface)
        .scrollContentBackground(.hidden)
        .alert("debug.clearAllData.confirm.title", isPresented: $confirmingClearData) {
            Button("debug.clearAllData.cancel", role: .cancel) { }
            Button("debug.clearAllData.confirm", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("debug.clearAllData.confirm.message")
        }
    }

    private var premiumSection: some View {
        Section {
            Toggle("debug.forcePremium", isOn: $forcePremium)
                .onChange(of: forcePremium) { _, newValue in
                    DebugUnlock.isForcedPremium = newValue
                }
        } header: {
            Text("debug.section.premium")
        } footer: {
            Text("debug.forcePremium.footer")
                .font(Typography.caption)
        }
        .listRowBackground(AppTheme.surfaceSecondary)
    }

    private var simulateSection: some View {
        Section("debug.section.simulate") {
            Toggle("debug.sim.ai", isOn: $simulateAIUnavailable)
            Toggle("debug.sim.cloudkit", isOn: $simulateCloudKitFailure)
            Toggle("debug.revealEggs", isOn: $revealAllEasterEggs)
        }
        .listRowBackground(AppTheme.surfaceSecondary)
    }

    private var resetSection: some View {
        Section("debug.section.reset") {
            Button("debug.resetOnboarding") {
                UserDefaults.standard.removeObject(forKey: "onboarding.completed")
            }
            Button("debug.printAnalyticsStack") {
                // Hook for AnalyticsService when present.
                // No-op in templates without analytics enabled.
            }
            Button("debug.clearAllData", role: .destructive) {
                confirmingClearData = true
            }
        }
        .listRowBackground(AppTheme.surfaceSecondary)
    }

    private func clearAllData() {
        // Preserve the bundle-version stamp so the version-change
        // clearer doesn't loop on next launch.
        let defaults = UserDefaults.standard
        let preservedBundle = defaults.string(forKey: "debug.lastSeenBundleVersion")
        let preservedFirstLaunch = defaults.object(forKey: "debug.firstLaunchDate") as? Date

        if let domain = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: domain)
        }
        if let preservedBundle {
            defaults.set(preservedBundle, forKey: "debug.lastSeenBundleVersion")
        }
        if let preservedFirstLaunch {
            defaults.set(preservedFirstLaunch, forKey: "debug.firstLaunchDate")
        }
    }
}

#Preview {
    NavigationStack {
        DebugMenuView()
    }
}
