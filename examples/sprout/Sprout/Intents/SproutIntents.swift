// SOURCE: provider pattern proven in a shipped production app (logic only;
//         widget-surface strings always live in the widget extension's
//         own string catalog).
//
// Gated: Intents/** is excluded from compile in Sprout/project.yml by
// default (taste rule 1). /new-app --commit removes the exclude when
// DECISIONS/004-native-feature-checklist.md enables App Intents.
//
// Keep perform() THIN — it calls into an existing service, it doesn't
// reimplement logic. All user-facing titles go through Localizable.xcstrings.

import AppIntents

/// A starter action intent. Replace the body with a call into a real
/// service; keep the shape (a struct, a localized title, a thin
/// `perform()` returning an IntentResult).
struct SproutQuickActionIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.quick_action.title"
    static var description = IntentDescription("intent.quick_action.description")

    // Opens the app after running. Drop this for a fully in-background
    // intent (one that never needs UI).
    static var openAppWhenRun: Bool = false

    @Parameter(title: "intent.quick_action.note_param")
    var note: String?

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // TODO(intent): call into the real service, e.g.
        //   try await DataController.shared.quickCapture(note)
        return .result(dialog: "intent.quick_action.confirmation")
    }
}

/// A second starter intent — a parameterless toggle/trigger. Most apps
/// keep 1–3 atomic intents; the user composes Shortcuts from them.
struct SproutBeginIntent: AppIntent {
    static var title: LocalizedStringResource = "intent.begin.title"
    static var description = IntentDescription("intent.begin.description")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        // TODO(intent): trigger the app's primary action.
        return .result()
    }
}
