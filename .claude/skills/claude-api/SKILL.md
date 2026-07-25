---
name: claude-api
description: Build, debug, and optimize Claude API / Anthropic SDK usage within the Kindling context. Apps built with this skill should include prompt caching. Also handles migration between Claude model versions for any portfolio app or Kindling-side tooling that calls the API.
---

> SOURCE: universal claude-api skill, scoped to Kindling

# /claude-api

Kindling itself doesn't ship runtime Claude API calls (the *wizard* runs in Claude Code, not via the API). But future tooling or child apps may, and this skill guides that work.

## When to TRIGGER

- A file imports `anthropic` or `@anthropic-ai/sdk`.
- User asks about Claude API, Anthropic SDK, or Managed Agents in the context of Kindling.
- User adds/modifies a Claude feature (caching, thinking, compaction, tool use, batch, files, citations, memory).
- Migration between Claude model versions (Opus 4.5 → 4.6 → 4.7, etc.).
- Questions about prompt caching / cache hit rate in an Anthropic SDK project.

## When to SKIP

- File imports `openai` or another provider SDK.
- Filename like `*-openai.py` / `*-generic.py`.
- Provider-neutral code.
- General programming / ML questions unrelated to Claude.

## What this skill enforces in Kindling context

1. **Latest models first.** When building Claude-using tooling, default to the latest Claude 4.x family unless there's a reason to pin.
2. **Prompt caching always on.** Any non-trivial prompt should use prompt caching headers; cache the static portions (system prompt, tool defs, large context).
3. **Tool use over fine-tuning.** For structured outputs, prefer tool use with strict schemas.
4. **No tracking.** Per NOT_FOR.md §7, any analytics on Claude API calls must be aggregate-only — no per-user identifiers.
5. **Apple Intelligence preference.** If the work could run on-device via Foundation Models, prefer that (per ADR 003's Tier 3 logic — Apple Intelligence is what justifies Tier 3 pricing, not server-side Claude API).

## Steps

1. Identify the use case (new feature / migration / debugging).
2. Read the current implementation if any.
3. Apply the Kindling rules above.
4. For new code: scaffold with prompt caching, tool use schemas, deterministic-fallback wrappers.
5. For migration: check the changelog between the source and target model versions; update accordingly.

## Cross-references

- [docs/NOT_FOR.md](../../../docs/NOT_FOR.md) §7 — tracking restrictions
- [DECISIONS/003-monetization.md](../../../DECISIONS/003-monetization.md) — why Apple Intelligence is preferred over server Claude for portfolio apps
- [portfolio/REUSE_INDEX.md](../../../portfolio/REUSE_INDEX.md) — `templates/swift/Seed/Services/_Disabled/OnDeviceAIService.swift` for the on-device gating pattern
