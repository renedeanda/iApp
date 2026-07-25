# Add a StoreKit 2 paywall

> **Source:** `templates/swift/Seed/Services/SubscriptionManager.swift` (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md))
> **Platform:** Swift
> **Reliability:** ✅ gold-standard. The template ships the clean baseline; a fuller variant (grace periods, multiple product groups) is proven in production.

## What it adds

A `SubscriptionManager` (`@Observable`, `@MainActor`) that loads products via StoreKit 2, exposes `isPro` as the single authoritative read for premium gating, handles purchase + restore, and listens for transaction updates. Plus a paywall view that renders products with **prices from StoreKit**, never hardcoded.

## When to use

- The app has a genuine premium tier defined in `DECISIONS/003-monetization.md`.
- Pricing comes from App Store Connect — the app should never know a number the store didn't tell it.
- You need one read (`isPro`) that every gated feature consults.

## When NOT to use

- **RevenueCat or any third-party IAP wrapper.** Portfolio rule: StoreKit 2 only. No ADR will approve RevenueCat.
- **Hardcoding prices or "save 40%" math.** Prices come from `product.displayPrice`; savings are computed from actual product prices at runtime. A hardcoded price is a guaranteed App Store rejection waiting to happen on the first price change.
- **"Start Free Trial" copy without a trial.** That button text is only valid when `product.subscription?.introductoryOffer` actually exists. Otherwise it's "Subscribe".
- **Rendering the paywall before products load.** Empty `availableProducts` is a state to handle (spinner / retry), not a blank screen.
- **A second `@Observable` owning subscription state.** `SubscriptionManager` owns it. `DataController` does not. One concern, one observable.

## How

### 1. Harvest

- Source: `templates/swift/Seed/Services/SubscriptionManager.swift` for the clean start; extend it with grace periods / multiple product groups only when the app genuinely needs them.
- In a generated app it lives at `<App>/Services/SubscriptionManager.swift`, already wired to the dev premium toggle pattern — see `Utilities/DebugUnlock.swift`.

### 2. Wire

- **Products:** load via `Product.products(for:)` with the IDs from the `.storekit` config. Store them in `availableProducts`.
- **`isPro`:** computed from current entitlements (`Transaction.currentEntitlements`). This is the *only* gate read — features check `SubscriptionManager.shared.isPro`, nothing else.
- **Transaction listener:** a `Task` started at init that iterates `Transaction.updates` and refreshes entitlements. Cancel it in `cleanup()`.
- **Purchase / restore:** `product.purchase()` and `AppStore.sync()` respectively, both with proper error handling (user-cancelled is not an error to surface).
- **Paywall view:** every price is `product.displayPrice`. Trial copy is conditional on `introductoryOffer`. Handle the empty-products state.
- **Dev toggle:** `DebugUnlock` short-circuits `isPro` in DEBUG (24h expiry, clear-on-version-change, reviewer-suppressed). It never ships enabled in RELEASE.

### 3. Verify

```sh
xcodebuild test -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:<App>Tests/SubscriptionManagerTests
```

Expected: tests green using the `.storekit` config; the paywall renders products with store-supplied prices; `isPro` flips correctly on a sandbox purchase + restore.

## Gotchas

- The `.storekit` config file drives Simulator testing; the real products in App Store Connect must match its IDs exactly.
- `Transaction.currentEntitlements` is `async` — `isPro` backed by it needs a cached synchronous mirror that the listener updates, or every gate read becomes async.
- Reviewer accounts: the `DebugUnlock` reviewer-suppression path (sandbox receipt + fresh-install window) exists so App Review doesn't see the dev toggle. Don't remove it.
- Test restore on a fresh install signed into an account that already purchased — the most common shipped paywall bug is a restore that doesn't.
