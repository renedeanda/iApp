// SOURCE: iApp template
// Dev premium toggle (24h auto-expiry + reviewer suppression) per docs/HOUSEKEEPING.md.

import Foundation
import StoreKit

/// The dev-premium-toggle unlock gate.
///
/// Implements the cross-app contract from `docs/HOUSEKEEPING.md`
/// "Dev/Debug Premium Toggle":
/// - 7-tap on version string activates (handled by AboutView).
/// - Reviewer accounts are suppressed (sandbox receipt + fresh-install
///   heuristic; release-only).
/// - 24-hour auto-expiry on the force-premium flag.
/// - Clear-on-update: every CFBundleVersion change wipes the flag.
///
/// Lives separate from SubscriptionManager so the debug menu can
/// open even when StoreKit isn't enabled (Tier 0 apps). The
/// `SubscriptionManager.isPro` short-circuit reads `isForcedPremium`
/// from this utility.
///
/// Apple Review safety per HOUSEKEEPING.md:
/// 1. Unlock gesture is non-discoverable (7-tap).
/// 2. Override is time-bounded (24h).
/// 3. Override is INERT in production — a real App Store build
///    (`AppTransaction.environment == .production`) can never unlock Pro
///    through this path (see `canUnlockDebugMenu` / `isForcedPremium`).
/// 4. Override doesn't compromise data security.
/// 5. Reviewer accounts are detected and suppressed.
enum DebugUnlock {
    private enum Keys {
        static let forcePremium     = "debug.forcePremium"
        static let activationDate   = "debug.forcePremium.activationDate"
        static let lastSeenBundle   = "debug.lastSeenBundleVersion"
        static let firstLaunchDate  = "debug.firstLaunchDate"
        static let sandboxEnvironment = "debug.sandboxEnvironment"
    }

    /// 24 hours.
    static let expiryInterval: TimeInterval = 24 * 60 * 60

    /// Window in which a fresh install + sandbox receipt is treated
    /// as a likely reviewer session. Apps may tighten this for their
    /// own threat model.
    static let reviewerFreshInstallWindow: TimeInterval = 60 * 60

    /// Call once at app launch from SeedApp.init().
    /// Stamps the first-launch date if missing, runs the
    /// bundle-version-change clearer, and expires any stale activation.
    static func bootstrap() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Keys.firstLaunchDate) == nil {
            defaults.set(Date(), forKey: Keys.firstLaunchDate)
        }
        clearIfBundleVersionChanged()
        expireIfStale()
    }

    /// True when a 7-tap unlock should reveal the Debug menu.
    ///
    /// **Hard production gate:** in a RELEASE build the menu is reachable
    /// ONLY once StoreKit confirms a non-production environment (TestFlight
    /// / sandbox / Xcode). A real App Store build reports
    /// `AppTransaction.environment == .production`, so this is `false` and
    /// the 7-tap easter egg is inert — a shipped build can never reveal
    /// Force Premium. Defaults closed until the async probe resolves
    /// (fail-safe); suspected reviewer sessions stay suppressed on top
    /// (`isLikelyReviewer`).
    static var canUnlockDebugMenu: Bool {
        #if DEBUG
        return true
        #else
        return isKnownNonProduction && !isLikelyReviewer
        #endif
    }

    /// True if the force-premium flag is active and unexpired.
    /// Read by SubscriptionManager.isPro at the short-circuit boundary.
    static var isForcedPremium: Bool {
        get {
            #if !DEBUG
            // Hard production gate — the debug override can NEVER grant
            // Pro in a real App Store build. This is the authoritative
            // read `SubscriptionManager.isPro` funnels through, so short-
            // circuiting it to false unless StoreKit has confirmed a non-
            // production environment closes the unlock path even if the
            // flag was somehow set. Fails closed during the launch window.
            guard isKnownNonProduction else { return false }
            #endif
            let defaults = UserDefaults.standard
            guard defaults.bool(forKey: Keys.forcePremium) else { return false }
            return !isExpired
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: Keys.forcePremium)
            if newValue {
                defaults.set(Date(), forKey: Keys.activationDate)
            } else {
                defaults.removeObject(forKey: Keys.activationDate)
            }
        }
    }

    // MARK: - private

    /// True only once StoreKit has confirmed this build runs in a
    /// non-production environment (TestFlight / sandbox / Xcode). Cached
    /// by `refreshEnvironment()`; defaults to `false` so the unlock fails
    /// *closed* in production and during the brief launch window before
    /// the async `AppTransaction` probe resolves.
    private static var isKnownNonProduction: Bool {
        UserDefaults.standard.bool(forKey: Keys.sandboxEnvironment)
    }

    private static var isExpired: Bool {
        guard let activated = UserDefaults.standard.object(forKey: Keys.activationDate) as? Date else {
            return false
        }
        return Date().timeIntervalSince(activated) > expiryInterval
    }

    private static func expireIfStale() {
        guard isExpired else { return }
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Keys.forcePremium)
        defaults.removeObject(forKey: Keys.activationDate)
    }

    private static func clearIfBundleVersionChanged() {
        let defaults = UserDefaults.standard
        let current = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        let lastSeen = defaults.string(forKey: Keys.lastSeenBundle) ?? ""
        if current != lastSeen {
            defaults.removeObject(forKey: Keys.forcePremium)
            defaults.removeObject(forKey: Keys.activationDate)
            defaults.set(current, forKey: Keys.lastSeenBundle)
        }
    }

    /// Reviewer-account heuristic. Returns true when the running
    /// install is plausibly a reviewer session, in which case the
    /// 7-tap easter egg is suppressed entirely.
    ///
    /// DEBUG builds always return false (always-on for the developer).
    /// Release builds combine sandbox receipt + fresh-install window.
    private static var isLikelyReviewer: Bool {
        #if DEBUG
        return false
        #else
        // StoreKit 2 environment (cached at launch by `refreshEnvironment()`) is
        // the modern replacement for the deprecated `appStoreReceiptURL ==
        // "sandboxReceipt"` signal (removed in iOS 18 — it failed the archive
        // under -warnings-as-errors). Combined with the hard production gate
        // in `canUnlockDebugMenu` / `isForcedPremium`, the unlock fails *closed*
        // until the async probe resolves.
        let isSandboxEnvironment = UserDefaults.standard.bool(forKey: Keys.sandboxEnvironment)
        let isFreshInstall: Bool = {
            guard let firstLaunch = UserDefaults.standard.object(forKey: Keys.firstLaunchDate) as? Date else {
                return true
            }
            return Date().timeIntervalSince(firstLaunch) < reviewerFreshInstallWindow
        }()
        return isSandboxEnvironment && isFreshInstall
        #endif
    }

    /// Cache the StoreKit environment for `isLikelyReviewer`. Async because
    /// StoreKit 2's `AppTransaction` is async; call once at launch (the 7-tap
    /// easter egg takes long enough that the value is ready in time). A non-
    /// production environment (sandbox / TestFlight / Xcode) marks a possible
    /// reviewer session. No-op in DEBUG — the developer is never suppressed.
    static func refreshEnvironment() async {
        #if !DEBUG
        guard let result = try? await AppTransaction.shared,
              case .verified(let appTransaction) = result else { return }
        UserDefaults.standard.set(
            appTransaction.environment != .production,
            forKey: Keys.sandboxEnvironment
        )
        #endif
    }
}
