# What Kindling Is Not For

> Read alongside [WHATS_ALLOWED.md](WHATS_ALLOWED.md). This doc rejects **manipulative** patterns, not engagement itself. Streaks, reminders, notifications, gamification are welcome when framed as care, celebration, or utility — see the sibling doc for explicit positive examples.

A coding agent reading this doc should not refuse a feature without first checking `WHATS_ALLOWED.md` for the positive framing of the same primitive. Worked examples below.

---

## The hard "no" list

These patterns will never ship in an app built from this repo. The wizard's anti-list step (`DECISIONS/013-anti-list.md`) defaults to rejecting them; opting one in requires an ADR.

### 1. Shame-driven streaks

❌ **Bad:** Streak resets to zero after one missed day. "You broke your 47-day streak."

✅ **Good (see [WHATS_ALLOWED.md](WHATS_ALLOWED.md)):** Streak as celebration of cumulative practice. Missed days are forgotten quietly; the next time the user returns, the app says "welcome back" — not "you failed."

### 2. Infinite scroll for attention extraction

❌ **Bad:** Endless feed of content selected by an engagement algorithm. The app's success metric is time-in-app.

✅ **Good:** Bounded content. Daily limit. Natural stopping point. A "you're done" screen.

### 3. Dark-pattern paywalls

❌ **Bad:** Free trial pre-checked. Dismiss button hidden behind a tiny "x" in the corner. Annual price highlighted while the *real* charge is a monthly bill labeled in small gray.

✅ **Good:** Restore Purchases visible. Annual vs monthly shown with equal weight. The dismiss path is obvious. The template's `Services/_Disabled/SubscriptionManager.swift` ships this pattern.

### 4. Ad-mediated monetization

❌ **Bad:** AdMob, Facebook Audience Network, AppLovin, IronSource, Unity Ads, any rewarded-video SDK.

✅ **Good:** Free with all features. One-time IAP. Subscription with restore. Pay-once-own-forever. Decision tree in the [MONETIZATION_MATRIX](../portfolio/MONETIZATION_MATRIX.md).

### 5. Engagement-maximizing notifications

❌ **Bad:** "You haven't opened the app in 3 days." "Don't forget to check your stats!" "Your friends are active right now." Push to drive opens.

✅ **Good (see [WHATS_ALLOWED.md](WHATS_ALLOWED.md)):** Push to *serve* the user's stated intent — "your reminder for Mom's birthday is in 2 days," "your evening session is queued." Notifications the user explicitly subscribed to, delivering information they want.

### 6. Social graphs / follows / leaderboards

❌ **Bad:** Friend feeds, follow buttons, public leaderboards, comments, "who else is using this app right now."

✅ **Good:** Single-user experience. Optional CloudKit sync to *your own* devices. If multiplayer is ever the mission, it gets its own product, not bolted onto a single-user app.

### 7. Tracking + ad-targeting identifiers

❌ **Bad:** `requestTrackingAuthorization` for any reason. IDFA. Cross-app identifiers. SDKs that fingerprint device.

✅ **Good:** TelemetryDeck (anonymous, EU-hosted, no PII). Optional Sentry for crash reports with PII scrubbing. Privacy nutrition labels filled in honestly.

### 8. Dark-pattern review prompts

❌ **Bad:** "Rate us 5 stars" with a 1-star path that opens a feedback form to *prevent* a low rating from reaching the App Store. Triggered immediately on first launch.

✅ **Good:** Use `SKStoreReviewController.requestReview` (system-throttled). Trigger only after the user has had a genuinely good moment (completed a session, hit a milestone, used the app 5+ times). The template's `Services/_Disabled/AppReviewService.swift` ships this pattern.

### 9. Forced onboarding metadata collection

❌ **Bad:** Required email, phone, name, birthday, gender, "interests" before the user can see the app's value.

✅ **Good:** Show value first. Ask for what you actually need. Sign in with Apple if you need an account at all. Most small, focused apps don't need accounts.

### 10. Notification spam disguised as features

❌ **Bad:** "Want to enable notifications?" on first launch with no context. Re-prompting every session. Burying the "no thanks" option.

✅ **Good:** Defer the permission ask until you have a concrete reason to send a notification ("you set a reminder for 9 AM — want us to notify you?"). One-shot, never re-prompted.

### 11. Auto-renewing subscriptions without proportional value

❌ **Bad:** $9.99/month for a wallpaper changer. Subscription pricing on a single-purchase value prop.

✅ **Good:** [MONETIZATION_MATRIX](../portfolio/MONETIZATION_MATRIX.md) decision tree. Subscription is for apps with ongoing server costs (AI inference) or genuinely recurring value (daily content). Otherwise: one-time IAP.

### 12. Hidden data sharing

❌ **Bad:** Sending user content to a third-party analytics SDK in the clear. Streaming voice transcripts to a server. Sharing health data with anyone.

✅ **Good:** Privacy manifest declares every API used. Apple Intelligence runs on-device. CloudKit sync stays in the user's iCloud (not yours).

---

## How a coding agent should use this doc

When asked to implement a feature that smells like one of the above:

1. **Check the sibling.** Open [WHATS_ALLOWED.md](WHATS_ALLOWED.md) and look for the positive framing of the same primitive. *Streaks* are listed there as celebration. *Reminders* are listed there as care. *Gamification* is listed there with examples of milestone-as-acknowledgment vs. shame-as-mechanic.

2. **Ask the user.** If the request maps to both a "no" and a "yes" framing, surface the distinction explicitly: *"You said 'add a streak.' I can build streak-as-celebration (no shame on miss) or streak-as-mechanic (which the anti-list rejects). Which?"*

3. **Refuse only when it's clearly the hard "no."** Don't refuse "add a reminder" because it could theoretically be used for engagement. Refuse "add a push that pings inactive users to drive opens" because that's the explicit anti-pattern.

4. **When in doubt, write an ADR.** If the user wants something that genuinely sits at the boundary, capture the decision in `DECISIONS/013-anti-list.md` for their app. The wizard pre-loads this doc as the default, but every app can deviate with cause.

---

## What this doc is not

This is not a list of features the repo refuses to *consider*. It's a list of *implementations* of features that the repo rejects. Streaks are not on the no-list; shame-driven streaks are. Notifications are not on the no-list; engagement-maximizing notifications are. Subscriptions are not on the no-list; subscription pricing on single-purchase value props is.

Reading this doc without the sibling [WHATS_ALLOWED.md](WHATS_ALLOWED.md) will produce an over-correcting agent. Read both. Reject the manipulation, not the mechanic.
