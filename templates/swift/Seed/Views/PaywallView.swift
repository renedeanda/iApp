// SOURCE: proven in a shipped production app.
//
// The Pro paywall. Prices come from StoreKit (`product.displayPrice`)
// — NEVER hardcoded. Trial copy is conditional on an actual
// introductory offer. The empty-products state is handled. The
// dismiss path is always visible (docs/WHATS_ALLOWED.md ✅ Paywalls).
//
// The wizard reshapes this per tier at /new-app --commit:
// - Tier 0: this file is deleted (no paywall).
// - Tier 1 / 2: single lifetime product — the ForEach collapses to one row.
// - Tier 3: monthly + annual + lifetime (the default below).

import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var subscriptions = SubscriptionManager.shared
    @State private var purchasing = false

    var body: some View {
        ThemeRootView {
            VStack(spacing: Spacing.xl) {
                header

                if subscriptions.products.isEmpty {
                    // Empty state — products still loading or fetch failed.
                    ProgressView()
                        .tint(AppTheme.accent)
                        .frame(maxHeight: .infinity)
                } else {
                    productList
                }

                restoreAndDismiss
            }
            .padding(Spacing.xl)
            .background(AppTheme.surface.ignoresSafeArea())
        }
        .task {
            if subscriptions.products.isEmpty {
                await subscriptions.fetchProducts()
            }
        }
        // If a purchase or restore flips isPro, close the paywall.
        .onChange(of: subscriptions.isPro) { _, isPro in
            if isPro { dismiss() }
        }
    }

    private var header: some View {
        VStack(spacing: Spacing.sm) {
            Text("paywall.title")
                .font(Typography.display)
                .foregroundStyle(AppTheme.onSurface)
            Text("paywall.subtitle")
                .font(Typography.body)
                .foregroundStyle(AppTheme.onSurfaceSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, Spacing.xxl)
    }

    private var productList: some View {
        VStack(spacing: Spacing.md) {
            ForEach(subscriptions.products, id: \.id) { product in
                Button {
                    buy(product)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(product.displayName)
                                .font(Typography.bodyEmphasized)
                            // Trial copy ONLY when a real offer exists.
                            if product.subscription?.introductoryOffer != nil {
                                Text("paywall.includes_trial")
                                    .font(Typography.caption)
                                    .foregroundStyle(AppTheme.onSurfaceSecondary)
                            }
                        }
                        Spacer()
                        // Price ALWAYS from StoreKit — never hardcoded.
                        Text(product.displayPrice)
                            .font(Typography.bodyEmphasized)
                    }
                    .foregroundStyle(AppTheme.onSurface)
                    .padding(Spacing.lg)
                    .background(Capsule().fill(AppTheme.surfaceSecondary))
                }
                .disabled(purchasing)
            }
        }
    }

    private var restoreAndDismiss: some View {
        VStack(spacing: Spacing.md) {
            Button("paywall.restore") {
                Task { await subscriptions.restore() }
            }
            .buttonStyle(.seed)
            .disabled(purchasing)

            // The dismiss path is always obvious — never a hidden X.
            Button("paywall.not_now") {
                dismiss()
            }
            .font(Typography.caption)
            .foregroundStyle(AppTheme.onSurfaceSecondary)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
    }

    private func buy(_ product: Product) {
        purchasing = true
        Task {
            defer { purchasing = false }
            // A thrown verification error or user-cancel just leaves
            // the paywall open — never surface a cancel as an error.
            _ = try? await subscriptions.purchase(product)
        }
    }
}

#Preview {
    PaywallView()
}
