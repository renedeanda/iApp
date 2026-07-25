// SOURCE: proven in a shipped production app.
//
// The Live Activity's attributes type. This file is special: it must
// be a member of BOTH the app target AND the widget extension target,
// because the app creates the Activity and the widget renders it. The
// type identity has to match across both processes.
//
// The wizard's `/new-app --commit` wires this when DECISIONS/004
// enables Live Activities:
//
//   1. Uncomment the SproutWidgets app-extension target in project.yml.
//   2. Add this single file to the Sprout app target's sources:
//
//      targets:
//        Sprout:
//          sources:
//            - path: Sprout
//              excludes: ...
//            - path: SproutWidgets/SproutActivityAttributes.swift  # ← add this
//
//   3. Add `NSSupportsLiveActivities = YES` to Sprout/Info.plist's
//      `info.properties` block.
//
//   4. Move `Services/_Disabled/LiveActivityService.swift` → `Services/`.
//
// The ActivityKit import is wrapped in #if canImport so the file is
// inert on macOS-only or ActivityKit-unavailable build configurations
// (Mac Catalyst before iOS 18.4, OS-version-gated tests, etc.). The
// app and widget targets both link ActivityKit in their entitlements,
// so on iOS the type compiles in both contexts identically.

#if canImport(ActivityKit)
import ActivityKit
import Foundation

/// The activity's dynamic state. Keep it to exactly what the
/// surfaces show — every field here is pushed on every update.
struct SproutActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var progress: Double      // 0.0 ... 1.0
        var label: String
    }

    var title: String
}
#endif
