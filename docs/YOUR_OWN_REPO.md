# Your Code Goes in Your Repo

Kindling is the workshop; your app is the thing you carry out of it. **Never build your app inside a clone or fork of this repo** — your app gets its own repository, sitting next to Kindling on disk. This page is the setup, and why.

## The layout

```
~/code/                      # any parent folder you like
├── kindling/                # this repo — cloned once, updated with git pull
└── my-app/                  # YOUR app, YOUR (private) repo
```

Why side-by-side instead of fork-and-gut:

- **Clean ownership.** Your app's history starts with your app — not 300 commits of template history that mean nothing to it (and a fork of a public repo stays public-visible in ways people don't expect; your app deserves a genuinely private repo).
- **Free updates.** `cd kindling && git pull` brings new recipes, template improvements, and lessons — with zero merge conflicts against your app, because your app isn't entangled with it. Skim [CHANGELOG.md](../CHANGELOG.md) after pulling: it flags which changes affect the *next* render vs improvements worth adopting into shipped apps. Template improvements reach your app *deliberately* (via recipes or a sync pass), never as a surprise merge.
- **The wizard assumes it.** `/new-app --commit` renders your app into a **sibling directory**, not into Kindling.

## Setup (5 minutes, before your first wizard session)

1. **Create your app's repo on GitHub:** New repository → name it after your app (lowercase, e.g. `my-app`) → **Private** → check "Add a README file" → Create. (A blank repo with just a README is exactly right — the scaffold lands on top of it.)
2. **Clone both, side by side:**
   ```sh
   mkdir -p ~/code && cd ~/code
   git clone <kindling-repo-url> kindling
   git clone git@github.com:<you>/my-app.git
   ```
3. **Open your agent session in `kindling/`** — that's where the skills, wizard, and constitution load from. Your drafts (`drafts/<app-name>/`, gitignored) live here too.
4. When the wizard reaches `/new-app --commit`, it renders the scaffold **into `../my-app/`**, commits on top of your README, and pushes to *your* remote. From then on, day-to-day app work happens in a session opened in `my-app/` (which has its own `CLAUDE.md`/`AGENTS.md`); you come back to the Kindling session for new apps, recipes, and portfolio decisions.

**Manual path (no AI):** same layout — `cp -r kindling/templates/swift/* ../my-app/`, then `cd ../my-app && make bootstrap NAME=MyApp BUNDLE=com.you.myapp`, commit, push.

## Where your *portfolio* data lives

The `portfolio/` files (your shipped-apps table, claimed palettes, learnings) are personal — and your clone of the public Kindling repo isn't the place to push them. Two good options, by seriousness:

- **Quick path:** edit `portfolio/` files locally in your clone and don't push them anywhere (or keep a local-only branch). Fine for your first app or two.
- **Studio path (recommended once you have 2+ apps):** make a **private copy** of Kindling that you own — GitHub's "Use this template" button if enabled, or `git clone --bare` + push to a new private repo — then add the public repo as an `upstream` remote. Your private hub commits your real portfolio data; `git fetch upstream && git merge` pulls system updates. Your apps still get their own separate repos either way.

## What never crosses the line

- Your app's repo never contains Kindling's full history, and Kindling's public repo never receives your portfolio data, app code, or drafts.
- Secrets (`.env`, API keys, signing assets) belong in **neither** — see the Forbidden list in [CLAUDE.md](../CLAUDE.md).
