// SOURCE: proven in a shipped production app.
// Happy-moment scoring + optional happy-gate pre-prompt around a throttled
// SKStoreReviewController / AppStore.requestReview request.

import Foundation
import StoreKit
import SwiftUI
#if os(iOS)
import UIKit
#endif

/// Decides when to surface a rate-the-app prompt.
///
/// **Graduate** when DECISIONS/004-native-feature-checklist.md enables
/// `app-review`. Record happy moments from *positive* moments only —
/// a completed task, a successful export, a milestone — never after a
/// feature use and never after an error (WHATS_ALLOWED.md).
///
/// Two ways to wire the final ask:
///   1. **Direct** — call `requestReviewNow(in:)` straight from a success
///      moment once `evaluateIfReady()` returns true. Simplest.
///   2. **Happy-gate** (recommended for chatty apps) — bind
///      `shouldShowPrePrompt` to a sheet ("Enjoying {App}?" → I love it /
///      Could be better / Not now). Only "I love it" calls
///      `AppStore.requestReview`, so a frustrated user never burns one of
///      Apple's 3-per-365-days system prompts. "Could be better" routes to
///      `feedbackMailtoURL()`.
///
/// Throttling (belt-and-suspenders over Apple's hard 3/365-day limit):
/// score ≥ `scoreThreshold`, ≥ `minDaysSinceFirstLaunch` since install,
/// ≥ `minDaysBetweenPrompts` since the last prompt, at most once per app
/// version, and never in a TestFlight/sandbox build.
@MainActor
@Observable
final class AppReviewService {
    static let shared = AppReviewService()
    private init() {}

    /// Replace these cases with the app's real success moments. Weight is
    /// how much each moment counts toward `scoreThreshold`; `triggers`
    /// means "evaluate eligibility now" (use for the strongest moments).
    enum HappyMoment {
        case taskCompleted        // weight 1
        case milestoneReached     // weight 2, triggers
        case sharedOrExported     // weight 2, triggers

        var weight: Int {
            switch self {
            case .taskCompleted: return 1
            case .milestoneReached, .sharedOrExported: return 2
            }
        }
        var triggers: Bool {
            switch self {
            case .taskCompleted: return false
            case .milestoneReached, .sharedOrExported: return true
            }
        }
    }

    // MARK: - Tunables
    private static let scoreThreshold = 3
    private static let minDaysSinceFirstLaunch = 14
    private static let minDaysBetweenPrompts = 30

    // MARK: - Persisted state
    private let defaults = UserDefaults.standard
    private enum Keys {
        static let firstLaunch = "appReview.firstLaunchDate"
        static let lastPromptDate = "appReview.lastPromptDate"
        static let lastPromptedVersion = "appReview.lastPromptedVersion"
        static let score = "appReview.happyMomentScore"
    }

    /// Bind a happy-gate sheet to this when using pre-prompt mode.
    var shouldShowPrePrompt = false

    // MARK: - Public API

    func recordHappyMoment(_ moment: HappyMoment) {
        score += moment.weight
        if moment.triggers { evaluateIfReady() }
    }

    /// Flip `shouldShowPrePrompt` true when every gate passes. Returns the
    /// same boolean for callers that want to branch directly. Idempotent.
    @discardableResult
    func evaluateIfReady() -> Bool {
        guard !shouldShowPrePrompt else { return true }
        guard !isTestFlightOrSandbox else { return false }
        guard isPastFirstLaunchGrace else { return false }
        guard isPastLastPromptGrace else { return false }
        guard score >= Self.scoreThreshold else { return false }
        if let v = defaults.string(forKey: Keys.lastPromptedVersion),
           v == currentVersion, lastPromptDate != nil { return false }
        shouldShowPrePrompt = true
        return true
    }

    #if os(iOS)
    /// Direct path: trigger the system review sheet now (skip the happy-gate).
    func requestReviewNow(in scene: UIWindowScene) {
        AppStore.requestReview(in: scene)
        markPrompted()
    }
    #endif

    enum PromptOutcome { case liked, feedback, notNow }

    /// Call from the happy-gate UI. `.liked` assumes the caller already
    /// triggered `AppStore.requestReview`. All outcomes reset the score and
    /// stamp the version/date so the gate must re-fill before the next ask.
    func recordPromptOutcome(_ outcome: PromptOutcome) {
        markPrompted()
        shouldShowPrePrompt = false
    }

    // MARK: - Private

    private var score: Int {
        get { defaults.integer(forKey: Keys.score) }
        set { defaults.set(newValue, forKey: Keys.score) }
    }
    private var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
    }
    private var firstLaunchDate: Date {
        if let d = defaults.object(forKey: Keys.firstLaunch) as? Date { return d }
        let now = Date(); defaults.set(now, forKey: Keys.firstLaunch); return now
    }
    private var lastPromptDate: Date? { defaults.object(forKey: Keys.lastPromptDate) as? Date }
    private var isPastFirstLaunchGrace: Bool {
        Date().timeIntervalSince(firstLaunchDate) >= TimeInterval(Self.minDaysSinceFirstLaunch * 86_400)
    }
    private var isPastLastPromptGrace: Bool {
        guard let lastPromptDate else { return true }
        return Date().timeIntervalSince(lastPromptDate) >= TimeInterval(Self.minDaysBetweenPrompts * 86_400)
    }
    private var isTestFlightOrSandbox: Bool {
        Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }
    private func markPrompted() {
        defaults.set(Date(), forKey: Keys.lastPromptDate)
        defaults.set(currentVersion, forKey: Keys.lastPromptedVersion)
        score = 0
    }
}
