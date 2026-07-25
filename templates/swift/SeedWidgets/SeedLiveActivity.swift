// SOURCE: proven in a shipped production app.
//
// All FIVE presentations ship (compact leading, compact trailing,
// expanded, minimal, lock screen) — LiveActivityViewTests snapshots
// each against localized fixtures. Per docs/WIDGETS.md rule 4.
//
// Strings resolve from THIS extension's Localizable.xcstrings.
// Compact leading/trailing use an SF Symbol + a tiny number — never
// text labels in compact. The host app must end the activity on the
// natural completion event, not the 8-hour system timeout.
//
// Gated: this file only compiles when the wizard enables Live
// Activities (project.yml widget target uncommented + NSSupportsLive-
// Activities = YES in the host Info.plist).
//
// `SeedActivityAttributes` lives in its own file (SeedActivityAttributes.swift)
// because that type must be a member of BOTH the app target AND the
// widget extension target — see that file's header for the wizard-time
// wiring.

#if canImport(ActivityKit)
import ActivityKit
import SwiftUI
import WidgetKit

struct SeedLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SeedActivityAttributes.self) { context in
            // Lock-screen presentation.
            lockScreen(context: context)
                .containerBackground(for: .widget) { WidgetTheme.surface }
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded presentation.
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "circle.dashed")
                        .foregroundStyle(WidgetTheme.accent)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(Int(context.state.progress * 100))%")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(WidgetTheme.onSurface)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: context.state.progress)
                        .tint(WidgetTheme.accent)
                    Text(context.state.label)
                        .font(.caption2)
                        .foregroundStyle(WidgetTheme.onSurfaceSecondary)
                }
            } compactLeading: {
                // Compact leading — SF Symbol, never a text label.
                Image(systemName: "circle.dashed")
                    .foregroundStyle(WidgetTheme.accent)
            } compactTrailing: {
                // Compact trailing — a tiny number, never a text label.
                Text("\(Int(context.state.progress * 100))")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(WidgetTheme.onSurface)
            } minimal: {
                // Minimal — multi-activity Dynamic Island.
                Image(systemName: "circle.dashed")
                    .foregroundStyle(WidgetTheme.accent)
            }
            .widgetURL(URL(string: "seed://live-activity"))
        }
    }

    @ViewBuilder
    private func lockScreen(context: ActivityViewContext<SeedActivityAttributes>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(context.attributes.title)
                .font(.headline)
                .foregroundStyle(WidgetTheme.onSurface)
            ProgressView(value: context.state.progress)
                .tint(WidgetTheme.accent)
            Text(context.state.label)
                .font(.caption)
                .foregroundStyle(WidgetTheme.onSurfaceSecondary)
        }
        .padding()
    }
}
#endif
