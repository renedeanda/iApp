# Add biometric auth (Face ID / Touch ID)

> **Source:** `templates/swift/Seed/Services/_Disabled/BiometricAuthService.swift` (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** Swift
> **Reliability:** ✅ gold-standard — `LocalAuthentication` wrapper with graceful fallbacks.

## What it adds

A `BiometricAuthService` wrapping `LAContext`: it gates a sensitive surface behind Face ID / Touch ID, with a clean fallback to device passcode and a graceful path when biometrics are unavailable or denied.

## When to use

- The app holds **genuinely sensitive data** the user would want protected if their unlocked phone is handed to someone — private notes, financial data, health info.
- The gate is **opt-in** via a Settings toggle — the user decides their data is sensitive, you don't decide for them.
- There's a sensible **fallback** (device passcode) so a failed/unavailable biometric doesn't lock the user out of their own data.

## When NOT to use

- **Gating the whole app by default.** Most apps don't hold lock-worthy data. A biometric gate on a habit tracker is friction theater. Make it opt-in, default off.
- **As the only key to the data.** Biometrics authenticate; they don't encrypt. If the data is truly sensitive it's also encrypted (Keychain / file protection) — the biometric gate is the UX layer, not the security layer.
- **Without a fallback.** A user who changes their face, has a wet thumb, or denied the permission must still be able to reach their data via passcode. No fallback = lockout = support nightmare.
- **Re-prompting aggressively.** Authenticate once per app session (or per sensitive-surface entry), not on every view appear.

## How

### 1. Harvest

- Source: `templates/swift/Seed/Services/_Disabled/BiometricAuthService.swift` — read it for the `LAContext` lifecycle and the availability/error branching.
- In a generated app it ships in `Services/_Disabled/` — move it up to `<App>/Services/BiometricAuthService.swift`.

### 2. Wire

- **Availability check:** `LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error:)` before offering the toggle. If biometrics aren't enrolled, the Settings toggle is disabled with an explanation.
- **Evaluate:** `.deviceOwnerAuthentication` (not `.deviceOwnerAuthenticationWithBiometrics`) so passcode is the automatic fallback.
- **Localized reason:** the `localizedReason` string is user-facing — it goes through `Localizable.xcstrings`.
- **`NSFaceIDUsageDescription`:** add the Info.plist key, localized in `InfoPlist.xcstrings`. App Review rejects Face ID use without it.
- **Session model:** authenticate on entry to the sensitive surface; hold the unlocked state for the session; re-lock on background (with a grace period if the UX calls for it).
- **Settings toggle:** the gate is a setting the service actually checks — off by default.

### 3. Verify

```sh
xcodebuild test -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:<App>Tests/BiometricAuthServiceTests
```

Expected: tests green — the unavailable-biometrics path, the denied path, and the passcode-fallback path all resolve without crashing or locking the user out. (Simulator: enroll Face ID via Features menu to exercise the happy path.)

## Gotchas

- `LAContext` is single-use for one evaluation — create a fresh context per authentication, don't reuse.
- `.deviceOwnerAuthenticationWithBiometrics` has **no passcode fallback** — that's the lockout footgun. Use `.deviceOwnerAuthentication` unless you have a hard reason not to.
- The Simulator's Face ID is in Features → Face ID → Enrolled / Matching Face — easy to forget when a test "fails".
- Backgrounding mid-evaluation cancels it with a specific error code — treat that as "not authenticated", not as a failure to surface.
