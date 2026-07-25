// SOURCE: proven in a shipped production app.
//
// Gated: excluded from compile by default (see SproutIntents.swift header).
//
// The provider registers each intent with Siri / Shortcuts / Spotlight.
// At most 10 shortcuts per app — be selective. Invocation phrases are
// user-facing. Human-readable source phrases are LocalizedStringResource
// keys and also remain readable if system-owned UI cannot load a catalog.

import AppIntents

struct SproutShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SproutQuickActionIntent(),
            phrases: [
                "Run a quick action in \(.applicationName)",
                "Add a note with \(.applicationName)"
            ],
            shortTitle: "intent.quick_action.short_title",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: SproutBeginIntent(),
            phrases: [
                "Begin in \(.applicationName)"
            ],
            shortTitle: "intent.begin.short_title",
            systemImageName: "play.circle"
        )
    }
}
