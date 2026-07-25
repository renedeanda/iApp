# After 1.0 — Owning an App, Not Just Shipping One

Launch day is the midpoint, not the finish line. This is the guide to the part nobody scaffolds: the weeks after release, the annual platform ritual, reviews, pricing changes, and — someday — a kind ending. Opinionated, like everything here; calibrated for a solo developer or tiny team.

## The first two weeks

- **Watch crashes, not charts.** App Store Connect → your app → Analytics/Metrics shows crash counts; Xcode's Organizer shows symbolicated crash logs. One crash pattern affecting real users outranks every feature idea you had at launch. (If you enabled the analytics service, your funnel events are the *second* thing to read.)
- **Answer every review in the first month.** ASC lets you reply once per review; early adopters who bothered to write are your highest-signal users. A shipped fix + "this is fixed in 1.0.1, thank you" reply converts 1-star reviews into edits surprisingly often.
- **Keep TestFlight alive.** Your external group is now your beta channel for 1.1 — ship to them a week before every App Store release, forever.
- **Resist the launch-adrenaline roadmap.** You will want to build everything the first ten users suggest. Put requests in a list, wait two weeks, then check them against your anti-list (`DECISIONS/013`) and mission. Requests that survive the wait and the anti-list are real.

## The annual iOS ritual

Every year has the same shape; put it in your calendar once:

- **June (WWDC):** watch what's announced; read the new HIG deltas. Do *not* rush to adopt betas in shipping apps. Note which new API would genuinely serve your mission (usually one, sometimes zero).
- **Summer:** install the iOS beta on a spare device (never your daily phone), run your app, file a list of what breaks or looks dated. Xcode beta builds are for investigating, not releasing.
- **September (new iOS ships):** rebuild with the new SDK, fix what broke, ship a compatibility release *promptly* — users on day-one iOS notice apps that lag. Apple requires recent-SDK builds for submissions on a rolling basis anyway.
- **Adopt one new thing deliberately** (or none): the new API you flagged in June, done properly, is worth ten half-adoptions. New-OS-feature adoption is also your best free App Store featuring lottery ticket.

## Reviews without despair

- The star rating is a *lagging* indicator dominated by your prompt strategy — the template's throttled review prompt (after success moments, never interrupting) is the honest way to keep it representative.
- Read 1-star reviews in batches, weekly, not push-notification-fresh. Look for *patterns*; a single angry outlier is weather, three mentions of the same confusion is a bug in your design.
- You can reset the *displayed* average with a new version in extreme cases (ASC option) — use it only after genuinely fixing the cause; resetting a deserved rating just re-earns it.

## Features, analytics, and saying no

- **A feature request needs evidence twice:** once that people want it (multiple independent asks or funnel data), once that it serves the mission. The wizard's discipline doesn't end at 1.0 — new features get a mini-ADR (a paragraph in `DECISIONS/`, appended, dated).
- If you wired analytics: act on *funnels*, not totals. "40% drop between opening the composer and saving" is actionable; "DAU went down Tuesday" is weather.
- The strongest post-1.0 move is usually **deepening the core loop** (faster, calmer, more delightful) rather than widening the surface. Every widening also widens localization, testing, and support forever.
- Price changes: **raising prices is fine and normal** as scope grows — new users pay the new price. Existing lifetime buyers keep what they bought; existing subscribers should be grandfathered or given long notice (Apple supports preserving prices for existing subscribers). Never quietly move features from the free core into the paywall — that breaks the "core mission stays free" covenant and earns the reviews it deserves.

## Updates cadence

- Small, frequent releases beat seasonal epics: less risk per release, livelier store listing, faster review-response loop. Keep `WHATS_NEW.md` honest and human — it's marketing copy read at the exact moment someone still cares.
- Bump versions with the template's `bump-version` script; keep the changelog discipline you learned here (your app deserves a CHANGELOG too).
- Re-run the release gates every time, not just at 1.0: `/review`, the [launch audit](LAUNCH_AUDIT_CHECKLIST.md), and `/apple-app-review` when a release touches permissions, purchases, or data handling.

## Sunsetting kindly

Some apps complete their mission or stop earning their upkeep. Ending one well protects your users and your name:

1. **Stop selling before you stop serving:** remove from sale (ASC → Pricing & Availability) so no new user buys into a sunset; existing users keep their downloads.
2. **Ship a final release** that: works fully offline where possible, surfaces data **export** prominently (you built it — see the share/export recipe), and states the situation plainly in `WHATS_NEW` and on your landing page.
3. **Wind down obligations in order:** cancel-proof the users first (refund recent lifetime purchases on request; subscriptions must be cancellable and should stop renewing), keep the support email alive for a stated period, keep the privacy policy page up as long as any build can run.
4. If the app had real fans, consider **open-sourcing it** into your showcase instead of deleting it — a public archive is the kindest tombstone and the best proof-of-work.

An app you ended honestly costs you nothing in reputation. An app that silently rotted costs you every future launch.
