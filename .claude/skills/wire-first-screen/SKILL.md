---
name: wire-first-screen
description: After /new-app --commit renders templates, wire the first-launch surface and the interactive onboarding + About replay contract from DECISIONS/010-first-sixty-seconds.md. Preserve external-route bypasses, defer permissions to feature intent, and honor native-feature enables from DECISIONS/004. Invoked as Phase B step 2 of /new-app --commit.
---

# /wire-first-screen

The gap the end-to-end smoke test surfaced: the rendered templates compile, but `SeedApp` and `ContentView` don't actually *present* `OnboardingView` or honor the "seen onboarding" gate. A bare `xcodebuild` passes; a real user launches and the onboarding never fires. This skill closes that gap.

## When to use

- Inside `/new-app --commit` as Phase B step 2, after `rename-template.sh` runs.
- Re-wiring an existing app's first-screen flow if `DECISIONS/010` is amended (rare — usually that's an addendum, not a rewire).

## When NOT to use

- For an app whose ADR 010 explicitly elected "no onboarding" — this skill detects that and exits cleanly with no edits.
- For non-portfolio apps — the patterns this wires assume the iApp Swift template's structure.

## Forbidden agent behavior

**Never invent the first-screen pattern on the user's behalf.** This skill reads the pattern from `DECISIONS/010-first-sixty-seconds.md` (which was filled during `/new-app --draft` step 11). If the ADR is silent or ambiguous, surface the gap via `AskUserQuestion` rather than picking a default.

## Inputs

- `DECISIONS/010-first-sixty-seconds.md` — frame-by-frame narration, onboarding decisions, the chosen first-screen pattern.
- `DECISIONS/004-native-feature-checklist.md` — which native features are on (Apple Intelligence gates may need a permission ask in second 0-15; notifications may need the deferred-ask pattern).
- `DECISIONS/006-naming-and-bundle-id.md` — to derive the UserDefault key namespace.
- `DECISIONS/009-signature-motion.md` — the motion principle this skill turns into code (see step 6).
- `DECISIONS/014-delight-moments.md` — the 3–5 delight moments this skill applies to the first screen (see step 6).
- `DECISIONS/003-monetization.md` — the tier; paid tiers need a reachable `PaywallView` (see step 6).

## What it edits

- `<AppName>/<AppName>App.swift` — adds the `@AppStorage("seenOnboarding")` gate, wires `OnboardingView` as the cover sheet or the conditional root.
- `<AppName>/Views/ContentView.swift` — replaces the placeholder TabView with the chosen first-screen pattern (single-screen + sheets per `templates/swift/Seed/Services/_Disabled/NavigationRouter.swift`, or tab-based, or other per ADR 010).
- `<AppName>/Theme/SignatureMotion.swift` — rewrites the modifier body to the ADR 009 principle when it is not the Breathing default (see step 6).
- `<AppName>/Theme/DelightMoments.swift` — adds an app-specific bespoke delight modifier if ADR 014 picked a moment not already covered by the shipped reel patterns (see step 6).
- `<AppName>/Views/OnboardingView.swift` — specializes the four-page interactive template around the app's promise, input, payoff, and trust story.
- `<AppName>/Views/Settings/AboutView.swift` — adds full-screen replay without resetting user data.

## Steps with the user

1. Read the three input ADRs.

2. Parse ADR 010 for the "Onboarding decisions" section:
   - **Onboarding required?** (yes / no — some apps elect no onboarding)
   - **Pattern** — cold start / interactive carousel / another explicitly justified pattern.
   - **First-screen surface** — single screen + sheets / tabbed / hero-then-list / etc.

3. If onboarding decision is ambiguous: **`AskUserQuestion` — Onboarding pattern.**
   - Question: *"ADR 010 doesn't specify the onboarding pattern. Pick one (we'll write an addendum to 010 capturing this)."*
   - Options: "Interactive carousel (recommended portfolio pattern)" / "Cold start (no onboarding)" / "Other"

4. Parse ADR 004 for permission-asking native features (notifications, camera, photos, Live Activities). Record where each permission is deferred until the user invokes that feature. Onboarding may demonstrate the outcome with disposable local state, but must never trigger the permission prompt.

5. Edit `<AppName>App.swift`:
   - Add `@AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false` to the App struct, or use a `SubscriptionManager`-style flag if the app has multi-flag state.
   - Wire the gate per the chosen pattern:
     - **Cold start (no onboarding):** no gate — leave `SeedApp` body as-is.
     - **Sheet on top of home:** `.sheet(isPresented: $hasSeenOnboarding.inverted) { OnboardingView() }` on `ContentView()`.
     - **Conditional root:** `if hasSeenOnboarding { ContentView() } else { OnboardingView() }`.
   - Preserve external-route handling above the gate: files, deep links, widgets, Spotlight, Share imports, and App Intents must complete onboarding and continue to the requested destination.

6. Edit `<AppName>/Views/ContentView.swift`:
   - Replace the placeholder TabView with the chosen first-screen surface. The single-screen + sheets pattern is the most common; tabbed is the second.
   - Preserve the Settings entry point — every app needs Settings reachable.
   - Use `AppTheme`, `Typography` and `Spacing` tokens (no `.system(size:)`, no `#000`/`#FFF`, no magic-number padding).
   - **Signature motion — close the ADR→code loop.** Read `DECISIONS/009`. The template ships `Theme/SignatureMotion.swift` implementing Breathing (idle); if ADR 009 picked a different principle, rewrite `SignatureMotionModifier`'s `body` to implement it — keep the `.signatureMotion(active:)` entry point and the `active:` contract unchanged so call sites are stable. Apply `.signatureMotion()` to the first screen's primary surface. An ADR 009 with no `.signatureMotion()` call site is the bug this step exists to prevent — and `SignatureMotionWiredTests` fails the build if it happens.
   - **Delight moments — close the ADR→code loop.** Read `DECISIONS/014`. The template ships `Theme/DelightMoments.swift` with the reusable reel patterns (`.resultReveal()` for completion/result views, `.celebrationPop(_:)` for milestone moments). Apply each chosen moment to the first screen's matching action surface — a result view gets `.resultReveal()`, a finished operation or streak hit gets `.celebrationPop()`. If ADR 014 picked a bespoke moment no shipped pattern covers, add it to `DelightMoments.swift` as one more modifier, never scattered inline. A moment that ADR 014 picked but no view applies is the delight half of the same "ADR that produced no code" gap.
   - **Paywall reachability.** Read `DECISIONS/003`. For Tier 1/2/3, the wired first screen MUST present `PaywallView` from a real path — a Pro-feature gate if the app has one, otherwise a "Go Pro" row in `SettingsView`. A `PaywallView` that nothing presents is dead monetization shipped by default.

7. Specialize `OnboardingView` using [`recipes/swift/add-interactive-onboarding.md`](../../../recipes/swift/add-interactive-onboarding.md):
   - Default to four pages: promise → input → payoff → trust; three to five is the allowed range.
   - Give at least two pages an honest live interaction using disposable sample state.
   - Keep Skip available, provide back/Next controls, use a motion-safe page transition, support AX Dynamic Type, and keep controls at least 44 points.
   - Never add a permanent onboarding, “Designed for iPad,” or replay announcement to Home.

8. Add “Replay Onboarding” to Settings → About as a `fullScreenCover`. Replay presents the exact production flow, dismisses back to About, and never resets or deletes user data.

9. Run `xcodebuild build -scheme <AppName>` to verify the wiring compiles. Test fresh completion, Skip persistence, About replay, external-route bypass, Reduce Motion, VoiceOver, and the longest locale. Report status.

10. **`AskUserQuestion` — Approve wiring.**
   - Question: *"First-screen wired per ADR 010. Build is <green/red>. Approve, or revisit?"*
   - Options: "Approve — proceed to next /new-app --commit step" / "Revisit ADR 010 first" / "Show me the diff"

## Output

```
/wire-first-screen

Read ADR 010 (pattern: interactive carousel) + ADR 004 (camera deferred)
✓ <AppName>App.swift   — @AppStorage gate added, sheet wiring added
✓ ContentView.swift     — replaced placeholder with hero-then-list pattern
✓ OnboardingView.swift  — promise/input/payoff/trust with two live demos
✓ AboutView.swift       — full-screen replay added

Build: PASSED
```

## Cross-references

- [DECISIONS/010-first-sixty-seconds.md](../../../DECISIONS/010-first-sixty-seconds.md) — the narration this skill operationalizes
- [DECISIONS/004-native-feature-checklist.md](../../../DECISIONS/004-native-feature-checklist.md) — feature toggles whose permission prompts must be deferred until intent
- [portfolio/REUSE_INDEX.md](../../../portfolio/REUSE_INDEX.md) — single-screen + sheets pattern, interactive onboarding
- [CLAUDE.md](../../../CLAUDE.md) — Maturity matrix; this skill is 🟡 (LLM contract), backed by the `xcodebuild build` check (⬜ Automation)
- [.claude/skills/new-app/SKILL.md](../new-app/SKILL.md) — Phase B step 2 invokes this skill
