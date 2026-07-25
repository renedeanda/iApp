// SOURCE: proven in a shipped production app.
// Minimal CloudKit + SwiftData baseline.

import Foundation
import SwiftData

/// SwiftData + CloudKit container.
///
/// **Graduate** when DECISIONS/004-native-feature-checklist.md enables
/// `swiftdata` or `cloudkit`. Move this file from Services/_Disabled/
/// to Services/ at /new-app --commit time.
///
/// Source pattern: minimal baseline proven in shipped production
/// apps — start here, and graduate to an advanced variant when the
/// app needs sharing zones, schema migrations, or complex
/// relationships.
///
/// The placeholder `Item` model below is replaced by the app's actual
/// model types at /new-app --commit time per
/// DECISIONS/008-data-model-and-sync.md.
@MainActor
@Observable
final class DataController {
    let container: ModelContainer

    init() {
        let schema = Schema([Item.self])

        // Data-deletion gate (Services/_Disabled/DataDeletionService.swift):
        // while a cloud deletion is pending, the store MUST open local-only.
        // Re-attaching the CloudKit mirror before the zone delete lands would
        // re-export local state and resurrect the zone. The key literal
        // matches DataDeletionService.pendingCloudDeletionKey — graduate the
        // two files together for any CloudKit app.
        let pendingCloudDeletion = UserDefaults.standard.bool(
            forKey: "accountDeletion.pendingCloudDeletion"
        )
        let cloudConfig = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: pendingCloudDeletion
                ? .none
                : .private("iCloud.com.example.sprout")
        )

        do {
            container = try ModelContainer(for: schema, configurations: [cloudConfig])
        } catch {
            // CloudKit unavailable (no entitlement, simulator, etc.).
            // Fall back to local-only. AnalyticsService logs the
            // degradation when graduated.
            do {
                let localConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    cloudKitDatabase: .none
                )
                container = try ModelContainer(for: schema, configurations: [localConfig])
            } catch {
                // Schema invalid — explicit precondition failure so
                // the developer sees the bug rather than silently
                // running with no persistence.
                fatalError("DataController: ModelContainer init failed: \(error)")
            }
        }
    }
}

@Model
final class Item {
    var createdAt: Date
    var note: String

    init(note: String = "") {
        self.createdAt = Date()
        self.note = note
    }
}
