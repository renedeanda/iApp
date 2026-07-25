// SOURCE: proven in a shipped production app.
// Gold-standard haptic playback gated on Reduce Motion / reduceHaptics.

import CoreHaptics
import Foundation
import UIKit

/// CoreHaptics wrapper. Plays named patterns from `HapticPatterns`.
///
/// **Graduate** when DECISIONS/004-native-feature-checklist.md enables
/// haptics (it should — every app gets 3 starter patterns by default
/// per CLAUDE.md taste rule 2 + DECISIONS/012-haptic-vocabulary.md).
///
/// Source pattern: gold-standard haptics wrapper proven in a shipped
/// production app. The lightweight `HapticsService.swift` next door is
/// an alternative for apps that only need 1–3 patterns; this wrapper
/// handles the full vocabulary.
///
/// Reduce Haptics gating: checks `UIAccessibility.isReduceMotionEnabled`
/// (CLAUDE.md convention) and a dedicated `reduceHaptics` UserDefault
/// if the app exposes a separate toggle in Settings.
@MainActor
final class HapticManager {
    static let shared = HapticManager()

    private var engine: CHHapticEngine?

    private init() {
        prepareEngine()
    }

    /// Play one of the named patterns from `HapticPatterns`.
    /// No-op when Reduce Motion (or the app's reduceHaptics toggle)
    /// is on, or when the device doesn't support CoreHaptics.
    func play(_ pattern: HapticPatterns.Named) {
        guard shouldPlay else { return }
        guard let engine else { return }

        do {
            let chPattern = try pattern.coreHapticsPattern()
            let player = try engine.makePlayer(with: chPattern)
            try player.start(atTime: 0)
        } catch {
            // Engine failure — try to restart for the next call.
            prepareEngine()
        }
    }

    // MARK: - private

    private var shouldPlay: Bool {
        if UIAccessibility.isReduceMotionEnabled { return false }
        if UserDefaults.standard.bool(forKey: "settings.reduceHaptics") { return false }
        return CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            engine = nil
            return
        }
        do {
            let engine = try CHHapticEngine()
            engine.resetHandler = { [weak engine] in
                try? engine?.start()
            }
            try engine.start()
            self.engine = engine
        } catch {
            engine = nil
        }
    }
}
