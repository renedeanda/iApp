// Cross-promotion Settings section. Two parts, both Apple-compliant (plain
// links, no incentivization, no interruptive modal):
//
//   1. "Made with care by {Studio}" — a single always-present row that opens
//      the studio site. Mirrors a settings pattern proven in a shipped app.
//   2. "More from {Studio}" — a list of sibling apps that are LIVE on the
//      App Store (PortfolioRegistry.liveApps). Hidden entirely when empty,
//      so it shows nothing pre-launch and grows automatically.
//
// Adapt the theme tokens (AppTheme / Typography) to the host app when
// vendoring. Strings go through Localizable.xcstrings — translate the four
// keys (madeWithCare.title, madeWithCare.subtitle, moreApps.title,
// moreApps.openAppStore) to the app's tier-1 locales in the same commit.

import SwiftUI

struct MoreFromStudioSection: View {
    @Environment(\.openURL) private var openURL

    private var liveApps: [PortfolioApp] { PortfolioRegistry.liveApps() }

    var body: some View {
        Section {
            // Made with care — always shown.
            Button {
                if let url = PortfolioRegistry.studioURL { openURL(url) }
            } label: {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("madeWithCare.title")
                            .foregroundStyle(AppTheme.onSurface)
                        Text("madeWithCare.subtitle")
                            .font(.footnote)
                            .foregroundStyle(AppTheme.onSurfaceSecondary)
                    }
                } icon: {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(.isButton)

            // More apps — only the ones already on the App Store.
            ForEach(liveApps) { app in
                Button {
                    if let url = URL(string: app.appStoreURL) { openURL(url) }
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(verbatim: app.name)
                                .foregroundStyle(AppTheme.onSurface)
                            Text(verbatim: app.tagline)
                                .font(.footnote)
                                .foregroundStyle(AppTheme.onSurfaceSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: "arrow.up.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(AppTheme.onSurfaceSecondary)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel(Text("moreApps.openAppStore \(app.name)"))
            }
        } header: {
            // Header reads "More from Your Studio" once anything is live.
            if !liveApps.isEmpty {
                Text("moreApps.title")
            }
        }
    }
}
