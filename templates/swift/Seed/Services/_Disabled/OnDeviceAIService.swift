// SOURCE: proven in a shipped production app.
// Apple Intelligence (Foundation Models) gating pattern — harvest the
// STRUCTURE verbatim; the prompts/UI are app-specific.

import Foundation

/// On-device LLM access, gated three ways: compile-time
/// (`#if canImport`), runtime (availability checked at call time),
/// and product (Pro-gated). Every path has a deterministic fallback.
///
/// **Graduate** when DECISIONS/004-native-feature-checklist.md enables
/// Apple Intelligence. Move this file from Services/_Disabled/ to
/// Services/ at /new-app --commit time.
///
/// Pattern (per portfolio/REUSE_INDEX.md "Apple Intelligence"):
/// `#if canImport(FoundationModels)` + runtime availability + a nil
/// return path the caller handles. See recipes/swift/add-apple-intelligence.md.
///
/// NEVER gate on `#available(iOS ...)` alone — Foundation Models
/// availability depends on device class + the user's Apple
/// Intelligence setting + thermal state, not OS version.
#if canImport(FoundationModels)
import FoundationModels
#endif

@MainActor
final class OnDeviceAIService {
    static let shared = OnDeviceAIService()

    /// Checked at CALL time, not cached at launch — availability can
    /// change (Apple Intelligence toggled off, thermal throttling).
    var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26, *) {
            return SystemLanguageModel.default.availability == .available
        }
        return false
        #else
        return false
        #endif
    }

    /// Generate a response, or `nil` when the model is unavailable /
    /// the user isn't Pro. The caller MUST handle nil with a
    /// deterministic fallback — design the fallback first.
    func generate(prompt: String, isPro: Bool) async -> String? {
        guard isPro, isAvailable else { return nil }

        #if canImport(FoundationModels)
        if #available(iOS 26, *) {
            do {
                let session = LanguageModelSession()
                let response = try await session.respond(to: prompt)
                return response.content
            } catch {
                // Model failed mid-session (thermal, cancellation) —
                // fall back to the deterministic path.
                return nil
            }
        }
        #endif
        return nil
    }
}
