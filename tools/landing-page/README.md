# Landing Page Starter

The App Store requires a **support URL** and a **privacy-policy URL** before you can submit — a wall every first-time shipper hits. This folder is the ten-minute answer: a self-contained, three-page site (landing, support, privacy) with no build step, no framework, no external assets, dark-mode aware, and styled by the same no-pure-`#000`/`#FFF` token rules as the templates.

## Use it

1. Copy this folder into your app repo (e.g. as `site/`).
2. Replace every `{{TOKEN}}` across the three HTML files (app name, tagline, support email, year…). Delete the `{{IF_...}}` blocks that aren't true for your app — the privacy page especially must only say true things.
3. Drop in `icon.png` (export 1024px from your `icon_master.svg`) and 2 real screenshots (`tools/app-store-graphics/` output works).
4. Swap the `:root` color variables for your app's `AppTheme` tokens (light + dark).

## Deploy free on GitHub Pages

1. Push the folder to a GitHub repo (its own repo, or your app repo's `site/` directory).
2. Repo → **Settings → Pages** → Source: your branch (+ `/site` folder if applicable) → Save.
3. Your site is live at `https://<username>.github.io/<repo>/` in ~a minute. That URL (plus `/support.html` and `/privacy.html`) is what you paste into App Store Connect.

A custom domain is optional polish, not a requirement — App Review accepts github.io URLs. Any other static host (Cloudflare Pages, Netlify) works identically.

## Rules of the house

- **Real screenshots only** — same as the store listing.
- **The privacy page must be true.** Generate the honest baseline from your app's shipped `docs/PRIVACY_POLICY.md` and the `app-privacy-declaration` recipe rather than inventing claims.
- Keep it one page per job. A landing page that's trying to be a blog is a landing page that never ships.
