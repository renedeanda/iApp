// SOURCE: proven in a shipped production app.
//
// The widget extension's @main entry. Every widget + Live Activity
// the extension ships must be registered here, or it won't appear.
//
// Gated: the whole SproutWidgets/ target is commented out in
// Sprout/project.yml by default (taste rule 1 — features off until the
// wizard enables them). /new-app --commit uncomments the target when
// DECISIONS/004-native-feature-checklist.md enables widgets.

import SwiftUI
import WidgetKit

@main
struct SproutWidgetBundle: WidgetBundle {
    var body: some Widget {
        SproutWidget()
        // SproutLiveActivity is registered only when the host app's
        // Info.plist has NSSupportsLiveActivities = YES. Uncomment
        // alongside that flag at /new-app --commit.
        // SproutLiveActivity()
    }
}
