# Setup — Xcode, Apple Accounts, and Your Toolchain

Everything you need installed and signed up for, in the order you actually need it. The rule of this page: **spend no money and create no accounts until the step that requires them.**

## Stage 1 — Build and run (free, no accounts beyond an Apple ID)

### Xcode

1. Open the **Mac App Store**, search "Xcode," install. It's ~10 GB — start it before making coffee, not after.
2. Launch Xcode once. Accept the license, let it install additional components.
3. When prompted about platforms, ensure **iOS** is checked (Xcode → Settings → Platforms to verify or add simulators/runtimes later).
4. Install the command-line tools if anything asks for them:
   ```sh
   xcode-select --install
   ```

**Which version?** The latest stable Xcode from the App Store. Apple requires recent Xcode/SDK versions for App Store submissions, so staying current isn't optional hygiene — it's the submission requirement. (Beta Xcodes are for the curious; never make a beta your only install.)

### Homebrew + XcodeGen (Swift template)

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"   # from brew.sh
brew install xcodegen
```

### Node.js (React Native template only)

Install the **LTS** version from [nodejs.org](https://nodejs.org) (or `brew install node`). Verify: `node -v` and `npm -v` both print versions.

### Your Apple ID

A free Apple ID (the one you already use on your iPhone is fine) is all Stage 1 needs. Add it to Xcode: **Xcode → Settings → Accounts → "+" → Apple ID**. This unlocks the Simulator fully and — Stage 2 — running on your own device.

✅ **Checkpoint:** you can complete Part 1 of the [First-App Tutorial](FIRST_APP_TUTORIAL.md) — the template builds and runs in the Simulator.

## Stage 2 — Your own iPhone (still free)

A free Apple ID can install your app on your **personal devices** ("free provisioning"). Limits: apps expire after ~7 days (re-run from Xcode to refresh), a small number of app IDs per week, and some capabilities (iCloud, push) are restricted. Full walkthrough: [ON_YOUR_IPHONE.md](ON_YOUR_IPHONE.md).

## Stage 3 — The Apple Developer Program ($99/year)

**Wait until one of these is true:** you want TestFlight beta testers, you're ready to submit to the App Store, or you need a restricted capability (push notifications, full iCloud) on device. Learning, building, and running on your own phone need none of it.

When it's time:

1. Go to [developer.apple.com/programs/enroll](https://developer.apple.com/programs/enroll) and sign in with your Apple ID (turn on two-factor auth first — it's required).
2. **Individual vs Organization:**
   - **Individual** — fastest (usually approved in ~a day or two), your legal name appears as the seller on the App Store. Right for almost everyone reading this. You can switch to an organization later.
   - **Organization** — requires a legal entity **and a D-U-N-S number** (a free business identifier from Dun & Bradstreet that can take days–weeks). Only worth it if you already have an LLC/company and want its name as the seller.
3. Pay the $99/year and wait for the approval email.
4. Back in Xcode's Accounts settings, your team now shows as a paid team. In your project's **Signing & Capabilities**, select it and keep **"Automatically manage signing"** on — Xcode creates and renews certificates and provisioning profiles for you. (Manual signing and the `fastlane match` setup in the template exist for CI and teams — ignore them until you have that problem.)
5. Sign in at [App Store Connect](https://appstoreconnect.apple.com) — this is where app records, TestFlight, and store listings live.

✅ **Checkpoint:** Xcode shows your paid team; App Store Connect loads. You're ready for [TestFlight + shipping](ON_YOUR_IPHONE.md#part-2--testflight-your-app-on-your-friends-phones).

## Common setup failures

| Symptom | Fix |
|---|---|
| `xcodegen: command not found` | Homebrew's bin dir isn't on PATH — open a new terminal, or follow the PATH instructions brew printed at install. |
| "Failed to register bundle identifier" | Your bundle ID is taken (globally unique across all Apple developers) — change `com.example.yourapp` to something with your name/brand in it. |
| Signing error: "requires a development team" | Xcode → project → Signing & Capabilities → pick your team (your Apple ID's personal team is fine pre-Program). |
| Simulator list is empty | Xcode → Settings → Platforms → download an iOS runtime. |
| Two-factor prompts loop during enrollment | Enroll in the Developer Program on the *same* Apple ID your iPhone is signed into, with 2FA already on. |
| RN: `expo start` can't find the Simulator | Launch Simulator once from Xcode first (Xcode → Open Developer Tool → Simulator). |

> Prices, approval times, and program rules are Apple's and change — verify anything load-bearing at [developer.apple.com](https://developer.apple.com) before relying on it.
