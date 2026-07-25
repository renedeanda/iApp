// SOURCE: proven in a shipped production app.
// The Live Activity SERVICE layer (start/update/end plumbing).
// NOTE: the LA *views* live in the template's own widget scaffold —
// see Widgets/SeedLiveActivity.swift and recipes/swift/add-live-activity.md.
// Both layers are proven in shipped production apps.

import ActivityKit
import Foundation

/// Starts, updates, and ends the app's Live Activity.
///
/// **Graduate** when DECISIONS/004-native-feature-checklist.md enables
/// Live Activities. Move this file from Services/_Disabled/ to
/// Services/ at /new-app --commit time, add `NSSupportsLiveActivities
/// = YES` to the host Info.plist, and uncomment `SeedLiveActivity()`
/// in Widgets/SeedWidgetBundle.swift.
///
/// `SeedActivityAttributes` is defined in
/// SeedWidgets/SeedActivityAttributes.swift — shared between the app
/// target (this file) and the widget extension target (which renders
/// it in SeedLiveActivity.swift).
@MainActor
final class LiveActivityService {
    static let shared = LiveActivityService()

    private var activity: Activity<SeedActivityAttributes>?

    /// Begin an activity. Throws if the user disabled Live Activities
    /// for the app — handle it, don't force-try.
    func start(title: String, initialState: SeedActivityAttributes.ContentState) throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = SeedActivityAttributes(title: title)
        activity = try Activity.request(
            attributes: attributes,
            content: .init(state: initialState, staleDate: nil)
        )
    }

    /// Push a new content state. Fire-and-forget: the ActivityKit call
    /// is wrapped in a `Task` so the method stays synchronous. Calling
    /// `await activity.update(...)` directly from an `async @MainActor`
    /// method trips Swift 6 strict concurrency ("sending 'activity'");
    /// the `Task` capture is the gold-standard production pattern.
    func update(_ state: SeedActivityAttributes.ContentState) {
        guard let activity else { return }
        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    /// End on the NATURAL completion event — never rely on the 8-hour
    /// system timeout. A Live Activity that lingers is worse than none.
    func end(final state: SeedActivityAttributes.ContentState) {
        guard let activity else { return }
        Task {
            await activity.end(.init(state: state, staleDate: nil), dismissalPolicy: .immediate)
        }
        self.activity = nil
    }
}
