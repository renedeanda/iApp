# Ambitious Apps — Multiplayer, Accounts, and Backends, Honestly

Some app ideas are bigger than one phone. The moment your idea includes *other people* — sharing with a friend, competing on a leaderboard, collaborating on the same data, a social feed — you've crossed from "app" into "app + service," and the cost structure, legal obligations, and failure modes change completely.

This guide is the opinionated map. This repo's templates lean hard on Apple's built-in services (iCloud/CloudKit, Sign in with Apple, on-device Apple Intelligence) precisely because they let a solo developer ship multi-device — and even multi-*person* — features with **no servers, no ops, and no monthly bill**. Go beyond them with open eyes.

> **Honesty note:** the *principles* here are stable; the specifics (vendor pricing, free-tier limits, API names) drift. Before committing to any vendor or quota assumption, verify against their current docs — and treat any concrete number in this file as "the shape of the cost," not a quote.

---

## The ambition ladder

Find your idea's rung. Each rung up adds real, permanent overhead — most ideas are happiest on the lowest rung that delivers the promise.

| Rung | What the user experiences | What it takes | Ongoing cost to you |
|---|---|---|---|
| **1. Solo, one device** | Their stuff, on their phone | SwiftData / AsyncStorage (template default) | None |
| **2. Solo, all their devices** | Same stuff on iPhone + iPad + Mac | CloudKit private database — the user's own iCloud | None. No accounts, no servers. |
| **3. Small-group sharing** | "Share this list with my partner / family / friend" | CloudKit **record sharing (CKShare)** — invite via a link, data lives in a shared iCloud zone | None. Still no backend, still no accounts of yours. |
| **4. Game-style multiplayer** | Leaderboards, achievements, matchmaking, turn-based play | **Game Center** — Apple runs the whole thing | None. |
| **5. Live together-time** | Doing the thing simultaneously over FaceTime | **SharePlay** | None. |
| **6. Strangers & feeds** | Public content, discovery, follows, likes, realtime presence among people who don't know each other | **A backend.** Accounts, database, API, moderation | **Forever.** Money, time, and legal duty — see below. |

**The design move that saves most ideas:** "multiplayer" usually means *rung 3*, not rung 6. "My friend and I keep a shared log" is CKShare. "Compete with my sister" is Game Center. Interrogate the promise: does the user care about *their people*, or about *strangers*? Rung 6 exists for strangers. If your idea works with invited-people-only, you can ship the multiplayer she's dreaming of with zero backend.

### What rungs 2–5 quietly give you for free

- **No account system** — iCloud identity is already there. Nothing to sign up for is a first-sixty-seconds superpower.
- **No privacy honeypot** — data lives in the *user's* iCloud, not your database. Your App Privacy label stays clean; a breach of "your servers" is impossible because there are none.
- **No bill that scales with success** — a hit app on rung 2–5 costs the same as a flop: $0.
- **Tier 0–2 pricing stays honest** — no infra cost means no pressure to charge a subscription (see [portfolio/MONETIZATION_MATRIX.md](../portfolio/MONETIZATION_MATRIX.md)).

Their limits, honestly: CKShare invitation UX is clunkier than a bespoke flow; everyone needs an Apple device signed into iCloud; Android/web users are locked out; you can't compute server-side (no push-based "someone liked your post" fan-out); querying across *all* users' data is impossible by design.

---

## If you truly need rung 6: what you're really signing up for

None of this is a reason not to build it. It's the price list nobody shows you.

### 1. Accounts are a lifecycle, not a login screen

- Sign-up, sign-in, password reset, email change, account merge, "I lost access," and **in-app account deletion — Apple requires it** (App Review 5.1.1(v)) and it must actually delete server-side data, not just deactivate.
- If you offer *any* third-party login (Google, etc.), Apple generally requires **Sign in with Apple** as an equal option (guideline 4.8). Opinion: make Sign in with Apple the *primary* path regardless — highest conversion, no passwords to breach, built-in email relay.
- Every account feature above needs support answers. You are now a support desk.

### 2. The bill scales with success

- Managed backends (Firebase, Supabase, and kin) have generous free tiers that vanish exactly when things go well. Model the cost at 1k and 10k MAU *before* building — the same discipline this repo demands for metered Apple APIs like WeatherKit.
- Realtime features (presence, live cursors, chat) are the most expensive class — persistent connections cost more than request/response.
- **Rule of the house:** genuine ongoing infra cost is the *only* justification for subscription pricing — and it also *demands* it. A free app with a growing server bill is a countdown clock. Decide the Tier 3 story on day 1, not at 10k users.

### 3. Strangers' content makes you a moderator

- Any user-generated content visible to other users triggers App Review's UGC rules (1.2): you need **flag/report, block, and a moderation response path** before approval — not after your first incident.
- Abuse arrives with scale: spam, impersonation, illegal content. "I'll deal with it later" is a plan to deal with it during your worst week.
- Kids may use it: if your app appeals to children, COPPA-class obligations apply and the bar rises sharply.

### 4. You become a data controller

- Privacy policy stops being a formality: GDPR/CCPA-class rights (access, export, deletion) now apply to data *you* hold. The App Privacy nutrition label grows, and "data linked to you" changes how the store page reads.
- A breach is now possible, and it's yours. Store the minimum; encrypt in transit and at rest; never store what you can derive.

### 5. Ops is a lifestyle

- Deploys, migrations, monitoring, rate limiting, API versioning (old app builds keep calling your API for *years*), and downtime that makes your app unusable through no fault of its code.
- Opinion for solo developers: **managed BaaS over self-hosted, boring over clever, one region, no microservices.** Your differentiation is the app, never the infrastructure.

### A sane default architecture (opinion)

If rung 6 is genuinely the idea: Sign in with Apple → a managed BaaS (hosted Postgres/auth/storage) → thin REST/RPC calls from the app → push via APNs. Keep the client offline-first with the same local models the template gives you, syncing through your API. Avoid: rolling your own auth, WebSocket empires before product-market fit, and any architecture you can't explain in four boxes.

---

## How this feeds the wizard

Ambition is a **design decision, uncovered at intake — not a surprise during development**:

- The [BRING_YOUR_IDEA worksheet](BRING_YOUR_IDEA.md) asks whether other people see each other's stuff — answer honestly and bring it up in your first session.
- `/new-app` step 0 (spec/JTBD intake) should classify the idea's rung. Rungs 1–5: proceed normally — `DECISIONS/008-data-model-and-sync.md` records the choice. Rung 6: the wizard must surface this guide's cost list, ask "does the promise survive with invited-people-only?", and — if backend it is — record in `DECISIONS/008` the chosen provider, the modeled cost at 1k/10k MAU, the account-deletion plan, and the moderation plan. `DECISIONS/003` (monetization) must then justify how the bill gets paid.
- **The downgrade question is the most valuable question:** most rung-6 drafts become rung-3 apps that ship a year earlier, cost nothing to run, and keep their privacy story. Ask it twice.
