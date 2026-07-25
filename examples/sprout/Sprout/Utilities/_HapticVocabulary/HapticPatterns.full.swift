// SOURCE: proven in a shipped production app.
// Full 24-pattern reference. Excluded from compile; consult before /earn-haptic.

import CoreHaptics
import Foundation

/// Reference: the full 24-pattern haptic vocabulary, distilled from
/// a shipped production app.
///
/// Excluded from compilation by `project.yml`. This file exists as a
/// reference so `/earn-haptic` can pull additional patterns into the
/// active `Utilities/HapticPatterns.swift` when the app proves it
/// needs a 4th, 5th, 6th, etc.
///
/// **Why 24 patterns are too many for one app**: the app that
/// originated this vocabulary shipped all 24; users stopped
/// distinguishing patterns after ~8. The whole vocabulary was felt as
/// "the app is vibrating" rather than distinct emotional events.
/// This is why the wizard caps every new app at 3 starter patterns +
/// a soft cap of 8 (hard cap of 10).
///
/// Use `/sync-from-portfolio` to refresh this reference from a
/// shipped app in your portfolio that has evolved it.
enum FullHapticVocabulary {
    enum Named: CaseIterable {
        // Beginnings (4)
        case bloomOpen
        case launchBreath
        case startFocus
        case beginGentle

        // Completions (4)
        case completionRing
        case finishStrong
        case milestoneBurst
        case resetComplete

        // Ambient feedback (4)
        case reminderSoft
        case favoriteBurst
        case noteSave
        case toggleFlip

        // Grounding / countdown (4)
        case senseTickDescending
        case heartbeatSlow
        case breathInhale
        case breathExhale

        // Errors / warnings (3)
        case errorSoft
        case warningTriple
        case forbiddenBuzz

        // Celebration / delight (3)
        case streakIgnite
        case sparkPop
        case bloomBlossom

        // Specialty (2)
        case selectionTick
        case longPressHold

        /// Build the CoreHaptics pattern for this named pattern.
        /// Values are tuned from production use; adjust timings
        /// deliberately if any pattern feels off after harvest.
        func coreHapticsPattern() throws -> CHHapticPattern {
            switch self {
            case .bloomOpen:
                return try continuous(duration: 0.18, intensity: 0.45, sharpness: 0.30)
            case .launchBreath:
                return try continuous(duration: 0.55, intensity: 0.30, sharpness: 0.10)
            case .startFocus:
                return try continuous(duration: 0.25, intensity: 0.55, sharpness: 0.50)
            case .beginGentle:
                return try transient(intensity: 0.40, sharpness: 0.25)

            case .completionRing:
                return try CHHapticPattern(events: [
                    Self.transientEvent(0.00, 0.65, 0.55),
                    Self.transientEvent(0.10, 0.65, 0.55),
                    Self.transientEvent(0.20, 0.85, 0.65),
                ], parameters: [])
            case .finishStrong:
                return try transient(intensity: 1.0, sharpness: 0.85)
            case .milestoneBurst:
                return try CHHapticPattern(events: [
                    Self.transientEvent(0.00, 0.75, 0.65),
                    Self.transientEvent(0.05, 0.90, 0.75),
                    Self.transientEvent(0.12, 1.00, 0.85),
                ], parameters: [])
            case .resetComplete:
                return try CHHapticPattern(events: [
                    Self.transientEvent(0.00, 0.55, 0.45),
                    Self.transientEvent(0.18, 0.55, 0.45),
                    Self.transientEvent(0.36, 0.85, 0.55),
                ], parameters: [])

            case .reminderSoft:
                return try transient(intensity: 0.55, sharpness: 0.40)
            case .favoriteBurst:
                return try CHHapticPattern(events: [
                    Self.transientEvent(0.00, 0.80, 0.70),
                    Self.transientEvent(0.06, 0.45, 0.40),
                ], parameters: [])
            case .noteSave:
                return try transient(intensity: 0.50, sharpness: 0.50)
            case .toggleFlip:
                return try transient(intensity: 0.60, sharpness: 0.80)

            case .senseTickDescending:
                return try CHHapticPattern(events: [
                    Self.transientEvent(0.00, 0.70, 0.60),
                    Self.transientEvent(0.30, 0.55, 0.45),
                    Self.transientEvent(0.65, 0.40, 0.30),
                ], parameters: [])
            case .heartbeatSlow:
                return try CHHapticPattern(events: [
                    Self.transientEvent(0.00, 0.55, 0.30),
                    Self.transientEvent(0.12, 0.45, 0.25),
                ], parameters: [])
            case .breathInhale:
                return try continuous(duration: 0.80, intensity: 0.35, sharpness: 0.20)
            case .breathExhale:
                return try continuous(duration: 1.10, intensity: 0.45, sharpness: 0.15)

            case .errorSoft:
                return try CHHapticPattern(events: [
                    Self.transientEvent(0.00, 0.70, 0.70),
                    Self.transientEvent(0.10, 0.70, 0.70),
                ], parameters: [])
            case .warningTriple:
                return try CHHapticPattern(events: [
                    Self.transientEvent(0.00, 0.85, 0.85),
                    Self.transientEvent(0.10, 0.85, 0.85),
                    Self.transientEvent(0.20, 0.85, 0.85),
                ], parameters: [])
            case .forbiddenBuzz:
                return try continuous(duration: 0.35, intensity: 0.90, sharpness: 0.95)

            case .streakIgnite:
                return try CHHapticPattern(events: [
                    Self.transientEvent(0.00, 0.45, 0.30),
                    Self.transientEvent(0.04, 0.70, 0.50),
                    Self.transientEvent(0.09, 1.00, 0.70),
                ], parameters: [])
            case .sparkPop:
                return try transient(intensity: 0.75, sharpness: 0.95)
            case .bloomBlossom:
                return try CHHapticPattern(events: [
                    CHHapticEvent(
                        eventType: .hapticContinuous,
                        parameters: [
                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.50),
                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.30),
                        ],
                        relativeTime: 0,
                        duration: 0.40
                    ),
                    Self.transientEvent(0.40, 0.90, 0.70),
                ], parameters: [])

            case .selectionTick:
                return try transient(intensity: 0.35, sharpness: 0.95)
            case .longPressHold:
                return try continuous(duration: 0.65, intensity: 0.50, sharpness: 0.50)
            }
        }

        // MARK: - helpers

        private func transient(intensity: Float, sharpness: Float) throws -> CHHapticPattern {
            try CHHapticPattern(events: [Self.transientEvent(0, intensity, sharpness)], parameters: [])
        }

        private func continuous(duration: TimeInterval, intensity: Float, sharpness: Float) throws -> CHHapticPattern {
            try CHHapticPattern(events: [
                CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness),
                    ],
                    relativeTime: 0,
                    duration: duration
                ),
            ], parameters: [])
        }

        private static func transientEvent(_ time: TimeInterval, _ intensity: Float, _ sharpness: Float) -> CHHapticEvent {
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
