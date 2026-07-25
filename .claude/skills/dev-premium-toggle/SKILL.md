---
name: dev-premium-toggle
description: Scaffold the dev/debug premium toggle pattern in a Swift project — UserDefaults override, DEBUG Settings toggle, RELEASE 7-tap easter egg with 24h expiry + clear-on-update + reviewer suppression. Used in the Swift template and when retrofitting an existing app.
---

# /dev-premium-toggle

Implements the cross-app contract documented in [docs/HOUSEKEEPING.md](../../../docs/HOUSEKEEPING.md) "Dev/Debug Premium Toggle." The pattern lets you flip premium on/off without code changes — essential for early-user testing in production where TestFlight's 90-day window doesn't cover the post-launch period.

## When to use

- Scaffolding the pattern in `templates/swift/Seed/Services/SubscriptionManager.swift`.
- Retrofitting an existing portfolio app that doesn't have the pattern yet.
- Generating the matching `Settings → Developer` and `Settings → About` view code.

## When NOT to use

- For RN apps — the pattern is Swift-specific (StoreKit 2 + UserDefaults short-circuit). RN apps don't have native SubscriptionManager wiring; they use their own RN-side override pattern.
- For Tier 0 apps — they're pure free; there's nothing to override.

## The contract

| Element | Value |
|---|---|
| Override key | `UserDefaults.standard.bool(forKey: "debug.forcePremium")` |
| Override evaluator | `SubscriptionManager.isPro` short-circuits to `true` when the key is set |
| DEBUG visibility | Toggle visible in **Settings → Developer** |
| RELEASE visibility | Hidden until **7-tap gesture on version string** in Settings → About |
| RELEASE expiry | Override auto-clears after **24 hours** of activation (writes activation timestamp; SubscriptionManager checks expiry on read) |
| RELEASE clear-on-update | Override cleared on every `CFBundleVersion` change (cached `CFBundleVersion` compared on launch) |
| **Production hard-gate** | `canUnlockDebugMenu` / `isForcedPremium` are **inert** in a real App Store build — they require StoreKit's `AppTransaction.environment != .production` (cached at launch by `DebugUnlock.refreshEnvironment()`). Fails **closed** during the launch window |
| Reviewer suppression | Detected via StoreKit 2 sandbox/TestFlight environment + first-launch heuristic; easter egg suppressed entirely. (Replaces the deprecated `appStoreReceiptURL == "sandboxReceipt"` signal, removed in iOS 18) |

## Files generated / modified

1. `Services/SubscriptionManager.swift` — `isPro` short-circuit + expiry logic
2. `Services/DebugMenu.swift` — new file, contains the menu shell
3. `Views/Settings/AboutView.swift` — 7-tap gesture recognizer on version string
4. `Views/Settings/SettingsView.swift` — conditional Developer section (DEBUG only)
5. `Views/Settings/DebugMenuView.swift` — the menu UI (Force Premium toggle + portfolio-wide testing primitives)

## Debug menu contents (template ships with these, app wires what's relevant)

- **Force Premium** (toggle, the headline feature)
- **Reset Onboarding** (button)
- **Clear All Data** (button, requires confirmation)
- **Simulate AI Unavailable** (toggle — for Foundation Models apps)
- **Simulate CloudKit Failure** (toggle — for CloudKit apps)
- **Print Analytics Stack** (button)
- **Reveal All Easter Eggs** (toggle — surfaces user-facing delights normally gated by progression)

## Apple Review safety

The pattern survives App Review because:
1. The unlock gesture is genuinely non-discoverable (7-tap is well beyond accidental).
2. The override is time-bounded (24h auto-clear).
3. The override is **inert in production** — a real App Store build (`AppTransaction.environment == .production`) can never reach Force Premium, so it can't bypass monetization at scale.
4. The override doesn't compromise data security.
5. Reviewer accounts are detected (StoreKit sandbox/TestFlight environment + fresh-install window) and the easter egg is suppressed for them.

## Steps

1. Identify target: template or existing app.
2. Check whether the contract is already present (`grep "debug.forcePremium"` in the target).
3. If not present: generate the 5 files (or add the snippets to existing files).
4. Wire `SubscriptionManager.isPro` to short-circuit on the override key with expiry + version checks. Also wire `await DebugUnlock.refreshEnvironment()` into the App's root scene `.task` so the StoreKit-environment cache (production hard-gate + reviewer suppression) populates at launch — without it, RELEASE unlock fails *closed* everywhere.
5. Add the 7-tap recognizer in AboutView with the unlock-to-DebugMenuView destination.
6. Run `/validate-template` if scaffolding into the template, or `xcodebuild build` if retrofitting an app.
7. Commit: `feat(dev): add dev-premium-toggle pattern`.

## Recipe vs. skill

This skill scaffolds the pattern; the full conceptual reference (with copy-ready code blocks and the App Review rationale) lives in [docs/HOUSEKEEPING.md](../../../docs/HOUSEKEEPING.md) "Dev/Debug Premium Toggle". The skill works from that reference when generating files.

## Cross-references

- [docs/HOUSEKEEPING.md](../../../docs/HOUSEKEEPING.md) "Dev/Debug Premium Toggle" — the full template pattern reference
- [DECISIONS/003-monetization.md](../../../DECISIONS/003-monetization.md) "Engineering convention" — strategic context
- [docs/WHATS_ALLOWED.md](../../../docs/WHATS_ALLOWED.md) ✅ Developer-only debug easter eggs — why this isn't a forbidden pattern
- [docs/DELIGHT_REEL.md](../../../docs/DELIGHT_REEL.md) "Forbidden delights" — clarification that dev eggs are explicitly NOT the same category as user-facing-unfindable delights
- [/security-review](../security-review/SKILL.md) — confirms reviewer-suppression code path is present
