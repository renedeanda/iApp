# Add a Keychain wrapper

> **Source:** `templates/swift/Seed/Services/_Disabled/KeychainService.swift` (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** Swift
> **Reliability:** ✅ gold-standard — thin wrapper, no force-unwraps.

## What it adds

A `KeychainService` that wraps the Security framework's C API behind a small, typed, no-force-unwrap Swift interface: `set`, `get`, `delete` for `Data` / `String` values, with a consistent error type.

## When to use

- The app stores a **secret** — an auth token, an API key the user provided, a sync credential.
- The value must **survive app deletion** (Keychain does) or be **device-only** (set the right accessibility).
- You want one audited wrapper instead of raw `SecItem*` calls scattered around.

## When NOT to use

- **Storing non-secrets.** User preferences, the theme choice, the last-opened tab — that's `UserDefaults`. The Keychain is slower and has a tiny value-size budget; don't use it as a database.
- **Storing large data.** Keychain items are meant for small secrets (tokens, keys), not files or blobs. Big encrypted data goes to disk with file protection.
- **Rolling your own crypto on top.** The Keychain *is* the secure store. Don't encrypt-then-Keychain "for extra safety" — you'll just add a key-management problem.
- **Syncing secrets you didn't mean to.** The `kSecAttrSynchronizable` flag pushes items to iCloud Keychain — deliberate choice, not a default to leave on.

## How

### 1. Harvest

- Source: `templates/swift/Seed/Services/_Disabled/KeychainService.swift` — read it for the `SecItem*` call wrapping and the `Result`/`throws` error shape. The whole point is that it has *no force-unwraps* — keep it that way.
- In a generated app it ships in `Services/_Disabled/` — move it up to `<App>/Services/KeychainService.swift`.

### 2. Wire

- **API:** `try KeychainService.set(_:for:)`, `try KeychainService.get(_:)`, `try KeychainService.delete(_:)`. Keys are a typed enum, not raw strings.
- **Accessibility:** set `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` for most secrets — available to background tasks after first unlock, never synced, never restored to a different device. Choose deliberately.
- **Errors:** `OSStatus` is mapped to a Swift `KeychainError` enum — callers handle `.itemNotFound` distinctly from `.unexpectedStatus`.
- **No force-unwraps:** every `SecItemCopyMatching` result is `guard`-ed. This is the review rule and the reason this wrapper exists.

### 3. Verify

```sh
xcodebuild test -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:<App>Tests/KeychainServiceTests
grep -n '!' <App>/Services/KeychainService.swift | grep -v '!=' | grep -v '//'
```

Expected: tests green — round-trip set/get/delete, `.itemNotFound` on a missing key, overwrite semantics. The `grep` returns nothing (no force-unwraps).

## Gotchas

- The Simulator's Keychain is **shared across apps** and persists between runs — a test that doesn't clean up after itself will pollute the next run. Tests delete their keys in teardown.
- `SecItemUpdate` vs `SecItemAdd`: a "set" that doesn't first check existence will fail with `errSecDuplicateItem` on the second write. The wrapper handles add-or-update internally.
- Keychain access during app launch *before first unlock* fails for `...AfterFirstUnlock...` items — don't read secrets in `application(_:didFinishLaunching...)` if the app can launch in the background pre-unlock.
