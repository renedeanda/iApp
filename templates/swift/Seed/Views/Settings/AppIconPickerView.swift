// SOURCE: proven in a shipped production app.
//
// A Pro-gated grid of alternate app icons. Selecting a Pro icon while not
// subscribed routes to the paywall instead of applying. Uses `AppTheme` /
// `Typography` tokens — no hardcoded colors or fonts.
//
// Add a row/NavigationLink to this from SettingsView. Localize the picker
// strings (`appIcon.title`, `appIcon.seed/snow/noir`) in the same commit.

import SwiftUI

struct AppIconPickerView: View {
    /// The single authoritative premium read (dev premium toggle pattern). Swap for the
    /// app's real subscription source.
    @State private var isPro = SubscriptionManager.shared.isPro
    @State private var current: AppIconOption = .seed
    @State private var showingPaywall = false

    private let columns = [GridItem(.adaptive(minimum: 96), spacing: Spacing.lg)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Spacing.lg) {
                ForEach(AppIconOption.allCases) { option in
                    Button {
                        select(option)
                    } label: {
                        swatch(option)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel(Text(option.displayName))
                }
            }
            .padding(Spacing.lg)
        }
        .background(AppTheme.surface)
        .navigationTitle("appIcon.title")
        .onAppear { current = currentSelection() }
        .sheet(isPresented: $showingPaywall) { PaywallView() }
    }

    private func swatch(_ option: AppIconOption) -> some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(option.swatchField)
                Image(systemName: "app.fill") // replace with the app's mark glyph
                    .font(IconSize.medium)
                    .foregroundStyle(option.swatchMark)
                if option == current {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(AppTheme.accent, lineWidth: 3)
                }
                if option.isPro && !isPro {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(AppTheme.onSurfaceSecondary)
                        .padding(6)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
            .frame(width: 88, height: 88)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(AppTheme.onSurface.opacity(0.08), lineWidth: 1)
            )
            Text(option.displayName)
                .font(Typography.caption)
                .foregroundStyle(AppTheme.onSurface)
        }
    }

    private func select(_ option: AppIconOption) {
        if option.isPro && !isPro { showingPaywall = true; return }
        #if os(iOS)
        UIApplication.shared.setAlternateIconName(option.alternateIconName) { error in
            guard error == nil else { return }
            Task { @MainActor in
                current = option
            }
        }
        #endif
    }

    private func currentSelection() -> AppIconOption {
        #if os(iOS)
        let name = UIApplication.shared.alternateIconName
        return AppIconOption.allCases.first { $0.alternateIconName == name } ?? .seed
        #else
        return .seed
        #endif
    }
}
