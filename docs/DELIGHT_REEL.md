# Delight Reel — A Catalog of Earned Micro-Joys

A catalog of proven micro-animations and small surprises — patterns that earned their delight in shipped production apps. The `/pick-delight-moments` skill reads this doc and asks the user to pick 3–5 to bake into a new app, then writes `DECISIONS/014-delight-moments.md` and seeds `recipes/swift/delight-animations.md` with copy-ready snippets.

## Discipline

- **Cap at 5 delight moments per app.** Each one consumes a memory budget. Too many delights and they all become noise.
- **Adding a 6th requires an ADR addendum** justifying it (parallel to how `/earn-haptic` works for haptics).
- **Delight is *earned*, not sprinkled.** The wizard rejects "make it more delightful" as a feature request. Pick specific moments tied to specific user actions.
- **Test against Reduce Motion.** Every delight moment must degrade to a tasteful static state when the user has Reduce Motion enabled.

## The reel

Each pattern below has shipped in at least one production app. For every entry: what it is, what user action fires it, and how it degrades under Reduce Motion. The reusable ones ship as working code in `templates/swift/Seed/Theme/DelightMoments.swift` and `templates/swift/Seed/Theme/SignatureMotion.swift`.

### Completion & celebration

| Pattern | What it is | Fires on | Reduce Motion fallback |
|---|---|---|---|
| **Concentric ring bloom** | Three rings expand outward at staggered timing, fading to the surface color. The "you're done" moment. | End of a timed session or completed exercise. | Rings appear at final size with a gentle opacity fade only. |
| **Streak-as-celebration burst** | Confetti-free milestone celebration: a held breath of color radiates outward, then settles. Missing a day is *silent* — the next return says "welcome back," never shame. | Hitting a streak milestone (7, 30, 100 days). | Static color wash with a text acknowledgment. |
| **Tally type-animation** | A number ticks up monospaced, like a mechanical odometer, when a cumulative stat increments. | A session/trip/entry closing and a running total updating. | Number updates instantly to the final value. |
| **Result reveal** | Soft scale-up + fade for any view inserted on a completion/success state. Ships as `.resultReveal()`. | An operation finishing successfully. | Opacity fade only, no scale. |
| **Celebration pop** | A brief pop keyed to a trigger value. Ships as `.celebrationPop(_:)`. | Milestone / completion moments. | No pop; the state change renders directly. |

### Ambient & launch

| Pattern | What it is | Fires on | Reduce Motion fallback |
|---|---|---|---|
| **Breathing orb expand-on-tap** | A resting orb that "wakes" when tapped — one slow inhale signaling readiness. Idle breathing ships as the template's default signature motion in `SignatureMotion.swift`. | Tap on the home surface before beginning a session. | Orb renders at rest scale; tap produces a subtle opacity shift. |
| **Soft launch fade-in** | Palette wash + logo fade-in over ~600 ms on the first frame after launch. Sets the tone before the user does anything. | App launch. | Content appears immediately at full opacity. |
| **Dark palette settling** | The palette appears instantly, but one focal element takes ~400 ms to settle into place. Conveys "the app is waking, not waiting." | App launch in a dark-first identity. | The focal element renders settled from the first frame. |
| **Quote/content blur-to-sharp reveal** | Today's featured content starts blurred and sharpens over ~800 ms. Mirrors the "settling into a moment" feeling. | App open on a daily-content surface. | Content renders sharp immediately. |

### Chrome & navigation

| Pattern | What it is | Fires on | Reduce Motion fallback |
|---|---|---|---|
| **Liquid Glass under floating bars** | Subtle vibrancy + edge-light under toolbars, FABs, and tab bars makes the chrome feel like it's floating on the content. Works under any palette. | Always-on chrome treatment (not action-fired). | Not motion-dependent; verify contrast under Reduce Transparency. |
| **Brutalist hard-cut transitions** | Sheet present/dismiss with no spring, no fade. Hard cut. The visual identity *is* the absence of softness — it earns its place only when the whole app honors it. | Sheet present / dismiss in a brutalist identity. | Already motion-free. |
| **Live Activity → Dynamic Island morph** | A Live Activity expands from the lock screen into the Dynamic Island, then morphs into the in-app destination. The connection between surfaces feels physical. | Notification / Live Activity tap. | System transitions only; no custom morph. |
| **Type-weight snap** | When state flips (e.g. "early" → "leave now"), a hero number snaps from soft to bold weight with no animation. A typographic moment, not a motion moment. | An engine/state threshold being crossed. | Already motion-free. |

### Direct-manipulation feedback

| Pattern | What it is | Fires on | Reduce Motion fallback |
|---|---|---|---|
| **Save → favorite haptic chain** | Save gets a soft haptic; mark-as-favorite gets a distinct "bloom" haptic + brief icon scale-up. Two-step actions get two-step feedback. | Saving, then favoriting, an item. | Haptics respect the reduce-haptics setting; icon change renders without scale. |
| **Descending haptic count** | During a counted-down exercise (e.g. 5-4-3-2-1 grounding), each tick down is a softer haptic + a visual count-shrink. The deceleration is the design. | Each step of a guided countdown. | Visual count only, no shrink animation. |
| **Dot/cell fill on tap** | Tap an empty dot → it fills with the accent color via a ~200 ms spring. Subtle and instant. The reward is the mark itself becoming permanent. | Marking a habit/task done. | Fill renders instantly. |
| **Card flip on tap** | Tapping a summary card flips it in 3D to reveal detail + actions. One of the few cases where playful animation earns its place. | Tap on a card. | Cross-fade between faces instead of a flip. |
| **Orbital state-change wave** | A wave propagates around a ring marking a state transition (idle → active → cool-down), then settles. | A session state change. | Ring recolors to the new state without the traveling wave. |
| **Staged onboarding fade-in** | Each onboarding screen fades in content in two stages: title first (~400 ms), then body (~300 ms later). The pacing tells the user "we'll go at your speed." | Onboarding page appear. | Both stages render immediately. |
| **Per-theme micro-animation registry** | In a multi-theme app, each theme carries its own signature micro-animation (one theme's dots gradient-shift, another's ripple). Theme isn't just color — it's behavior. | The theme's marking interaction. | Each theme's fallback is its static fill. |

## Slots for future patterns

The catalog grows. Examples of moments that would earn a spot if one of your apps ships them:

- **Page-curl easter egg on long-press** — onboarding screen yields a peek of the next under your finger.
- **Spring-back overscroll** with semantic meaning (the spring's pull strength encodes how far over).
- **Type-weight shift on hover/tap** — a number going from 300 → 700 weight as it becomes "active."
- **Color-bleed on navigation** — the previous screen's accent bleeds briefly into the new screen's title before settling.
- **Sound-aware visual** — a tasteful visual response to ambient sound level (microphone permission), e.g. a quiet visualizer that's *not* the point of the app.
- **Time-of-day palette settling** — the app's palette gently shifts toward warmer-at-dawn / cooler-at-dusk.

These are not promises. They are slots. The next app that ships one earns a row.

## How `/pick-delight-moments` uses this doc

```
$ /new-app --draft

> ...
> Pick 3–5 delight moments from the reel. Each consumes a small "weight" budget.

  [1] Concentric ring bloom             — completion moments
  [2] Liquid Glass under floating bars  — chrome
  [3] Brutalist hard-cut transitions    — sheet present/dismiss
  [4] Streak-as-celebration burst       — milestones
  [5] Type-weight shift on tap          — interactive elements
  [6] ...

> Selection (3-5 numbers, comma-separated): 1, 3, 5

Writing DECISIONS/014-delight-moments.md...
Seeding recipes/swift/delight-animations.md with snippets for [1, 3, 5]...
```

The recipe seeded into the new app includes copy-ready Swift snippets for each chosen pattern, with the import paths and contrast verified.

## The code home — `Theme/DelightMoments.swift`

A picked moment that never becomes code is a documented failure mode: an ADR gets filed and most of the chosen moments produce nothing. The Swift template closes that loop the same way it closed the signature-motion loop — with a file.

`templates/swift/Seed/Theme/DelightMoments.swift` is where an app's delight moments live as *code*. It ships the recurring, reusable reel patterns as working, Reduce-Motion-aware `View` modifiers:

- **`.resultReveal()`** — the operation-complete result reveal (soft scale-up + fade). For any view inserted on a completion/success state.
- **`.celebrationPop(_:)`** — a brief celebration pop keyed to a trigger. For milestone / completion moments.

`/wire-first-screen` applies the chosen moments to the first screen using these patterns; an app-specific bespoke moment is added to `DelightMoments.swift` as one more modifier. Every moment in `DECISIONS/014` ends as an applied modifier — never just a table row.

## Forbidden delights

A short list of "delight" patterns that look fun but are actually noise:

- **Confetti for routine actions.** Save-the-form does not deserve confetti.
- **Screen-shake.** Always wrong unless the app is *literally* about earthquakes.
- **Continuous animations in idle state.** Looping spinners, never-ending pulses, ambient particles — they bleed attention.
- **Animation longer than 600 ms** for anything other than a *completion* moment. Use 200–400 ms for transitions, 400–600 ms for state changes, longer only for celebrations.
- **Auto-playing video splash screens.** Never.
- **User-facing easter eggs that delight you (the dev) but no user finds.** If it's a *user-facing delight* and it's not findable, it doesn't count. *(This rule applies to user-facing delights only. **Developer-only debug eggs** — like the 7-tap-on-version-string Premium toggle described in [HOUSEKEEPING.md](HOUSEKEEPING.md) "Dev/Debug Premium Toggle" — are a separate, allowed category. They're intentionally unfindable to general users because they're for the developer's own testing, not user delight.)*

If a proposed delight moment matches any pattern above, the wizard rejects it. Pick something tied to a specific user action, gated behind a specific success state, capped at the right duration.
