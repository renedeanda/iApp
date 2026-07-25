// SOURCE: proven in a shipped production app.
//
// Curated, cost-conscious Bring Your Own Key model policy. This file owns
// model IDs, defaults, pricing metadata, and migrations; provider networking,
// Keychain storage, prompts, and UI stay app-specific.

import Foundation

struct BYOKModelDescriptor: Identifiable, Hashable, Sendable {
    let id: String
    let displayName: String
    let inputPer1M: Double
    let outputPer1M: Double
    let contextWindow: Int
    let isRecommended: Bool
}

enum BYOKModelProvider: String, CaseIterable, Identifiable, Sendable {
    case anthropic
    case openAI = "openai"
    case google

    var id: String { rawValue }

    var defaultModelID: String {
        switch self {
        case .anthropic: "claude-sonnet-5"
        case .openAI: "gpt-5.6-terra"
        case .google: "gemini-3.6-flash"
        }
    }

    /// The intentionally small picker catalog. Custom model IDs may remain
    /// available to advanced users, except IDs normalized below.
    var curatedModels: [BYOKModelDescriptor] {
        switch self {
        case .anthropic:
            [
                BYOKModelDescriptor(
                    id: "claude-sonnet-5",
                    displayName: "Claude Sonnet 5",
                    inputPer1M: 3,
                    outputPer1M: 15,
                    contextWindow: 1_000_000,
                    isRecommended: true
                ),
                BYOKModelDescriptor(
                    id: "claude-haiku-4-5",
                    displayName: "Claude Haiku 4.5",
                    inputPer1M: 1,
                    outputPer1M: 5,
                    contextWindow: 200_000,
                    isRecommended: false
                ),
                BYOKModelDescriptor(
                    id: "claude-opus-5",
                    displayName: "Claude Opus 5",
                    inputPer1M: 5,
                    outputPer1M: 25,
                    contextWindow: 1_000_000,
                    isRecommended: false
                ),
            ]
        case .openAI:
            [
                BYOKModelDescriptor(
                    id: "gpt-5.6-terra",
                    displayName: "GPT-5.6 Terra",
                    inputPer1M: 2.5,
                    outputPer1M: 15,
                    contextWindow: 1_050_000,
                    isRecommended: true
                ),
                BYOKModelDescriptor(
                    id: "gpt-5.6-luna",
                    displayName: "GPT-5.6 Luna",
                    inputPer1M: 1,
                    outputPer1M: 6,
                    contextWindow: 1_050_000,
                    isRecommended: false
                ),
                BYOKModelDescriptor(
                    id: "gpt-5.6-sol",
                    displayName: "GPT-5.6 Sol",
                    inputPer1M: 5,
                    outputPer1M: 30,
                    contextWindow: 1_050_000,
                    isRecommended: false
                ),
            ]
        case .google:
            [
                BYOKModelDescriptor(
                    id: "gemini-3.6-flash",
                    displayName: "Gemini 3.6 Flash",
                    inputPer1M: 1.5,
                    outputPer1M: 7.5,
                    contextWindow: 1_000_000,
                    isRecommended: true
                ),
                BYOKModelDescriptor(
                    id: "gemini-3.5-flash-lite",
                    displayName: "Gemini 3.5 Flash-Lite",
                    inputPer1M: 0.3,
                    outputPer1M: 2.5,
                    contextWindow: 1_000_000,
                    isRecommended: false
                ),
                BYOKModelDescriptor(
                    id: "gemini-3.1-pro-preview",
                    displayName: "Gemini 3.1 Pro Preview",
                    inputPer1M: 2,
                    outputPer1M: 12,
                    contextWindow: 1_000_000,
                    isRecommended: false
                ),
            ]
        }
    }

    /// Migrates only known old or intentionally unsupported IDs. Unknown
    /// custom IDs are preserved.
    func normalizedModelID(_ modelID: String) -> String {
        switch (self, modelID) {
        case (.anthropic, "claude-sonnet-4-6"):
            return "claude-sonnet-5"
        case (.anthropic, "claude-opus-4-7"), (.anthropic, "claude-opus-4-8"):
            return "claude-opus-5"
        case (.anthropic, "claude-fable-5"):
            // Fable is intentionally unsupported for consumer-app BYOK:
            // its cost and always-on reasoning are a poor fit for short tasks.
            return defaultModelID
        case (.openAI, "gpt-5.5"):
            return "gpt-5.6-sol"
        case (.openAI, "gpt-5.5-mini"):
            return "gpt-5.6-terra"
        case (.openAI, "gpt-5.5-nano"):
            return "gpt-5.6-luna"
        case (.google, "gemini-3-flash-preview"), (.google, "gemini-3.5-flash"):
            return "gemini-3.6-flash"
        case (.google, "gemini-3.1-flash-lite-preview"),
             (.google, "gemini-3.1-flash-lite"):
            return "gemini-3.5-flash-lite"
        default:
            return modelID
        }
    }
}
