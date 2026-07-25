// SOURCE: proven in a shipped production app.
// Face ID / Touch ID wrapper with graceful fallbacks.

import Foundation
import LocalAuthentication

/// Face ID / Touch ID wrapper with graceful fallbacks.
///
/// **Graduate** when DECISIONS/004-native-feature-checklist.md enables
/// `biometric-auth`. Wizard also uncomments the
/// `NSFaceIDUsageDescription` block in `Info.plist`.
///
/// Source pattern: proven in a shipped production app.
/// (per portfolio/REUSE_INDEX.md).
///
/// Fallback chain: biometrics → passcode → user-chosen unlock method.
/// Never reveal protected content without one of these passes.
@MainActor
final class BiometricAuthService {
    static let shared = BiometricAuthService()

    enum AuthError: Error {
        case unavailable
        case cancelled
        case failed
    }

    private init() {}

    /// True when biometric auth (Face ID or Touch ID) is enrolled
    /// and available on this device.
    var isAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    /// Prompt for biometric (or device passcode if biometrics
    /// unavailable). Returns on success; throws otherwise.
    func authenticate(reason: String) async throws {
        let context = LAContext()
        context.localizedReason = reason

        var policyError: NSError?
        let policy: LAPolicy = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &policyError)
            ? .deviceOwnerAuthenticationWithBiometrics
            : .deviceOwnerAuthentication

        do {
            let success = try await context.evaluatePolicy(policy, localizedReason: reason)
            guard success else { throw AuthError.failed }
        } catch let error as LAError {
            switch error.code {
            case .userCancel, .systemCancel, .appCancel:
                throw AuthError.cancelled
            case .biometryNotAvailable, .biometryNotEnrolled, .biometryLockout, .passcodeNotSet:
                throw AuthError.unavailable
            default:
                throw AuthError.failed
            }
        }
    }
}
