# DECISIONS/016-spec.md — Template

> Copy this file to `drafts/<app-name>/DECISIONS/016-spec.md` and fill in the six fields. **This is the front door** — the wizard's step 0 elicits these answers before mission, before visual identity, before tech. The artifact's presence is enforced: `/new-app --commit` refuses if `016-spec.md` is missing or has unfilled placeholders.

The spec is the answer to "what is this app, for whom, why, and what is it not?" It is shorter than a PRD and stricter than a pitch. It exists so every later ADR has something to be derived *from* — the mission is one sentence about the problem; the anti-list is the negative space around the spec; the JTBDs are what the first-sixty-seconds has to deliver on; the success signal is what `005-launch-readiness.md` measures against.

This template is **structured differently** from the generic [TEMPLATE.md](TEMPLATE.md). Where the generic ADR template captures *a decision*, the spec captures *the problem the decisions exist to solve*. Six discrete fields, each ≤ one short paragraph. Brevity is the discipline — if a field exceeds ~80 words, the answer hasn't been sharpened enough.

---

## Required header

```markdown
# ADR 016 — Spec

- **Status:** Accepted | Draft
- **Date:** YYYY-MM-DD
- **App:** <app name>
- **Authors:** <who decided>
- **Wizard step:** /new-app step 0 — Spec intake
```

## The six fields

### 1. Problem

What real situation in the world makes someone reach for this app? One short paragraph. Anchored in the user's day, not the app's features. Avoid solution-shaped phrasing ("users need a way to ...") — describe the lived friction.

> **Good:** *"iOS users routinely receive PDFs (signed contracts, scanned receipts, government forms) and need to merge or rotate or compress them on the device. The App Store has either ad-supported free apps or $79/year subscriptions, no fair-priced middle ground."*
>
> **Bad:** *"Users need a PDF tool."* — vague, solution-shaped, no friction described.

### 2. Target user

Who specifically? One sentence describing the person, their device context, and what they're already doing that this app intersects with. Not a demographic; a behavioral slice.

> **Good:** *"iOS users who already handle PDFs on their phone — receipts, contracts, school forms — and currently work around fragmented free apps or skip the task until they're back at a desktop."*
>
> **Bad:** *"Anyone who uses PDFs."* — too broad to inform design.

### 3. The 3 JTBDs

Three "jobs to be done" in the canonical Christensen form. The wizard accepts these via free-form input (option chips seed thinking; you can override with your own).

```
When ___ (situation),
I want to ___ (motivation),
so I can ___ (expected outcome).
```

Three is the cap. If you have five candidates, pick the three the app must serve perfectly — the other two go in field 5 (out-of-scope) or get demoted to nice-to-haves in feature backlog.

> **Good (one of three):** *"When I get a 40-page PDF on my phone and only need pages 3–7, I want to split and share just those pages, so I can reply to the sender without forwarding the whole document."*

### 4. Success signal

What does it look like, six months after launch, that this app earned its keep? One sentence, preferably observable. Distinguish from vanity metrics (downloads alone don't count); name the behavior or outcome that proves the JTBDs were served.

> **Good:** *"A non-trivial fraction of users buy the lifetime IAP within 30 days, and App Store reviews mention specific PDF operations (compress, watermark) rather than generic praise."*
>
> **Bad:** *"10k downloads."* — downloads are an output, not a signal.

This field anchors `005-launch-readiness.md`. The wizard pulls from here.

### 5. Out-of-scope

What is this app deliberately *not* going to do, even though it would be reasonable to ask why not? 3–5 bullets. Different from `013-anti-list.md`: out-of-scope is about *capability scope* ("we won't do OCR in v1"), while 013 is about *ethical/taste rejections* ("we won't shame users into using us").

> **Good:**
> - *"Cloud storage. PDFs live on-device only. No CloudKit sync of file content."*
> - *"Editing PDF text. Annotation only, not re-flow."*
> - *"Form filling. Static PDF operations only."*

### 6. Anti-vision

The one-paragraph negative version of the mission. Describe the app this *could become* if discipline lapsed — feature creep, scope drift, monetization desperation — so it's named and avoided. This is the field that catches drift in year two.

> **Good:** *"This app is **not** a workflow automation app, a document management platform, a cloud collaboration tool, or a 'PDF-and-also-images-and-also-OCR' Swiss Army knife. It is three or four operations done beautifully on-device. The day we add a 'Team' tab, the spec has been violated."*

---

## How the wizard collects these

`.claude/skills/new-app/SKILL.md` Phase A Step 0 walks the user through the six fields via `AskUserQuestion` calls. Each call either offers 2–3 example chips for shape-priming (which the user can override via "Other"), or — for the JTBDs — runs three sequential questions, each in canonical form, with examples that the user replaces.

**Synthesis (after the 6 fields are captured):**

The wizard then proposes:

- A draft `000-mission.md` sentence derived from field 1 (problem) + field 2 (target user). One sentence, ≤14 words. User confirms or edits.
- A draft `013-anti-list.md` of 3–5 entries derived from field 6 (anti-vision) + the portfolio-wide `docs/NOT_FOR.md`. User confirms or edits.

This synthesis is **derivation, not invention** — every line proposed traces back to a spec field. The user owns the final wording.

---

## Required at `--commit` time

`/new-app --commit <name>` refuses to render templates if any of these conditions hold:

1. `drafts/<name>/DECISIONS/016-spec.md` does not exist.
2. Any of the six field headings is followed by the literal placeholder text from this template (`<...>`, `TBD`, `TODO`, or the example text quoted above).
3. JTBDs do not match the regex shape `When .+, I want to .+, so I .+`.

The wizard surfaces the specific failure and points the user back to step 0.

---

## What good specs look like

- Short. ≤ 500 words total across all six fields.
- Specific. Names the user's situation, not "users."
- Falsifiable. The success signal can actually be checked.
- Anti-positioned. The anti-vision describes the exact failure mode this app could drift into.

## What bad specs look like

- Feature lists. "The app does X, Y, Z." — that's a backlog, not a spec.
- Audience inflation. "Everyone." — if the user is everyone, the app is for no one.
- Vague success ("be successful"). If you can't say what success looks like, you don't have a spec.
- JTBDs that are really features in disguise ("When I open the app, I want to see a list of PDFs"). The situation should be in the world, not in the app.

## Cross-references

- [TEMPLATE.md](TEMPLATE.md) — the generic ADR shape, used by every other numbered ADR
- [000-mission.md](000-mission.md) — the one-sentence distillation of fields 1+2
- [013-anti-list.md](013-anti-list.md) — the ethical/taste rejections, paired with field 6
- [005-launch-readiness.md](005-launch-readiness.md) — measures against field 4
- [docs/NOT_FOR.md](../docs/NOT_FOR.md) — portfolio-wide anti-patterns the spec inherits
- [CLAUDE.md](../CLAUDE.md) — Maturity matrix section explains why this template lives in `DECISIONS/` rather than `templates/`
