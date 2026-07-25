// SOURCE: proven in a shipped production app —
// Settings -> Data deletion UX, generalized for the iApp template.
//
// Move this beside Views/Settings/SettingsView.swift when
// DataDeletionService graduates, then add `DataDeletionSettingsSection()`
// to SettingsView's List before the About section. Keep the neutral
// Data & Backup row always visible and never paywall it.
//
// UX contract (docs/ICLOUD_DATA_DELETION.md): the destructive confirmation
// is a centered .alert (never .confirmationDialog), and both the confirm
// and result alerts are attached HERE — the destination that owns the
// destructive row — not to the parent Settings list. If the app rebuilds
// its ModelContainer after deletion and resets the view tree with `.id()`,
// present the result from a surface that survives that reset, or the
// alert vanishes with the state that owned it.

import SwiftData
import SwiftUI

struct DataDeletionSettingsSection: View {
    var body: some View {
        Section {
            NavigationLink {
                DataDeletionSettingsView()
            } label: {
                Label("settings.data.manage", systemImage: "externaldrive")
            }
            .accessibilityIdentifier("settings.data.open")
        } header: {
            Text("settings.data.section")
        } footer: {
            Text("settings.data.manage.footer")
        }
        .listRowBackground(AppTheme.surfaceSecondary)
    }
}

private struct DataDeletionSettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var isDeleting = false
    @State private var showConfirmation = false
    @State private var resultMessage: LocalizedStringKey?

    var body: some View {
        List {
            Section {
                Button(role: .destructive) {
                    showConfirmation = true
                } label: {
                    HStack {
                        // The .destructive role renders the system treatment —
                        // no hardcoded .red (warm-palette rule).
                        Label("settings.deleteAllData", systemImage: "trash")
                        Spacer()
                        if isDeleting {
                            ProgressView()
                        }
                    }
                }
                .disabled(isDeleting)
                .accessibilityIdentifier("settings.data.deleteAllData")
            } footer: {
                Text("settings.deleteAllData.footer")
            }
            .listRowBackground(AppTheme.surfaceSecondary)
        }
        .navigationTitle("settings.data.manage")
        .background(AppTheme.surface)
        .scrollContentBackground(.hidden)
        .alert("settings.deleteAllData.confirm.title", isPresented: $showConfirmation) {
            Button("common.cancel", role: .cancel) {}
            Button("settings.deleteAllData.confirm.button", role: .destructive) {
                Task { await deleteAllData() }
            }
        } message: {
            Text("settings.deleteAllData.confirm.message")
        }
        .alert("settings.deleteAllData.result.title", isPresented: resultBinding) {
            Button("common.ok", role: .cancel) {}
        } message: {
            if let resultMessage {
                Text(resultMessage)
            }
        }
    }

    private var resultBinding: Binding<Bool> {
        Binding(
            get: { resultMessage != nil },
            set: { if !$0 { resultMessage = nil } }
        )
    }

    private func deleteAllData() async {
        guard !isDeleting else { return }
        isDeleting = true
        let outcome = await DataDeletionService.deleteAllData(modelContext: modelContext)
        isDeleting = false
        // Honest per-outcome copy — never claim more than what happened.
        resultMessage = switch outcome {
        case .fullyDeleted: "settings.deleteAllData.success"
        case .cloudPending: "settings.deleteAllData.pendingCloud"
        case .cloudUnavailable: "settings.deleteAllData.noAccount"
        case .localFailed: "settings.deleteAllData.error"
        }
    }
}
