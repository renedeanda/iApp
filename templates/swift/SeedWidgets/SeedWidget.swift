// SOURCE: proven in a shipped production app.
//
// Timeline: Triggered.
// Reloaded by the host app via WidgetCenter.shared.reloadAllTimelines()
// after it writes WidgetSharedData. Snapshot uses placeholder data so
// the widget gallery renders without app data.
//
// Per docs/WIDGETS.md: edge-to-edge containerBackground, ≤2 font
// weights, ≤1 accent, whole-widget tap target via widgetURL, no
// in-widget animation. Strings resolve from THIS extension's
// Localizable.xcstrings — never the host app's (a trap we hit in
// production: the widget runtime loads strings from the extension's bundle).

import SwiftUI
import WidgetKit

struct SeedWidgetEntry: TimelineEntry {
    let date: Date
    let payload: WidgetPayload
}

struct SeedWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SeedWidgetEntry {
        SeedWidgetEntry(date: .now, payload: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (SeedWidgetEntry) -> Void) {
        completion(SeedWidgetEntry(date: .now, payload: WidgetSharedData.read()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SeedWidgetEntry>) -> Void) {
        // Triggered strategy: one entry, valid until the app reloads us.
        let entry = SeedWidgetEntry(date: .now, payload: WidgetSharedData.read())
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct SeedWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SeedWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("widget.title")
                .font(.caption.weight(.semibold))
                .foregroundStyle(WidgetTheme.accent)
            Text(entry.payload.headline)
                .font(.headline)
                .foregroundStyle(WidgetTheme.onSurface)
                .lineLimit(family == .systemSmall ? 2 : 1)
            if family != .systemSmall {
                Text(entry.payload.detail)
                    .font(.subheadline)
                    .foregroundStyle(WidgetTheme.onSurfaceSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
            Text(entry.payload.updatedAt, style: .relative)
                .font(.caption2)
                .foregroundStyle(WidgetTheme.onSurfaceSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        // Edge-to-edge — never .background(...) on the root.
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [WidgetTheme.surface, WidgetTheme.surfaceSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        // Whole-widget tap target.
        .widgetURL(URL(string: "seed://widget"))
    }
}

struct SeedWidget: Widget {
    let kind = "SeedWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SeedWidgetProvider()) { entry in
            SeedWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("widget.display_name")
        .description("widget.description")
        // Declare only what's supported — omit the rest.
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}
