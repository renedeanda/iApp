// SOURCE: proven in a shipped production app.
// 3 starter patterns. Earn the 4th+ via /earn-haptic. Soft cap 8.

import CoreHaptics
import Foundation

/// The 3 starter haptic patterns for the Seed-derived app.
///
/// Per CLAUDE.md taste rule 2, every new app starts with 3 patterns
/// from the 24-pattern reference vocabulary. Adding a 4th–8th requires the
/// `/earn-haptic` skill (writes an ADR addendum justifying the unlock).
/// Soft cap: 8. Hard cap: 10 with reviewer sign-off.
///
/// The full 24-pattern reference vocabulary lives at
/// `Utilities/_HapticVocabulary/HapticPatterns.full.swift` (excluded
/// from compilation by project.yml). The wizard picks 3 from the
/// reference at /new-app --commit time and writes them here.
///
/// Default 3 (the "everyone needs these" baseline):
/// - `bloomOpen`     — soft expansion, for "begin a focused thing"
/// - `completionRing`— three quick taps, for "you're done"
/// - `reminderSoft`  — single soft tap, for ambient feedback
///
/// HapticManager consumes these via `HapticPatterns.Named` and plays
/// them through CoreHaptics. Reduce Haptics gating happens in
/// HapticManager, not here.
enum HapticPatterns {
    /// The named patterns this app uses.
    enum Named: CaseIterable {
        case bloomOpen
        case completionRing
        case reminderSoft

        /// Build the CoreHaptics pattern dictionary for this name.
        /// Patterns are tuned for the iOS Haptic engine; values are
        /// `intensity` (0..1) and `sharpness` (0..1) per event.
        func coreHapticsPattern() throws -> CHHapticPattern {
            switch self {
            case .bloomOpen:
                return try CHHapticPattern(events: [
                    CHHapticEvent(
                        eventType: .hapticContinuous,
                        parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.45),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.30),
                        ],
                        relativeTime: 0,
                        duration: 0.18
                    ),
                ], parameters: [])

            case .completionRing:
                return try CHHapticPattern(events: [
                    transient(at: 0.00, intensity: 0.65, sharpness: 0.55),
                    transient(at: 0.10, intensity: 0.65, sharpness: 0.55),
                    transient(at: 0.20, intensity: 0.85, sharpness: 0.65),
                ], parameters: [])

            case .reminderSoft:
                return try CHHapticPattern(events: [
                    transient(at: 0, intensity: 0.55, sharpness: 0.40),
                ], parameters: [])
            }
        }

        private func transient(
            at time: TimeInterval,
            intensity: Float,
            sharpness: Float
        ) -> CHHapticEvent {
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness),
                ],
                relativeTime: time
            )
        }
    }
}
