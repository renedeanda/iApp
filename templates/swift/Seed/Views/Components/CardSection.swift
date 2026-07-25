// SOURCE: proven in a shipped production app.
//
// A titled card surface. The template's one shared component example;
// add more here rather than duplicating layout across views (the
// "component reuse" rule in /review). Everything is theme-driven —
// no color or font literals.

import SwiftUI

/// A titled, padded card on the secondary surface. Use for grouping
/// related controls or content — Settings rows, a feature blurb, a
/// stat block.
struct CardSection<Content: View>: View {
    let titleKey: LocalizedStringKey
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(titleKey)
                .font(Typography.headline)
                .foregroundStyle(AppTheme.onSurfaceSecondary)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.surfaceSecondary)
        )
    }
}

#Preview {
    CardSection(titleKey: "preview.section.title") {
        Text("preview.section.body")
            .font(Typography.body)
            .foregroundStyle(AppTheme.onSurface)
    }
    .padding()
    .background(AppTheme.surface)
}
