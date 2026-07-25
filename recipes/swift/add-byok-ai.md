# Add Bring Your Own Key AI

> **Source:** `templates/swift/Seed/Services/_Disabled/BYOKModelCatalog.swift` (policy + catalog). The runtime client — a focused single-feature provider client, or a richer multi-provider settings manager — is a pattern proven in production, described below.
> **Platform:** Swift

## What it adds

Direct, user-funded access to Anthropic, OpenAI, and Google models without an app-owned proxy. API keys remain in the device Keychain; provider and model preferences may live in `UserDefaults`. User content goes directly to the provider the user configured.

## When to use

- Apple Intelligence is unavailable or insufficient and the feature still has a deterministic fallback.
- The app can explain clearly that content is sent to the selected AI provider.
- BYOK is Pro-gated without paywalling the app's non-AI core.
- The task is bounded enough to cap output, retries, and latency.

## When NOT to use

- A provider key would be bundled with the app or sent through an undeclared proxy.
- The feature has no deterministic fallback.
- The selected model is disproportionately expensive for the job.
- **Claude Fable 5 is intentionally unsupported for this app class.** Its price and always-on reasoning are a poor fit for short capture, classification, summarization, and writing-assist requests. Do not list it, recommend it, or accept it through a custom-model field; normalize an existing saved `claude-fable-5` selection to Sonnet 5.

## Curated catalog

Verify IDs and prices against official provider documentation whenever this catalog changes.

| Provider | Recommended default | Other curated choices |
|---|---|---|
| Anthropic | `claude-sonnet-5` | `claude-haiku-4-5`, `claude-opus-5` |
| OpenAI | `gpt-5.6-terra` | `gpt-5.6-luna`, `gpt-5.6-sol` |
| Google | `gemini-3.6-flash` | `gemini-3.5-flash-lite`, `gemini-3.1-pro-preview` |

The default is the best cost/quality/latency fit for consumer productivity work, not the most expensive model. Keep the picker curated; an advanced custom-ID field may preserve unknown IDs, except the explicit Fable exclusion.

## How

### 1. Graduate the policy

Move `Seed/Services/_Disabled/BYOKModelCatalog.swift` into the app's active `Services/` folder. Keep catalog, pricing metadata, defaults, and migrations in that one file.

### 2. Harvest the runtime deliberately

- Use a narrow single-provider client for a focused request/response feature.
- Use a multi-provider manager only when the app needs multiple configured providers, an active-provider picker, custom IDs, and richer settings.
- Adapt app-specific prompts and response types; do not copy them blindly.
- Use `URLSession` directly. No provider SDK or other third-party dependency is required.
- Set explicit request/resource timeouts, bound retries, and return `nil` into the deterministic fallback.
- Anthropic uses `anthropic-version: 2023-06-01`; its parser must find the first `type == "text"` content block rather than assuming the first block is text.
- For short GPT-5.6 actions, use `reasoning_effort: "none"` when the endpoint supports it.

### 3. Store and disclose safely

- Save API keys in Keychain only, with device-only accessibility when practical.
- Never log keys, request bodies, response bodies, custom model IDs, or user text.
- Store only non-secret provider/model selections in `UserDefaults`.
- The Settings footer and privacy policy must name all supported providers and state that content is sent directly to the selected provider under that provider's terms.
- Deleting app data must delete every provider key and cached "configured" flag.

### 4. Migrate without breaking expert setups

- Migrate only known former curated IDs.
- Preserve unknown custom IDs.
- Normalize `claude-fable-5` to `claude-sonnet-5` even when entered as a custom ID.
- Persist the normalized value so every later request uses the supported model.

### 5. Verify

Test exact curated arrays and defaults, known migrations, preservation of unknown custom IDs, provider response parsing, Keychain deletion, and fallback behavior. Then build every supported platform and run the full suite.

Do not make real billable provider calls in unit tests. Use representative JSON fixtures.
