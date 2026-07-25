// SOURCE: iApp template
// App-specific entry; the /new-app wizard rewrites this struct.

import SwiftUI

/// Seed template app entry. bin/rename-template.sh rewrites this type's
/// name (and the @main attribute target) to <AppName>App at
/// `/new-app --commit` time.
///
/// The init() bootstraps DebugUnlock so the bundle-version-change clear
/// + first-launch-date stamp happen before any view reads them.
@main
struct SeedApp: App {
    init() {
        DebugUnlock.bootstrap()
    }

    var body: some Scene {
        WindowGroup {
            ThemeRootView {
                ContentView()
            }
            // Cache the StoreKit environment for DebugUnlock's reviewer-
            // suppression + production hard-gate (replaces the deprecated
            // appStoreReceiptURL check; see Utilities/DebugUnlock.swift).
            .task {
                await DebugUnlock.refreshEnvironment()
            }
        }
    }
}
