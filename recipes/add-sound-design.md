# Add sound design

> **Source:** `templates/swift/Seed/Services/_Disabled/SoundService.swift` (per [REUSE_INDEX](../portfolio/REUSE_INDEX.md)) — pattern derived from a chime service proven in a shipped production app
> **Platform:** Swift (the pattern); RN equivalent uses `expo-av` / `expo-audio`
> **Reliability:** ✅ the template ships the disabled stub; the pattern (AVAudioSession category handling + play-once discipline) is proven in production. The first app to ship a richer version writes it back to the template via `/sync-from-portfolio`.

## What it adds

A `SoundService` that plays short, intentional audio — a completion chime, an ambient bed, a soft tick — respecting the silent switch, the user's sound setting, and other apps' audio. Sound is the rarest portfolio surface: most apps ship none.

## When to use

- The app has a **completion or transition moment** where a brief sound genuinely deepens the experience — an end-of-session chime in a breathing/timer app is the model.
- The sound is **short, deliberate, and earned** — under ~2 seconds, tied to a specific event.
- The app's `DECISIONS/004-native-feature-checklist.md` explicitly says yes to sound. It is off by default.

## When NOT to use

- **Ambient loops as decoration.** A never-ending background track bleeds attention and battery — it's the audio equivalent of a looping spinner. (See `docs/DELIGHT_REEL.md` "Forbidden delights".)
- **Sound on routine actions.** A save, a tap, a toggle — these get haptics, not sound. Sound is for *completion*, not feedback.
- **Ignoring the silent switch.** A chime that plays when the phone is on silent is a bug, full stop. The category choice (below) is what honors it.
- **Auto-playing sound on launch.** Never.
- **Fighting other audio.** If the user is playing music or a podcast, your app's incidental sound must duck or mix politely — never interrupt.
- **Without a setting.** Even when sound is enabled, the user gets a Settings toggle the service actually checks.

## How

### 1. Harvest

- Source: `templates/swift/Seed/Services/_Disabled/SoundService.swift` — read it for the `AVAudioSession` category handling and the play-once discipline.
- In a generated app it already ships in `Services/_Disabled/` — move it up and uncomment the imports. **If you extend it meaningfully**, propose the cleaned-up version back to the template via `/sync-from-portfolio`.

### 2. Wire

- **Audio session category:** use `.ambient` (obeys the silent switch, mixes with other audio) for incidental sound. `.playback` (ignores the silent switch) is only for apps where audio *is* the product — that is almost never a portfolio app.
- **Setting:** the service checks a `soundEnabled` UserDefault before playing. Off by default; the user opts in.
- **Assets:** short `.caf` or `.m4a` files in the bundle. Keep them small; preload the player so the first play isn't laggy.
- **Play once:** the service plays a sound on an event and returns — no loops, no scheduling. One event, one short sound.
- **Reduce-distraction parity:** treat sound like motion — if the user has reduced motion / wants calm, sound is a candidate to suppress too. At minimum, the setting is prominent.
- **Interruption handling:** observe `AVAudioSession.interruptionNotification` so a phone call mid-chime doesn't leave the session in a bad state.

### 3. Verify

```sh
xcodebuild build -scheme <App> -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
# then on a device: flip the silent switch on → trigger the sound event → confirm silence.
#                    silent switch off, soundEnabled off → confirm silence.
#                    silent switch off, soundEnabled on  → confirm the chime plays once.
```

Expected: build green; the three-state check above behaves correctly. The silent switch is honored because the session category is `.ambient`.

## Gotchas

- The Simulator's audio routing is unreliable for testing the silent switch — verify on a device.
- `.playback` category is a common mistake copied from music-app tutorials — it ignores the silent switch and will get the app 1-star reviews. Use `.ambient`.
- An `AVAudioPlayer` that goes out of scope stops mid-sound — the service holds a strong reference for the (brief) lifetime of the playback.
- RN equivalent: `expo-audio` with the `playsInSilentMode: false` configuration is the analog of `.ambient`; the same "earned, short, off-by-default" rules apply.
