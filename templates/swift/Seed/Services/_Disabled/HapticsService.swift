// SOURCE: proven in a shipped production app.
// Lightweight haptic wrapper — the alternative to the full
// HapticManager for apps that only need 1–3 simple patterns.

import Foundation
import Observation
#if canImport(UIKit)
import UIKit
#endif

/// A minimal haptic surface. Most apps use `HapticManager` +
/// `HapticPatterns` (the 24-pattern vocabulary). This is the lighter
/// option when the app needs only a couple of generic taps and
/// doesn't want the 24-pattern catalog.
///
/// **Graduate** when DECISIONS/004 enables haptics AND
/// DECISIONS/012-haptic-vocabulary.md says the lightweight wrapper
/// fits better than the full HapticManager. Pick ONE — don't ship both.
///
/// Respects the Reduce Motion / reduceHaptics gate, same as
/// HapticManager — a haptic that fires when the user asked for calm
/// is a bug.
@MainActor
@Observable
final class HapticsService {
    static let shared = HapticsService()

    /// Dedicated opt-out, in addition to the OS Reduce Motion check.
    var reduceHaptics: Bool = false

    private var shouldPlay: Bool {
        #if canImport(UIKit)
        !reduceHaptics && !UIAccessibility.isReduceMotionEnabled
        #else
        false
        #endif
    }

    /// A light tap — selection changes, small confirmations.
    func tap() {
        #if canImport(UIKit)
        guard shouldPlay else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    /// A success notification — completion moments.
    func success() {
        #if canImport(UIKit)
        guard shouldPlay else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    /// A warning notification — irreversible / destructive prompts.
    func warning() {
        #if canImport(UIKit)
        guard shouldPlay else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        #endif
    }
}
