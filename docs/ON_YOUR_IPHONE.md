# On Your iPhone — and Then on Your Friends' Phones

Two moments make an app real: the first time it runs on **your** phone (free), and the first time a friend texts you a screenshot from **theirs** (TestFlight). This guide is both, in order.

Prerequisites: [SETUP.md](SETUP.md) Stage 1 done; the app runs in your Simulator.

## Part 1 — Your own iPhone (free, ~10 minutes)

No $99 program needed — a free Apple ID installs your app on your own devices.

1. **Plug in your iPhone** with a cable (first time; wireless works after). Tap **Trust This Computer** on the phone.
2. In Xcode's device menu (top center) your iPhone appears above the Simulators — select it.
3. **Enable Developer Mode on the phone** (iOS 16+): Settings → Privacy & Security → Developer Mode → on → restart the phone. (The toggle only appears after Xcode has tried to talk to the device once.)
4. In Xcode: project → your app target → **Signing & Capabilities** → Team: your Apple ID's **Personal Team** → "Automatically manage signing" on.
5. Press **⌘R**. First run, the phone blocks the app: Settings → General → **VPN & Device Management** → your Apple ID → **Trust**. Run again.

Your app. Your phone. Feel the haptics the Simulator couldn't give you.

**Free-tier limits to expect:** the install expires after about 7 days (just ⌘R again to refresh), you can register only a handful of app IDs per week, and some capabilities (push notifications, full iCloud sync) won't work until you join the Developer Program. All fine for the "carry it around and fall in love with the problem" phase — which is exactly the phase that decides whether the idea deserves $99.

## Part 2 — TestFlight: your app on your friends' phones

Requires the [Apple Developer Program](SETUP.md#stage-3--the-apple-developer-program-99year) ($99/yr).

### One-time app record

1. In [App Store Connect](https://appstoreconnect.apple.com): **Apps → "+" → New App**. Pick your app's real name (30-char limit; check it's not taken), your bundle ID, and a SKU (any internal string).
2. In Xcode, confirm the target's version (e.g. `1.0.0`) and build number — the templates manage these in `Version.xcconfig` (Swift) / `app.json` (RN), bumped by `bin/bump-version.sh` / `scripts/` equivalents.

### Upload a build

- **Swift template:** `make archive` — regenerates the project, archives, and opens Organizer. In Organizer: **Distribute App → TestFlight & App Store → Upload**. Automatic signing handles certificates.
- **RN template:** `npm run archive` for the local path, or EAS (`eas build --platform ios`) per [recipes/rn/add-rn-eas.md](../recipes/rn/add-rn-eas.md) — EAS uploads for you.
- Processing takes a few minutes to an hour. It appears in App Store Connect → your app → **TestFlight** tab. First build per version asks the export-compliance question — the templates ship `ITSAppUsesNonExemptEncryption = NO` so it's usually pre-answered.

### Invite friends

Two tiers, different friction:

| | Internal testers | External testers |
|---|---|---|
| Who | Up to 100 people you add to your App Store Connect team | Up to 10,000 people via email or a public link |
| Review needed? | No — builds are testable within minutes | First build (and significant changes) get a lightweight beta review, usually ~a day |
| Right for | You, your partner, your most patient friend | The neighborhood |

For friends/neighbors: TestFlight tab → create an **external group** → add emails or generate a **public link** → attach the build. They install the free TestFlight app, tap your link, and your app is on their phone. Builds expire after 90 days; testers get update notifications automatically; crashes and screenshots-with-feedback flow back to you in App Store Connect.

**Before the neighbors get a link,** run the pre-flight the repo gives you: `/review`, the [App Store checklist](APP_STORE_CHECKLIST.md) (metadata + privacy answers matter for beta review too), and put a real support contact in TestFlight's test information — friends *will* find things, and that's the point.

### From TestFlight to the App Store

Same build, no re-upload: App Store Connect → **App Store** tab → attach the build to version 1.0.0, complete the listing ([APP_STORE_CHECKLIST.md](APP_STORE_CHECKLIST.md), screenshots via `tools/app-store-graphics/`, listing copy via `/app-store-aso`, pre-audit via `/apple-app-review`) → **Submit for Review**.

> Tester counts, expiry windows, and review behavior are Apple's numbers and shift over time — verify at [developer.apple.com](https://developer.apple.com/testflight/) when planning anything that depends on them.
