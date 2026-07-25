// SOURCE: proven in a shipped production app.
// Optional ambient + chime audio. Forward-looking — the first app to
// ship this writes the canonical version back via /sync-from-portfolio.

import AVFoundation
import Foundation

/// Short, intentional audio — a completion chime, a soft tick.
///
/// **Graduate** when DECISIONS/004-native-feature-checklist.md enables
/// Sound. Move this file from Services/_Disabled/ to Services/ at
/// /new-app --commit time. Off by default — the user opts in.
///
/// Pattern (see recipes/swift/add-sound-design.md): `.ambient` session
/// category so the silent switch is honored and other audio mixes;
/// `.playback` only for apps where audio IS the product (almost never).
@MainActor
final class SoundService {
    static let shared = SoundService()

    /// The user-facing opt-in. The service no-ops when false even if
    /// graduated — sound is earned, not assumed.
    var soundEnabled: Bool = false

    private var player: AVAudioPlayer?

    private init() {
        // `.ambient`: obeys the silent switch, mixes with other audio.
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
    }

    /// Play a one-shot sound bundled under `Resources/`. No loops, no
    /// scheduling — one event, one short sound.
    func play(_ resourceName: String, ext: String = "caf") {
        guard soundEnabled else { return }
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: ext) else {
            return
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
            // Hold a strong reference for the brief playback lifetime.
            self.player = player
        } catch {
            // Audio is non-essential — never throw into the UI.
        }
    }
}
