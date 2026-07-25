# Launch Audit Checklist

> Run this on every app before submission. It encodes five cross-cutting
> concerns + the gotchas surfaced by auditing a real multi-app portfolio. Each
> item names the gold-standard source and the mistake it prevents.

## 1. Rate-this-app prompt
- [ ] A review prompt exists and is wired to a **genuine success moment** (task done, export complete, milestone) — never on launch, never after an error.
- [ ] It throttles: score threshold + ≥14-day install age + ≥30-day inter-prompt + once-per-version + **TestFlight/sandbox suppressed**.
- [ ] Prefer the **happy-gate** ("Enjoying X?" → I love it / Could be better → feedback / Not now). It IS Apple-compliant — it filters unhappy users to email instead of burning a system prompt. A *deceptive* modal that fakes the system sheet is the dark pattern, not the happy-gate.
- [ ] A **manual** "Rate" row must **deep-link to write-review** (`https://apps.apple.com/app/id<ID>?action=write-review`), hidden until the listing exists — NEVER route a manual tap through the throttle (it becomes a dead button). The automatic prompt is separate.
- Source: `templates/swift/Seed/Services/_Disabled/AppReviewService.swift`, `recipes/swift/add-app-review.md`, `recipes/rn/add-rn-rating.md`.

## 2. Permission sweep
- [ ] Every permission is requested **on-demand or after a priming toggle**, with context — never at cold launch.
- [ ] Every `NS*UsageDescription` is specific and branded. **No unexpanded `$(PRODUCT_NAME)`** (an Expo `expo-image-picker` default trap — set `cameraPermission`/`microphonePermission: false` if unused).
- [ ] No permission declared for a framework the app doesn't use.
- [ ] iOS 17+ calendar: reading events *requires* `requestFullAccessToEvents()` + `NSCalendarsFullAccessUsageDescription` (there is no read-only read API) — that's correct, just keep the copy honest about not writing.

## 3. Cross-promotion
- [ ] "Made with care by Your Studio" link in **every** app (→ your studio site, e.g. `https://example.com`).
- [ ] "More from Your Studio" live-apps list **only where it fits the brand** — not in the most intimate/minimal apps (a couples app, a quiet journal) where a cross-sell breaks the spell.
- [ ] The list is **registry-driven and auto-hides** apps with no live App Store URL (`portfolio/CROSS_PROMO_REGISTRY.json`; taglines come from `PORTFOLIO.md` — don't fabricate). No incentivization, no modal.
- [ ] The vendored `CrossPromoRegistry.json` is actually in Copy Bundle Resources (else it silently shows nothing).
- Source: `Seed/Services/PortfolioRegistry.swift`, `Seed/Views/Settings/MoreFromStudioSection.swift`, `recipes/swift/add-cross-promo.md`.

## 4. Alternate app icons (Snow + Noir)
- [ ] Per-identity, but the seasonal pair uses one **exact studio palette**: Snow `#F4F4F6`/`#0A0A0A` (black-on-white), Noir `#0A0A0A`/`#F4F4F6` (white-on-black) — Snow is the exact inverse of Noir. **No silver, no accent tint.**
- [ ] Named **"Noir"** for the dark B&W-film variant — never "Classic" (means the default icon) or "Black".
- [ ] **Skip** both if the primary icon is already black/white/monochrome (it duplicates what ships).
- [ ] **Render the PNGs before building** — the `.appiconset`s ship with only `Contents.json` placeholders from a Linux session; the build FAILS until rendered. **Eyeball each at 1024²** — the inverse pair must be crisp and distinct from any existing light/dark variant the app already offers.
- [ ] Each set registered in `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES` (project.yml) / `CFBundleAlternateIcons`, and the enum/asset names match.
- Source: `Seed/Theme/AppIconOption.swift`, `Seed/Views/Settings/AppIconPickerView.swift`, `bin/render-alt-icons.py`, `recipes/swift/add-alternate-icons.md`.

## 5. Live Activities
- [ ] Only ship a Live Activity that tracks something genuinely **in-flight** with a clear **end event** (a timer, a trip). Remove any that just **restate a saved fact** (an "it's an office day" activity we shipped once) — it lingers and is awkward to dismiss.
- [ ] Delete **dead scaffold** (an `ActivityAttributes` defined but never registered/started).
- [ ] `WidgetTheme` MUST be **appearance-adaptive** (light/dark pair via a `UIColor { traits in … }` provider). A fixed light-only widget palette renders **black/blank on a dark Lock Screen** (a bug we shipped once).
- [ ] Guard `Text(timerInterval: Date()...endDate)` against a past `endDate` (invalid range → empty render).
- Source: `Seed/SeedWidgets/WidgetTheme.swift`, `recipes/swift/add-live-activity.md`.

## Diff & process hygiene (catches agent mistakes)
- [ ] **Localization catalogs:** never re-serialize a whole `.xcstrings`/`.strings`. Adding N keys should add ~N small blocks, not rewrite the file. If `git diff --shortstat` shows thousands of changed lines for a few keys, an agent reformatted it — restore origin's bytes and re-add only the new keys (the `bin/check-loc-diff.sh` guard flags this; recovery pattern: a JSON load of origin + new keys, re-serialized with `indent=2, separators=(",", " : ")`).
- [ ] New user-facing keys are translated to the app's **full** locale set in the same commit (`/translate`) — Tier-1-only is a tracked debt, not "done".
- [ ] Commits are signed; branch pushed; PR notes any "needs-a-Mac" follow-ups (icon render, build, locale backfill).
