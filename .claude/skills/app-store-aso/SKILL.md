---
name: app-store-aso
description: Draft, revamp, or validate App Store listing metadata (description, subtitle, promotional text, keywords) for any portfolio app, using the Kindling launch-packet convention. Use before App Store submission, when a listing reads thin or jargon-heavy, or when refreshing ASO copy. Produces rich, on-brand, emoji-free copy within Apple's field limits and validates it.
argument-hint: "<app-repo-path> [locale|all]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# App Store ASO — listing metadata

Write App Store listings that are **rich, on-brand, ASO-optimized, delightful to
read, jargon-free, and emoji-free** — and provably within Apple's limits. The
canonical home for every app's listing is the JSON at
`<repo>/Marketing/AppStoreMetadata/<app>-app-store-metadata.json` (the Kindling
launch-packet convention; schema vendored at `docs/schemas/launch-packet.v1.schema.json`).
**Always edit that JSON** — never invent a parallel `docs/*.md` listing. The house
style in section 3 is the quality bar.

## 1. Read before you write (every time)

1. `<repo>/CLAUDE.md` — the app's **voice rules**, mission one-liner, and the
   **free vs. Pro monetization boundary**. The copy must pass this tone filter.
   Quote the voice rules into your working context and keep them open.
2. `<repo>/Marketing/AppStoreMetadata/<app>-app-store-metadata.json` — current
   copy, `bundle_id`, categories, the IAP boundary, and `app_review_notes_en`.
   Reviewer notes are a good **fact source** but their engineering jargon
   (StoreKit, SwiftData, CloudKit, FoundationModels, CKShare, bundle ids) must
   **never** leak into public locale copy.
3. Any richer prose the repo already has, for honest specifics (real counts,
   named features): e.g. `scripts/app-store-listings.md`, a `tools/gen_listing.py`
   en block, or prior marketing docs.

## 2. The JSON shape (do not restructure)

```
locales.<code>.{ app_name, subtitle, promotional_text,
                 description (ARRAY of paragraph strings),
                 keywords, whats_new (array), in_app_purchase (object) }
```
`description` is an **array of strings** — one entry per paragraph/bullet/header,
with `""` entries as blank lines. Keep that format. Touch only `subtitle`,
`promotional_text`, `description`, `keywords`. Do **not** change `app_name`,
`whats_new`, `in_app_purchase`, `bundle_id`, categories, IAP product ids, or
`app_review_notes_en` unless explicitly asked.

## 3. The description skeleton (the house style)

**Plain text only. NO emojis. NO decorative glyphs (◆ ▸ ★ etc.).** Use ALL-CAPS
section headers and simple `-` bullets — the house style.

```
[HOOK — one short, emotional, on-voice line. Not a feature.]
[VALUE PARAGRAPH — 2-3 sentences: what it is, who it's for, the core promise.]
[PRIMARY FEATURE HEADER]      short paragraph or 3-5 "-" bullets, honest specifics
[SECONDARY FEATURE HEADER]    ...
[3-6 headers total, ordered by marketing weight]
[WHAT'S FREE / PRO]           one honest line each, NO prices (only if a Pro tier exists)
[PRIVACY]                     "No accounts. No ads. No tracking. Your data stays
                               on your device and your own iCloud." (adapt per app)
[CLOSING CTA]                 one on-voice line ("Download X ...")
```
Target ~2500-3500 characters: rich, never padded. The ceiling is 4000.

For CJK locales (ja/ko/zh-Hans) headers have no real "caps" — render them as
short, standalone header lines with the same meaning.

## 4. Apple field limits (verified; authority is `docs/schemas/launch-packet.v1.schema.json`)

| Field | Limit |
|---|---|
| app_name | 2-30 characters |
| subtitle | 30 characters |
| promotional_text | 170 characters (editable later without a build; not indexed) |
| description | 4000 characters — measured as `"\n".join(array)` |
| keywords | **100 UTF-8 BYTES** (not characters — CJK chars are ~3 bytes each) |
| whats_new / release notes | 4000 characters |
| IAP display_name | 35 characters |
| IAP description | 55 characters |

## 5. ASO rules

- **Concrete first sentence.** Lead with an emotional or vivid hook, not "An app that…".
- **subtitle**: a value/search hook; if `app_name` already carries the brand, keep
  the brand out of the subtitle.
- **keywords**: comma-separated, **no spaces after commas** (spaces waste bytes);
  no duplicate words; **no word that already appears in `app_name` or `subtitle`**
  (those are already indexed); blend category + feature + long-tail terms; localize
  them naturally per locale rather than copying the English. No competitor,
  celebrity, or third-party trademark terms (e.g. don't keyword "Reddit", "Notion").
- **No prices anywhere** in public copy (description/subtitle/promo/keywords).
- **Honest disclosure.** Don't over-claim. Gate AI / HealthKit / iCloud / "on-device"
  claims to what actually ships and is enabled. If a feature is device-capability
  gated, say "on supported devices".
- **No emojis, no glyphs.** Apple's description field doesn't render emoji.

## 6. Localization

English-first: perfect `en`, then rewrite each other locale to **faithfully match
the new English in that language and on-voice** — not literal word-for-word. Keep
the same section structure, headers (translated), `""` separators, and `-` bullets.
Keep Apple/brand feature names (Live Activity, Lock Screen, Home Screen, iCloud,
Widgets, Shortcuts, the app's "<App> Pro") in the locale's standard form. Flag
machine-drafted locales for a native-speaker tone pass before submission.

If the repo also keeps a `fastlane/metadata/<asc-locale>/*.txt` mirror, the JSON is
canonical — regenerate the mirror from it (see `tools/sync_fastlane_from_json.py`
in repos that have one) so the two never drift.

## 7. Validate (mandatory — never commit unvalidated)

```sh
python3 <repo>/Marketing/AppStoreMetadata/validate_metadata.py \
        <repo>/Marketing/AppStoreMetadata/<app>-app-store-metadata.json
```
Must print `OK: N locale(s), 0 errors`. Fix every ERROR (almost always a length /
byte overflow — shorten that locale's field). Resolve WARNs too (keyword
comma-space; an `EUR`/`£`/`$` false-positive can hide in a word like "ailleurs" —
reword it). Then sanity-grep the locale descriptions for emojis, glyphs, leaked
engineering jargon, and price digits, and re-read the app's CLAUDE.md tone rules to
confirm the draft holds the voice (e.g. anti-streak apps must carry zero
streak/scolding language; "presents, doesn't decide" apps must never tell the user
what to choose).

## 8. Voice gate (the check that matters most)

Before accepting any draft, restate the app's tone rules and read the copy
line-by-line against them. A draft that passes the length validator but breaks the
voice is **rejected**. Examples of binding voice rules an app's CLAUDE.md might
carry: no streaks/shame language; a specific address term for the user;
presents-not-decides (never tell the user what to choose); "the tip jar unlocks
nothing"; no over-claimed capabilities.
