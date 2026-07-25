# Add interactive onboarding (SwiftUI)

> **Source:** `templates/swift/Seed/Views/OnboardingView.swift` (per [REUSE_INDEX](../../portfolio/REUSE_INDEX.md)).
>
> **Reliability:** ✅ proven pattern — the same shell shipped in multiple production apps, specialized per app around its own workflow (color tools, structured data, documents).

## When NOT to use

- Do not add pages simply to advertise a feature list. If the app has one obvious action and no meaningful interaction to preview, use two concise pages or launch directly into the product.
- Do not ask for camera, photo, notification, pasteboard, account, or tracking permission during onboarding. Defer every permission until the user chooses the feature that needs it.
- Do not leave a “Designed for iPad,” “What’s new,” or replay card permanently on Home. Onboarding education belongs in this full-screen flow and its About replay entry.
- Do not put a fake control in the carousel. A tap must visibly change the real local model or an honest disposable sample.

## Experience contract

Use three to five pages; four is the portfolio default:

1. **Promise** — state the job and why the app is different.
2. **Input** — let the user manipulate a disposable sample.
3. **Payoff** — preview the app’s primary success moment.
4. **Trust** — explain privacy, sync, and deferred permissions accurately.

The shell must provide:

- a full-screen `TabView` with swipe navigation, a restrained custom page indicator, and a clear Next action;
- Skip on every page and a back control after page one;
- at least two app-specific live interactions before the final CTA;
- no idle looping animation; use the app’s motion-safe helper for page changes and respect Reduce Motion;
- scrollable page content, a 560-point compact readable measure, Dynamic Type,
  44-point controls, meaningful VoiceOver labels, and an announced page count;
- at regular width, compose the same narrative and interaction in a centered
  two-pane layout (roughly 320 + 520 points); do not invent iPad-only copy or
  preserve a narrow phone column in a large empty canvas;
- a primary final action that continues into a safe sample when one exists, plus a secondary “explore on my own” path;
- external routes that bypass onboarding so a file, intent, widget, or deep link is never swallowed;
- an About-row `fullScreenCover` that replays the exact production onboarding without resetting or deleting user data.

## Files to adapt

1. Copy `templates/swift/Seed/Views/OnboardingView.swift` and replace every page’s copy, symbol, and demo with the app’s real first-success story.
2. Gate the first launch from the app root with a persisted completion flag. Completion and Skip both set it.
3. Add “Replay Onboarding” to `Views/Settings/AboutView.swift`. Replay dismisses back to About and does not mutate the completion flag.
4. Add every string to `Localizable.xcstrings` before shipping. Technical sample content can use `Text(verbatim:)`; explanatory prose cannot.
5. Document the chosen pages and permission deferral in `DECISIONS/010-first-sixty-seconds.md`.

## Verification

- Fresh install: the first page appears once; complete and Skip both reach the app and stay completed after relaunch.
- Replay: Settings → About → Replay Onboarding presents full-screen and returns to About.
- Interactions: every demo changes visibly and never touches user files, clipboard, camera, network, or account state.
- External launch: deep links, App Intents, Share imports, Spotlight, and widgets bypass onboarding and land correctly.
- Accessibility: test VoiceOver, Reduce Motion, light/dark themes, landscape, iPad multitasking, and AX Dynamic Type.
- Page changes post the localized progress string as a VoiceOver announcement;
  the visual indicator is one combined accessibility element, not four dots.
- Adaptive layout: verify the regular-width two-pane page, compact Split View
  stacking, and vertical centering on the first page.
- Localization: run the app and extension parity tests, then spot-check the longest supported locale on all pages.
