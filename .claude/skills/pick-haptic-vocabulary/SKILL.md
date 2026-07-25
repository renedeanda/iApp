---
name: pick-haptic-vocabulary
description: Pick 3 starter haptics from the 24-pattern haptic catalog for the new app. Soft cap of 8 enforced via /earn-haptic for additions. Writes DECISIONS/012-haptic-vocabulary.md.
---

# /pick-haptic-vocabulary

Haptics are **bandwidth-limited** (a lesson recorded in RECENT_LEARNINGS.md — after 8 patterns, users stop distinguishing them). Every new app starts with 3 from the catalog; more must be *earned*.

## When to use

- During `/new-app --draft` step 13, after motion + delight are picked.

## When NOT to use

- Adding a 4th+ haptic — use `/earn-haptic` instead.
- For ad-hoc `UIImpactFeedbackGenerator(...)` calls in views — those are forbidden; everything goes through `HapticManager` + a declared pattern.

## The 24 patterns (the canonical catalog)

(Full source: `templates/swift/Seed/Utilities/_HapticVocabulary/HapticPatterns.full.swift` — a vocabulary distilled from a shipped production app.)

Notable patterns the wizard typically draws from:

- `bloomOpen` — soft expansion (for "begin a focused thing")
- `completionRing` — three quick taps (for "you're done")
- `senseTickDescending` — slowing rhythm (for countdown / grounding)
- `reminderSoft` — single soft tap (for notification)
- `favoriteBurst` — quick burst with rebound (for "starred")
- `launchBreath` — slow inhale (for app open)
- ... 18 more in the full catalog

## Forbidden agent behavior

**Never pick the 3 starter haptics on the user's behalf when this skill runs inside `/new-app`.** The bandwidth limit (8) is a hard taste rule — picking for the user invites accidental drift past the cap on later apps. The agent filters and recommends; the user picks via `AskUserQuestion` in three roles.

## Steps with the user

1. Read mission (`000`), signature motion (`009`), and delight moments (`014`) from prior ADRs.

2. **`AskUserQuestion` #1 — Begin-a-thing pattern.**
   - Question: *"Pick the haptic for the app's primary 'begin' action (e.g., starting a focus session, opening a note, casting a vote)."*
   - Options: 3 candidates from the catalog tailored to mission — typically `bloomOpen`, `launchBreath`, or `softTickAscending`. Each option's description names the action it fires on. Recommended labeled.

3. **`AskUserQuestion` #2 — Completion pattern.**
   - Question: *"Pick the haptic for the app's completion moment (e.g., session done, note saved, task marked complete)."*
   - Options: 3 candidates — typically `completionRing`, `favoriteBurst`, or `senseTickDescending`. Each option's description names the moment.

4. **`AskUserQuestion` #3 — Ambient feedback pattern.**
   - Question: *"Pick the third haptic — typically lighter, for ambient feedback or notification (e.g., reminder, toggle on/off, small confirmation)."*
   - Options: 3 candidates — typically `reminderSoft`, `tapAcknowledge`, or `silentBeat`.

5. For each picked pattern, **`AskUserQuestion` follow-up** to capture the specific firing action (free-form via "Other" with 2 examples from the catalog seeded as chips).

6. **`AskUserQuestion` — Reduce Haptics gating.**
   - Question: *"How should haptics gate on accessibility settings?"*
   - Options: "Reduce Motion check only (`UIAccessibility.isReduceMotionEnabled`)" / "Dedicated `reduceHaptics` user setting" / "Both"
   - Either is acceptable per CLAUDE.md; the user picks the one consistent with the app's settings surface.

7. Write `DECISIONS/012-haptic-vocabulary.md` with the table shape from TEMPLATE.md (3 rows: pattern / firing-action / mission-fit one-liner).

8. After Phase B commit: wizard writes `Seed/Utilities/HapticPatterns.swift` containing only the 3 chosen patterns. The full 24 stays at `_HapticVocabulary/HapticPatterns.full.swift` as reference.

## Discipline

- **Soft cap: 8 patterns.** Add a 4th–8th via `/earn-haptic` (writes addendum).
- **Hard cap: 10.** Beyond 10 requires PR + reviewer sign-off.
- **No raw `UIImpactFeedbackGenerator` calls in views.** Always go through `HapticManager.play(.<pattern>)`.

## Cross-references

- [portfolio/REUSE_INDEX.md](../../../portfolio/REUSE_INDEX.md) — Haptic vocabulary row (template gold-standard)
- [portfolio/RECENT_LEARNINGS.md](../../../portfolio/RECENT_LEARNINGS.md) — bandwidth limit lesson
- [CLAUDE.md](../../../CLAUDE.md) taste rule 2 — haptics are earned
- [/earn-haptic](../earn-haptic/SKILL.md) — for unlocking a 4th+ pattern later
- [DECISIONS/012-haptic-vocabulary.md](../../../DECISIONS/012-haptic-vocabulary.md) — worked example shape
