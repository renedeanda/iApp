# Bring Your Idea — A Worksheet for Future App Makers

You have an app idea. You don't need to know Swift, or what Xcode is, or anything technical to start — you need clear answers to a few plain-English questions. This worksheet is those questions. Fill it in anywhere (notes app, paper, voice memo), then bring it to your first AI session and the wizard turns your answers into a real, running app scaffold.

There are **no wrong answers** — vague ones are fine, the session will sharpen them with you. Skipped ones are fine too.

---

## Part 1 — The idea, in plain words

**1. What is it?** One or two sentences, like you'd tell a friend.

> *e.g. "An app where I log every plant in my garden and it reminds me what needs attention." / "A tiny app that helps my kid practice multiplication without it feeling like homework."*

**2. Who is it for?** Be specific — a real person you know beats a demographic.

> *"People like my sister, who…" is a great answer.*

**3. What's the moment?** When exactly does someone open it? Where are they, what just happened?

> *The strongest apps own one moment. "Standing in the garage wondering if I already own this screw" is a moment. "Whenever they want" is not.*

**4. Why does it deserve to be an app on their phone** rather than a notebook, a spreadsheet, or a website? (Camera? Reminders? Widgets? Offline? Always-in-pocket?)

**5. What already exists, and what's wrong with it?** Name the app/tool people currently use for this and the thing about it that annoys you.

## Part 2 — Taste (the questions most people never get asked)

**6. The promise, in one sentence.** If your app could only make one promise to its user, what is it? (This becomes the *mission* — the wizard caps it at ~14 words.)

**7. What will it never do?** List 2–3 things you refuse to build even if someone asks. Ads? Accounts? Social feeds? Guilt trips?

> *This becomes your anti-list, and it's the most protective document your app will ever have.*

**8. How should it feel?** Circle the closest: calm / playful / serious-and-fast / warm / bold-and-loud / handmade / luxurious / minimal. Name one app or object whose look you love.

**9. The one signature moment.** Describe a single small moment that should feel *great* — finishing a thing? adding a thing? seeing progress? What should happen on screen when it does?

**10. The first minute.** Someone just downloaded it. What do they see first, and what's the very first thing they *do* (not read)? What must NOT happen in that minute (signup walls? permission popups?)

**11. Money, honestly.** Free forever? Pay once? Would *you* pay for it — and for which part? (The core always stays free in this system; paying unlocks extras.)

## Part 3 — The ingredients (check what your idea needs)

☐ Take/attach photos ☐ Lists of things with sub-items ☐ Reminders/notifications ☐ A timer ☐ A home-screen widget ☐ Sync across devices ☐ Share something to friends ☐ Export my data ☐ Works fully offline ☐ Multiple languages ☐ Face ID lock ☐ Other: ______

(Everything on that list is a ready-made recipe or a built-in service in this repo — checking a box is most of the work.)

**12. Other people.** Does your idea involve people seeing or touching *each other's* stuff? Check the closest:

☐ No — it's just for the one person using it
☐ Sharing with specific people they invite (a partner, family, a friend)
☐ Competing with people they know (scores, streaks, games)
☐ Strangers — public posts, feeds, discovery, chat with people they've never met

> The first three are wonderfully cheap to build — Apple's built-in services handle them with no servers and no sign-ups. The last one is a genuinely bigger commitment (accounts, hosting bills, content moderation). It's absolutely buildable — but read [AMBITIOUS_APPS.md](AMBITIOUS_APPS.md) first, and expect your session to ask: *"does the idea still work if it's invite-only?"* Usually it does, and ships a year sooner.

**13. Already have designs?** Sketches in a notebook, Figma/Canva screens, a slide deck? You're ahead — the wizard can *look at them* and let your designs drive the choices. Export each screen as an image and bring them along (the how-to per tool: [BRING_YOUR_MOCKUPS.md](BRING_YOUR_MOCKUPS.md)). No designs is equally fine — the questions produce the design.

## Part 4 — Bringing it to a session

You'll pair with an AI coding agent that knows this repo's system. Setup, from absolute zero:

1. **Get the repo — and make yours.** Install [git](https://git-scm.com). On GitHub, create a **new private repository** named after your app (check "Add a README"). Then in Terminal:
   ```sh
   mkdir -p ~/code && cd ~/code
   git clone <this-repo-url> kindling
   git clone <your-private-repo-url>
   cd kindling
   ```
   Your app's code will land in *your* repo, next to Kindling — never inside it ([why + details](YOUR_OWN_REPO.md)).
2. **Get an agent.** Either [Claude Code](https://claude.com/claude-code) (`claude` in the repo folder) or [Codex](https://openai.com/codex) — both understand this repo (Claude reads `CLAUDE.md`; Codex reads `AGENTS.md`).
3. **Open with this:**
   > "I'm new. Run /start. Here's my filled-in worksheet: …" *(paste your answers)*
4. The agent will route you: if you've never built an app, it walks you through [FIRST_APP_TUTORIAL.md](FIRST_APP_TUTORIAL.md) first; if your worksheet is solid, it takes you into `/new-app --draft` — the 21-question wizard your worksheet just gave you a head start on.
5. **Expect to sleep on it.** The wizard writes your decisions, then *refuses to build until tomorrow*. That's a feature. Day 2, it renders your scaffold: a real app, your palette, your name on it, running in the Simulator.

A filled worksheet turns a 90-minute first session into a 30-minute one — and turns "I've always wanted to make an app" into a repo with your name on it.

---

*For the person hosting a friend's session: keep them on `/start`, resist answering the wizard for them, and let the mtime check enforce the overnight pause. The answers have to be theirs — that's what makes the app theirs.*
