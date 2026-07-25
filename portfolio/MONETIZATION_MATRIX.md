# Monetization Matrix

Per-app pricing decisions + the 5-tier ladder `/pick-monetization` uses for new apps. Strategic framing lives in [DECISIONS/003-monetization.md](../DECISIONS/003-monetization.md); this doc captures the operational tables, market data, and decision logic. Kindling ships it as a starter — the ladder and market data are ready to use; the per-app table is yours to fill.

Three rules govern every decision:

1. **No ads.** Ever. See [docs/NOT_FOR.md](../docs/NOT_FOR.md).
2. **Subscriptions only when ongoing infra costs justify them.** AI inference, hosted sync, server-side processing. Otherwise: lifetime IAP. See [docs/NOT_FOR.md](../docs/NOT_FOR.md).
3. **Restore Purchases always visible.** Dismiss path on paywall always obvious. See [docs/WHATS_ALLOWED.md](../docs/WHATS_ALLOWED.md) ✅ Paywalls.

And one pattern worth adopting portfolio-wide:

> **Every app's *core mission* is free. Pro/IAP unlocks *extensions*, never the core.** A user who never pays still gets a complete, useful app.

---

## Current portfolio

*(Starter state: empty. Add a row per app as pricing is decided.)*

| App | Tier | Pricing | Universal | Surface | Why |
|---|---|---|---|---|---|
| — | — | — | — | — | — |

Also track **claimed product IDs** here (e.g. `com.example.myapp.pro`) so no two apps collide and legacy IDs stay documented when pricing changes.

---

## The 5-tier ladder

### Tier 0 — Pure free, forever *(the gift)*

| | |
|---|---|
| Pricing | $0 |
| Surface preference | RN often correlates |
| Infra constraint | Zero ongoing costs |
| Audience | Anyone — especially never-payers |
| Strategic role | Halo effect, brand handshake, acquisition funnel |
| Portfolio target | 1–2 apps |

### Tier 1 — Small lifetime IAP, $3.99–$7.99 *(the friendly purchase)*

| | |
|---|---|
| Pricing | Apple Price Tier 5–8 ($4.99–$7.99 USD) |
| Surface preference | RN often correlates |
| Infra constraint | None to minimal |
| Audience | Sub-averse, casual converters, family-sharing households |
| Strategic role | Volume conversion; captures the ~93–95% of iOS users without active subs |
| Portfolio target | 2–3 apps |

### Tier 2 — Standard lifetime IAP, $9.99–$19.99 *(the proper buy)*

| | |
|---|---|
| Pricing | Apple Price Tier 10–20 ($9.99–$19.99 USD) |
| Surface preference | Swift native (substantial scope typically needs it) |
| Infra constraint | None to minimal (on-device compute is fine) |
| Audience | Prosumer, sub-averse-but-quality-willing |
| Strategic role | Confident standalone pricing |
| Portfolio target | 1–2 apps |

### Tier 3 — Subscription + lifetime escape *(the deep tool)*

| | |
|---|---|
| Sub pricing | $2.99–$4.99/mo · $19.99–$39.99/yr |
| Lifetime escape | $49.99–$99.99 (~2–3 years annual sub) |
| Surface preference | Swift native (AI / hosted sync / Live Activities) |
| Infra constraint | Must have genuine ongoing infrastructure costs |
| Audience | Power users + AI consumers + sub-comfortable households |
| Strategic role | Revenue backbone — funds free + Tier 1 apps' upkeep |
| Portfolio target | 2–3 apps |

### Tier 4 — Premium upfront *(the specialist tool)*

| | |
|---|---|
| Pricing | $24.99–$49.99 — either upfront, or top-of-ladder IAP anchored at this price point |
| Surface preference | Swift native |
| Infra constraint | None |
| Audience | Professional, specialized |
| Strategic role | Ceiling proof |
| Portfolio target | 0–1 apps |

**Boundary note:** a $19.99 single lifetime IAP with no subscription is Tier 2 (top of band), not Tier 4. Tier 4 is reserved for genuine premium-upfront pricing ($24.99+).

---

## Metered-Apple-API apps (portfolio-wide quota tracker)

Some Apple APIs are metered **per developer account**, not per app — WeatherKit is the live example (**500k calls/mo free, $49/100k thereafter**). All your apps share that quota, so track usage here.

| App | Status | Modeled call volume (10k MAU) | % of free quota | Fallback ladder documented |
|---|---|---|---|---|
| — | — | — | — | — |

**Rule:** any app using a metered Apple API must include a cost-modeling section in its planning card *before* it's approved — modeled call volume at 1k MAU and 10k MAU, free-quota headroom, and a fallback ladder (cache aggressively → reduce refresh cadence → degrade to manual refresh) if quota is approached.

---

## Market data

Tier choices should be grounded in citable data, not vibes. The wizard cites these in the `/pick-monetization` rationale. Refresh the estimates yearly.

| Data point | Source | Strategic implication |
|---|---|---|
| Apple commission: **30%** standard / **15%** Small Business Program (<$1M earnings) or year-2+ subs | Apple Developer official | Sub LTV math vs lifetime IAP changes meaningfully after year 1 |
| iOS users with **any** active subscription: estimated 5–7% of total users at any time | Industry estimates (data.ai, Sensor Tower) | Sub-only portfolios leave 93–95% of users unmonetizable |
| Top **5%** of subscribers drive **~85%** of sub revenue | RevenueCat State of Subscriptions | Sub revenue is power-law; long-tail apps don't recoup |
| Family Sharing **on by default** for IAPs + subs since 2021 | Apple policy | Tier 1 lifetime IAPs effectively multi-user |
| Apple Price Tier anchors (USD): Tier 5 = $4.99 · Tier 10 = $9.99 · Tier 15 = $14.99 · Tier 20 = $19.99 | Apple official | The Tier 0–4 ladder maps cleanly to Apple's price-tier anchors |
| TestFlight: 90-day max beta · 10K external testers · 100 internal | Apple official | The dev premium toggle's easter-egg path covers the post-TestFlight early-user window |
| Industry productivity-sub monthly churn: 5–10% | RevenueCat reports | Lifetime IAP eliminates churn |
| Honest trial→paid conversion: 20–40% | RevenueCat reports | Dark-pattern trials boost short-term but tank LTV |
| **WeatherKit free quota: 500k calls/mo per developer account, $49/100k thereafter** | Apple Developer | Metered-API apps need the cost-modeling section above |

---

## How `/pick-monetization` works

The wizard runs a **two-axis decision** (per [ADR 003](../DECISIONS/003-monetization.md)):

### Axis 1 — Per-app fit (5-tier pre-positioning)

```
RN + no enabled infra services + emotionally-simple mission        → suggest Tier 0–1
Swift + substantial scope + on-device compute only                 → suggest Tier 2
Genuine ongoing infra costs (AI inference, hosted sync)            → suggest Tier 3
Professional/specialist audience + deep single-purpose tool        → suggest Tier 4
```

The pre-positioning is a *suggestion*. The wizard presents it with rationale and asks; the user decides.

### Axis 2 — Portfolio mix

The wizard reads the **Current portfolio** table above and flags concentration: if every app is Tier 3, the portfolio has churn risk and no acquisition funnel; if everything is Tier 0, nothing funds upkeep. The per-tier "portfolio target" rows encode the healthy mix.

### Tip-jar warning

A tip jar is allowed (see WHATS_ALLOWED.md) but the wizard warns when a tip jar is proposed *instead of* a real tier decision: tips are not a pricing strategy, they're a gratitude channel. Data across indie iOS consistently shows tip-jar-only apps earning near zero.
