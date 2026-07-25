// SOURCE: proven in a shipped production app.
// TelemetryDeck signal taxonomy + naming conventions.

import Foundation

// import TelemetryDeckSwiftSDK  // wizard uncomments + adds package dep in project.yml

/// TelemetryDeck analytics wrapper.
///
/// **Graduate** when DECISIONS/004-native-feature-checklist.md enables
/// analytics. Per CLAUDE.md, TelemetryDeck is the only pre-approved
/// analytics dep — no third-party SDKs without an ADR.
///
/// Source pattern: proven in a shipped production app.
/// (gold-standard signal taxonomy + naming conventions).
///
/// Privacy constraints (per docs/NOT_FOR.md §7):
/// - No per-user identifiers; aggregate only.
/// - No third-party data sharing.
/// - NSPrivacyTracking stays `false` in PrivacyInfo.xcprivacy —
///   TelemetryDeck is privacy-preserving by design.
///
/// To activate at /new-app --commit:
/// 1. Wizard uncomments the TelemetryDeck import above.
/// 2. Wizard uncomments TelemetryDeckSwiftSDK in project.yml packages.
/// 3. Wizard injects the per-app TelemetryDeck app ID via
///    Info.plist (`TelemetryDeckAppID`) or a build setting.
@MainActor
final class AnalyticsService {
    static let shared = AnalyticsService()

    private var isStarted = false

    private init() {}

    /// Initialize TelemetryDeck. Call from SeedApp.init() once the
    /// service is graduated. No-op if already started or if the
    /// app ID is missing.
    func start() {
        guard !isStarted else { return }
        guard let appID = Bundle.main.object(forInfoDictionaryKey: "TelemetryDeckAppID") as? String,
              !appID.isEmpty
        else { return }

        // let config = TelemetryDeck.Config(appID: appID)
        // TelemetryDeck.initialize(config: config)
        isStarted = true
    }

    /// Log a single named signal with optional payload.
    /// Use signal names from the canonical taxonomy
    /// (the "signal names" convention proven in a shipped production app).
    func signal(_ name: String, payload: [String: String] = [:]) {
        guard isStarted else { return }
        // TelemetryDeck.signal(name, parameters: payload)
    }
}
