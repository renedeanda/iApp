import SwiftUI

/// One onboarding story across iPhone, iPad, Split View, and Dynamic Type.
/// Regular width composes narrative and interaction side by side; compact and
/// Accessibility sizes stay stacked and scroll safely.
struct AdaptiveOnboardingPage<Content: View>: View {
    let symbol: String
    let title: Text
    let detail: Text
    let content: Content

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ScrollView {
            Group {
                if sizeClass == .regular, !dynamicTypeSize.isAccessibilitySize {
                    HStack(alignment: .center, spacing: Spacing.xxl) {
                        narrative.frame(maxWidth: 320)
                        content.frame(maxWidth: 520)
                    }
                    .containerRelativeFrame(.vertical, alignment: .center)
                    .frame(maxWidth: 960)
                } else {
                    VStack(spacing: Spacing.lg) {
                        narrative
                        content
                    }
                    .frame(maxWidth: 560)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.md)
        }
    }

    private var narrative: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: symbol)
                .font(IconSize.hero)
                .foregroundStyle(AppTheme.accent)
                .accessibilityHidden(true)
            VStack(spacing: Spacing.sm) {
                title
                    .font(Typography.display)
                    .foregroundStyle(AppTheme.onSurface)
                    .multilineTextAlignment(.center)
                detail
                    .font(Typography.body)
                    .foregroundStyle(AppTheme.onSurfaceSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
