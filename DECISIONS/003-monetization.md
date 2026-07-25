# ADR 003 — Monetization (Portfolio-Wide Strategy)

- **Status:** Accepted
- **Date:** 2026-05-08
- **App:** Kindling (portfolio-wide strategy)
- **Authors:** Kindling maintainers
- **Supersedes:** prior draft (misframing) + first portfolio-strategy rewrite (lacked tier granularity)

## Context

Monetization is a **portfolio-strategy decision**, not a per-app decision in isolation. Every individual app's pricing choice (in its own `DECISIONS/003-monetization.md`) contributes to a **portfolio-wide mix that targets multiple distinct audience segments and revenue patterns**. The portfolio's value is the *deliberate range* — not a single bet on subs, not a single bet on IAP, not a single bet on free.

This ADR codifies the five-tier pricing ladder, the data points that justify it, and the pre-positioning logic the `/new-app` wizard runs to slot a new app into the right tier before asking the user to confirm.

## Decision

**The studio uses a 5-tier pricing ladder.** Every app sits in exactly one tier. The tier is chosen based on mission, infrastructure costs, audience, and Universal Purchase status — not on what's trendy.

### Tier 0 — Pure free, forever *(the gift)*

- **Ethos:** generosity. The studio commits to giving away crafted value.
- **Sustainability:** zero ongoing infra costs. No AI inference, no hosted sync, no recurring content delivery. If the app has costs, it's the wrong tier.
- **Audience:** anyone — especially users who would otherwise never download a paid app. Halo effect for the studio.
- **When to use:** small, complete, emotionally simple apps. Mission is the whole product.
- **Portfolio constraint:** maintain 1–2 of these at any time. Free-forever means actually committing to upkeep without revenue offset.

### Tier 1 — Small lifetime IAP, $3.99–$7.99 *(the friendly purchase)*

- **Ethos:** honest one-time exchange for crafted utility.
- **Sustainability:** small revenue floor; Family Sharing amplifies addressable customer count (one purchase covers a household up to 6).
- **Audience:** subscription-averse users, casual converters, family-sharing households.
- **When to use:** simpler apps (often RN), utility-leaning, content unlocks, optional polish.
- **Portfolio constraint:** the IAP unlocks an *extension*, never the core mission. Free version stays useful.

### Tier 2 — Standard lifetime IAP, $9.99–$14.99 *(the proper buy)*

- **Ethos:** confident pricing for substantial standalone value. No subscription required — value is bounded, not ongoing.
- **Sustainability:** meaningful revenue per user without commitment fatigue. Maps to Apple Price Tier 10–15.
- **Audience:** prosumer, sub-averse-but-quality-willing.
- **When to use:** substantial scoped apps without ongoing infra costs. Computational-on-device tools, engine apps, multi-feature utilities.
- **Portfolio constraint:** must be confidence-ready — pricing it $14.99 says "this is worth real money."

### Tier 3 — Subscription with lifetime escape, $29–$99 lifetime *(the deep tool)*

- **Ethos:** subscription only when ongoing infra costs *justify* it — always offer lifetime as an honest exit. Lifetime IAP price ≈ 2–3 years of annual sub.
- **Sustainability:** recurring revenue funds the ongoing costs (AI inference, hosted sync, server-side processing). Lifetime IAP captures the sub-averse fraction.
- **Audience:** power users + AI consumers + people who already pay for subs comfortably.
- **When to use:** apps with genuine ongoing infrastructure costs. Apple Intelligence consumers especially.
- **Portfolio constraint:** lifetime IAP always offered alongside, family-shareable, sized at ~2–3 years annual sub equivalent.

### Tier 4 — Premium upfront, $19.99+ *(the specialist tool)*

- **Ethos:** confidence that the audience expects to pay upfront for specialized tools.
- **Sustainability:** high revenue per user, low-volume. Niche but defensible.
- **Audience:** professional, specialized — developers, designers, audiophiles, traders.
- **When to use:** apps for specialists where the audience already pays $20+ upfront (Working Copy tier, Soulver tier).
- **Portfolio note:** an *empty* Tier 4 slot is fine — holding it open demonstrates the pricing ceiling until the right mission arrives.

## Universal Purchase dimension

Mac Catalyst is opt-in per app (see [ADR 001](001-tech-choice.md)). Apps that ship Universal Purchase (single bundle ID for iOS + iPadOS + macOS) sit at the top of their tier band — more value per purchase justifies pricing confidence, and Mac usage extends app lifespan (laptops outlive phones), which strengthens lifetime-IAP economics vs subscription.

Universal Purchase is tracked as a flag in [portfolio/MONETIZATION_MATRIX.md](../portfolio/MONETIZATION_MATRIX.md). The `/pick-tech` wizard step asks "Mac Catalyst likely? (yes / no / decide later)" and the answer cascades into `/pick-monetization` tier positioning.

## Worked example — a fictional 8-app portfolio

Your real table lives in [portfolio/MONETIZATION_MATRIX.md](../portfolio/MONETIZATION_MATRIX.md). This is the shape, filled with fictional apps:

| App | Tier | Pricing | Universal | Surface |
|---|---|---|---|---|
| Petal *(gratitude prompts)* | 0 — pure free | $0 | iOS-only | RN |
| Sprig *(daily quote)* | 0 — pure free | $0 | iOS-only | RN |
| Pause *(breathing timer)* | 1 — small lifetime IAP | $4.99 | iOS-only | Swift |
| Dots *(habit marks)* | 1 — small lifetime IAP | $4.99 | iOS-only | RN |
| Ledger *(trip-cost engine)* | 2 — standard lifetime IAP | $14.99 | iOS-only | Swift |
| Horizon *(AI day-planner)* | 3 — sub with lifetime escape | $3.99/mo · $29.99/yr · $79.99 lifetime | iOS-only | Swift |
| Quill *(synced notes)* | 3 — sub with lifetime escape | $4.99/mo · $39.99/yr · $99.99 lifetime | **Universal** | Swift |
| (slot) | 4 — premium upfront | $19.99+ | open | open |

**Mix distribution:** 2 / 2 / 1 / 2 / 0 across Tiers 0–4. No tier over cap. Tier 4 deliberately open.

## Strategic rationale

1. **Audience diversification.** iOS users with any active subscription are estimated at 5–7% of total users at any time (industry estimates, data.ai / Sensor Tower). A subscription-only portfolio writes off the other ~93–95%. Tier 0–2 apps capture the sub-averse majority.

2. **Revenue power-law buffering.** The top 5% of subscribers drive ~85% of subscription revenue (RevenueCat State of Subscriptions 2024). Sub revenue is long-tail-thin — Tier 1–2 lifetime IAPs cushion when the power law doesn't reach a given app.

3. **Family Sharing amplification.** Apple defaulted Family Sharing on for IAPs and subs in 2021. Tier 1 lifetime IAPs especially benefit — one $4.99 purchase covers a household of up to 6.

4. **Tier 0 as halo effect.** Pure-free apps aren't revenue drivers; they're the studio's brand handshake. A new user who installs a free app and finds it genuinely well-crafted has a meaningfully higher chance of installing a paid app later.

5. **Lifetime IAP as bridge in Tier 3.** Every Tier 3 sub also offers a lifetime IAP. This converts sub-averse users who would bounce + signals confidence (lifetime pricing requires believing the app is useful for years).

6. **Tier 4 as ceiling proof.** Holding an open Tier 4 slot demonstrates the studio's pricing ceiling. Apps don't need to be subscription-only to charge real money — the right specialist app at $19.99+ upfront is a viable model.

## Two-axis decision for new apps

The `/pick-monetization` wizard runs a **two-axis decision**:

**Axis 1 — Per-app fit.** The pre-positioning logic in [MONETIZATION_MATRIX.md](../portfolio/MONETIZATION_MATRIX.md) considers:

- Tech (Swift vs RN — RN tends toward Tier 0–1)
- Native features enabled (Apple Intelligence / CloudKit / Live Activities → Tier 3)
- Universal Purchase (top of tier band)
- Mission audience (specialist → Tier 4; gift-tier → Tier 0)

**Axis 2 — Portfolio mix.** Cross-reference the current-mix table:

- Would this push any tier past its target ceiling?
- Is an underrepresented tier a plausible fit?
- Surface trade-off acknowledgment if both apply.

Mission always wins. The mix is a tie-breaker. The ADR records both axes' answers.

## Engineering convention — Dev/Debug premium toggle

Every Swift template ships a cross-app contract for testing premium features in DEBUG and RELEASE builds (the dev premium toggle pattern):

- **`UserDefaults.debug.forcePremium`** is the single source of truth. `SubscriptionManager.isPro` short-circuits when set.
- **DEBUG builds:** visible toggle in Settings → Developer.
- **RELEASE builds:** gated behind 7-tap gesture on version string in Settings → About. Override auto-expires after 24h. Cleared on every app update. App Store Reviewer accounts: easter egg suppressed.

This pattern is documented in [docs/HOUSEKEEPING.md](../docs/HOUSEKEEPING.md) and as a recipe in `recipes/swift/dev-premium-toggle.md`. The dev easter egg is explicitly *not* a delight moment — see [docs/DELIGHT_REEL.md](../docs/DELIGHT_REEL.md) "Forbidden delights" clarification.

## Kindling's own status

**N/A.** Kindling is infrastructure for a portfolio, not a portfolio app. It has no App Store presence and no shipping channel that takes money. The repo is MIT-licensed (see [LICENSE](../LICENSE)). Kindling doesn't participate in any monetization mix.

## Options considered

- **All-subscription portfolio** — rejected. Concentration risk + audience exclusion (93–95% of users excluded). SaaS-shop positioning instead of craft studio.
- **All-lifetime-IAP portfolio** — rejected. Subscriptions exist for genuine reasons (AI inference, hosted sync). Killing them forces apps to eat ongoing costs or ship worse products.
- **All-free with ads** — rejected per [NOT_FOR.md](../docs/NOT_FOR.md) §4.
- **Hard quotas** — rejected. Mission fit always trumps quota fit; surface trade-offs, don't enforce them.
- **Skip Tier 4** (no premium upfront slot) — rejected. The open slot demonstrates the ceiling and creates aspirational room for the right specialist app.
- **Skip Tier 0** (every app must pay back) — rejected. Free-forever apps are the studio's brand signal. Without them, the portfolio reads as a paywall garden.

## Consequences

- **Unlocks:** `/pick-monetization` becomes a 5-tier pre-positioner. New apps land in a likely tier before the user is asked. Strategy is grounded in citable data, not vibes.
- **Forecloses:** monetization drift toward whatever's trendy. Every pricing choice is now also a tier-fit choice + portfolio-mix choice.
- **Cost to revisit:** small. Mix evolves with each app shipped; the current-portfolio table in MONETIZATION_MATRIX.md refreshes with each `/new-app --commit` PR back to Kindling.

## Cross-references

- [portfolio/MONETIZATION_MATRIX.md](../portfolio/MONETIZATION_MATRIX.md) — per-app data, 5-tier ladder, pre-positioning logic, market data points, Universal Purchase tracking, claimed product IDs
- [docs/NOT_FOR.md](../docs/NOT_FOR.md) §11 — when subscription is wrong
- [docs/WHATS_ALLOWED.md](../docs/WHATS_ALLOWED.md) ✅ Paywalls — honest paywall patterns
- [docs/HOUSEKEEPING.md](../docs/HOUSEKEEPING.md) — Dev/Debug Premium Toggle template pattern
- [ADR 001](001-tech-choice.md) — parallel portfolio tech-mix rationale (Swift native + RN deliberate diversification)
- [ADR 015](015-visual-identity.md) — parallel portfolio-diversity logic for visual identity
- [LICENSE](../LICENSE) — Kindling's MIT license (its non-participation in any monetization mix)
