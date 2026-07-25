// SOURCE: proven in a shipped production app.
//
// Gated: excluded from compile by default (see SeedIntents.swift header).
//
// A SetFocusFilterIntent lets the app respond to the user's Focus
// modes — e.g. show only work items during a Work Focus. Ship it only
// if the app has content worth filtering by Focus; delete otherwise.

import AppIntents

struct SeedFocusFilterIntent: SetFocusFilterIntent {
    static var title: LocalizedStringResource = "intent.focus_filter.title"
    static var description = IntentDescription("intent.focus_filter.description")

    /// Whether this Focus should hide non-essential content.
    @Parameter(title: "intent.focus_filter.minimal_param", default: false)
    var minimalMode: Bool

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: minimalMode
                ? "intent.focus_filter.repr.minimal"
                : "intent.focus_filter.repr.full"
        )
    }

    func perform() async throws -> some IntentResult {
        // TODO(intent): persist `minimalMode` somewhere the UI observes,
        // e.g. AppDefaults.focusMinimalMode = minimalMode
        return .result()
    }
}
