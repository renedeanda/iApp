// SOURCE: proven in a shipped production app.
// Clean StoreKit 2 baseline + dev premium toggle from docs/HOUSEKEEPING.md.

import Foundation
import Observation
import StoreKit

/// StoreKit 2 paywall + Pro entitlement state.
///
/// Source pattern: clean StoreKit 2 baseline proven in a shipped
/// production app. Extend with introductory offers + receipt
/// validation + sharing zone support as the app needs them.
///
/// **The dev-premium-toggle wiring:** `isPro` short-circuits to `true`
/// whenever `DebugUnlock.isForcedPremium` is on (DEBUG always-on;
/// RELEASE only after 7-tap unlock + reviewer-suppression check).
/// This is the single authoritative read for premium-gated features —
/// never check `Transaction.currentEntitlements` directly from views.
///
/// Wizard at `/new-app --commit` reshapes this file per tier
/// (DECISIONS/003-monetization.md):
/// - Tier 0: replace body of `isPro` with `true`, strip the StoreKit
///   plumbing and ProductID enum (no paywall needed).
/// - Tier 1 / Tier 2: keep `.lifetime` ProductID only, strip monthly/annual.
/// - Tier 3: keep all three ProductIDs (default below).
/// - Tier 4: rename `.lifetime` to a single upfront IAP id.
@MainActor
@Observable
final class SubscriptionManager {
    static let shared = SubscriptionManager()

    enum ProductID: String, CaseIterable {
        case monthly  = "com.example.seed.pro.monthly"
        case annual   = "com.example.seed.pro.annual"
        case lifetime = "com.example.seed.pro.lifetime"
    }

    /// The only authoritative read for premium-gated features.
    /// True when:
    /// - DebugUnlock.isForcedPremium is on (the dev-toggle short-circuit), OR
    /// - the user has an unrevoked active subscription, OR
    /// - the user has a verified lifetime entitlement.
    var isPro: Bool {
        if DebugUnlock.isForcedPremium { return true }
        return hasActiveSubscription || hasLifetime
    }

    /// Products fetched from StoreKit. Empty until `fetchProducts()`
    /// completes. Re-fetch if the paywall view appears and this is empty.
    private(set) var products: [Product] = []

    private var hasActiveSubscription: Bool = false
    private var hasLifetime: Bool = false

    private init() {
        // `shared` is a process-lifetime singleton: the transaction
        // listener is meant to live for the whole app session, so the
        // Task is intentionally not retained for cancellation.
        Task { [weak self] in
            await self?.listenForTransactions()
        }
        Task { [weak self] in
            await self?.refreshEntitlements()
        }
    }

    /// Fetch product details from StoreKit. Call from the paywall
    /// view's `.task { await SubscriptionManager.shared.fetchProducts() }`
    /// modifier. Silent on failure — paywall shows empty state.
    func fetchProducts() async {
        do {
            products = try await Product.products(for: ProductID.allCases.map(\.rawValue))
        } catch {
            products = []
        }
    }

    /// Begin a purchase. Returns true on success, false on user-cancel
    /// or pending state. Throws on verification failure.
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await refreshEntitlements()
            return true
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }

    /// Restore previous purchases. Synchronizes with App Store and
    /// re-checks entitlements. Idempotent.
    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    // MARK: - private

    private func refreshEntitlements() async {
        var active = false
        var lifetime = false
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            switch transaction.productType {
            case .autoRenewable:
                if transaction.revocationDate == nil {
                    active = true
                }
            case .nonConsumable, .nonRenewable:
                lifetime = true
            default:
                break
            }
        }
        hasActiveSubscription = active
        hasLifetime = lifetime
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            guard let transaction = try? checkVerified(result) else { continue }
            await transaction.finish()
            await refreshEntitlements()
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.failedVerification
        case .verified(let value):
            return value
        }
    }
}

enum SubscriptionError: Error {
    case failedVerification
}
