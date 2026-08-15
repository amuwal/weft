# Launch Kit — the priority queue

Copy-paste-ready assets, ordered by value per unit of effort. Work top-down. Log every submission
in `LOG.md` with the date and what came back.

**Status legend:** `TODO` · `SUBMITTED (date)` · `LIVE (url)` · `REJECTED (reason)`

---

## 0. Blocked on the owner — do these first, they gate everything

### 0a. Google Search Console — `DONE (2026-08-12)` ✅ · indexing requested 2026-08-16 ✅
**The 08-11 entry here was wrong.** The property has existed all along under the owner's
**second** Google account — console URL `/u/1/`. Sitemap submitted 2026-08-12
(it had never been submitted; that part was real). Add `&hl=en`, the UI defaults to Japanese.

**Request Indexing — done 2026-08-16.** Nine pages queued: `/vs/clay`, `/vs`, `/vs/dex`,
`/vs/notion`, `/vs/folk`, `/blog/why-another-personal-crm`, `/52-weeks`, `/about`, `/press`.
All nine had reported **"URL is unknown to Google"** beforehand. Done under the task's standing
approval and only after the deploy landed, so the pages Google fetches are the current ones.

**Sitemap remains `Couldn't fetch` on Google, and that is now known not to be a file problem** —
see 0b. Delete-and-re-add was executed 08-16; verdict due 08-18.

### 0b. Bing Webmaster Tools — `DONE` ✅ — **it was already set up; this item was wrong for five runs**
Checked properly on 2026-08-16: `getweft.xyz` is a **live property** and has been since at least
**2026-08-05**. The "not signed in" note came from a single glance at a signed-out landing page on
08-11 and was then copied forward by four later runs. *(The page takes ~20 seconds to render —
an early screenshot looks signed-out even when it is not.)*

**State on 2026-08-16:**

| | |
|---|---|
| Sitemap status | **Success** — 15 URLs discovered, 0 errors, 0 warnings |
| Last crawl | 8/7/2026 |
| Search performance | 0 clicks, 0 impressions |
| Site Explorer → Indexed URLs | **"No data available"** |

So Bing has **discovered all 15 URLs and indexed none.** The discovery path works; the authority
problem is the same one Google has.

**The valuable by-product:** Bing parsing the identical `sitemap.xml` with zero errors is what
proved the file was never the cause of Google's "Sitemap could not be read." Use Bing as the
control whenever Google reports a file-level fault.

### 0c. IndexNow key — `DONE (2026-08-15)` ✅
Key file verified: `https://getweft.xyz/0325d2ef1f3c51e28992f5b343647609.txt` returns 200 and its
body is exactly the key `indexnow.sh` sends.

`indexnow.sh` was **also rewritten on 2026-08-15** — it had been ignoring its arguments and
pinging a hardcoded, out-of-date list of 10 URLs on every run, which is the throttling behaviour
this note warned about. It is now argument-driven and pre-checks each path for a 200:

```
sh marketing/scripts/indexnow.sh /vs/clay /vs/dex     # only what changed
```

**First real submission: 2026-08-16.** `indexnow.sh --all` — all 15 URLs pre-checked 200, POST
returned **HTTP 200**. `--all` was justified because that deploy rewrote internal links on every
page. Default back to naming only changed paths.

---

> ### ⚠️ Everything below §1 is owner-gated. Read this before wondering why nothing moves.
>
> As of 2026-08-16 these items have sat at TODO for **six** consecutive runs. That is not neglect —
> **no scheduled agent run can clear them.** AlternativeTo, SaaSHub and Indie Hackers require
> *creating an account*; the crm.org correction requires *sending mail as the owner*; Reddit,
> Show HN and Product Hunt require *posting publicly as the owner*. An automated run is not
> permitted to do any of those, and should not be.
>
> The copy below is written, fact-checked and ready to paste. **The bottleneck is 20 minutes of
> the owner's time, not more agent work.** With the site indexed but holding 0 referring domains
> that it did not get from Apple, this queue is now the binding constraint on the whole project.
>
> **This is truer on 2026-08-16 than it has ever been.** Every other lever is now spent: the code
> is shipped and live, Bing is set up and reading the sitemap cleanly, nine pages are sitting in
> Google's priority crawl queue, and IndexNow has been pinged. There is no remaining technical
> task an agent can do that would move traffic. **Links are the entire remaining story.**

## 1. Directory listings — no gatekeeper, permanent, crawled

These are the cheapest real links available. None require a launch date.

### AlternativeTo — `TODO`
*Name re-verified 2026-08-13 against the iTunes Lookup API: **Weft: Personal CRM Journal**
(it was "Weft — Stay Close" when this kit was written). Use the current name — a directory entry
that disagrees with the App Store gets rejected or de-duplicated.*

***Slug correction (2026-08-13):** the 08-12 note said the URL slug was still `weft-stay-close`
and should not be corrected. That is now false — Apple has moved it, and
`…/weft-stay-close/id6770074864` **301s** to `…/weft-personal-crm-journal/id6770074864`. Always
link the canonical form:*
`https://apps.apple.com/us/app/weft-personal-crm-journal/id6770074864`

*Note when writing listings: **five-plus other live products are called Weft**, including
`getweft.app` (a wardrobe app one TLD away). Always use the full name, never the bare word.*

https://alternativeto.net/manage/new-app/ — list Weft as an alternative to Dex, Mesh, Monica,
Notion. High domain authority, and it is a common source for AI answer engines.

> **Name:** Weft: Personal CRM Journal
> **Category:** Personal CRM / Productivity · **Platform:** iOS
> **License:** Freemium
> **Short description:** A private, on-device personal CRM for iOS. Weft holds the 5-25 people you
> actually want to stay close to — not a contact database. You write one line about someone after
> you talk; the app remembers it and quietly reminds you who you have not spoken to in a while.
> There is no account, no server, and no cloud AI. Notes stay on your phone unless you turn on
> Apple's end-to-end-encrypted iCloud sync. Free for 7 people forever; $18.99/year or $39.99 once.

### Other directories — `TODO`
- **Product Hunt** — see §2, needs a scheduled date.
- **Indie Hackers** products directory — free listing, allows a founder story.
- **SaaSHub** — https://www.saashub.com/submit — mirrors AlternativeTo, separately crawled.
- **Apple's own "Made in Japan" / indie roundups** — see §4.

---

## 2. Show HN + Product Hunt — one shot each, do not waste them

Do **not** fire these until GSC is verified. If the launch lands while the site is invisible to
Google you lose most of the compounding benefit.

### Show HN — `TODO`
Post Tue-Thu, 8-10am ET. Title must start `Show HN:`. No marketing voice; HN punishes it.

> **Title:** Show HN: Weft – an on-device personal CRM for the 25 people you actually care about
>
> **Body:**
> I built this because I realised I had not called my closest friend in four months, and I only
> noticed by accident.
>
> Every personal CRM I tried was built for networkers — thousands of contacts, LinkedIn
> enrichment, pipeline views. I did not want a pipeline for my friends. I wanted somewhere to
> write "she is worried about her mum's surgery on the 14th" and be reminded of it before I next
> called her.
>
> So Weft caps you at ~25 people on purpose. There is no account and no server — I cannot see your
> notes because there is nowhere for them to go. Storage is on-device, with optional iCloud sync
> that is end-to-end encrypted by Apple. No cloud LLM anywhere in the product; I think an
> auto-generated summary of a friend defeats the point.
>
> Trade-offs, honestly: iOS 26 only, so most of the world cannot run it. No web app. No import,
> so you type the names in yourself. If you need to track 500 people, Dex or Mesh will serve you
> far better and I would rather you used them.
>
> Free for 7 people, $18.99/year or $39.99 once. Solo dev in Tokyo.
> https://getweft.xyz

### Product Hunt — `TODO`
Book a Tuesday or Wednesday. Needs: gallery images, a 60s demo video, first comment ready.
Reuse the Show HN body, softened, for the first comment.

---

## 3. The crm.org correction email — `TODO`

crm.org's personal-CRM roundup still lists Clay at clay.earth. Clay was acquired by Automattic in
June 2025 and is now **Mesh** at me.sh. A correction email is a legitimate reason to make contact
and often earns a mention.

> **Subject:** Correction for your personal CRM roundup — Clay is now Mesh
>
> Hi — small factual note on your personal CRM roundup: Clay (clay.earth) was acquired by
> Automattic in June 2025 and has rebranded to Mesh, at me.sh. The old name and domain still
> appear in the piece. Their pricing page now lists a free Personal tier up to 1,000 contacts and
> Pro at $10/month billed annually.
>
> Unrelated, and entirely up to you: I make a small iOS personal CRM called Weft
> (https://getweft.xyz) — on-device, no account, capped at ~25 people by design. It is a
> deliberately narrow tool and not a fit for every roundup, but if you ever cover the
> privacy-first end of the category I would be glad to answer questions.
>
> Either way, thanks for maintaining the list.

**Rule:** send the correction because it is true and useful. Do not condition it on coverage.

---

## 4. Indie iOS press — `TODO`

Small, personal, one at a time. Include a promo code. Never BCC a list.

- **The Sweet Setup** — https://thesweetsetup.com/contact/
- **MacStories** — app submissions; Federico Viticci and John Voorhees
- **9to5Mac** / **iMore** tips lines
- **Six Colors** (Jason Snell) — occasional indie roundups
- **Japanese Mac/iOS blogs** — an underused angle: solo dev in Tokyo, bilingual site

**Verified app facts (2026-08-12, iTunes Lookup API) — reuse these, do not re-derive:**
name `Weft: Personal CRM Journal` · v1.0.2 (2026-08-04) · first released 2026-05-21 ·
requires iOS 26.0 · free with IAP · Lifestyle / Productivity · 0 ratings.

> **Pitch (keep it this short):**
> Weft is a personal CRM for iOS that caps you at ~25 people on purpose. No account, no server, no
> cloud AI — notes live on device, with optional E2EE iCloud sync. Built by one person in Tokyo.
> Free for 7 people; $18.99/yr or $39.99 once. Happy to send a promo code.
> https://getweft.xyz

---

## 5. Reddit — `TODO`, read the rules first

**Cold start, corrected 2026-08-13.** The 3 Reddit links GSC reports are **our own** — two
self-posts by `u/Cold-Tear-968` in **r/apps** (1 upvote, 0 comments) and **r/sideprojects**. An
earlier note claimed these were unprompted third-party mentions and a warm entry point. They are
not; there is no existing thread to join.

**Treat the r/apps result as a test that failed.** "[iOS] I made Weft — a calm personal CRM for
the 5–25 people you actually care about (no AI, no streaks)" earned 1 upvote and no comments.
Do not recycle that framing. The problem-story approach below is untested and is the next thing
to try.

**~39% of the obvious subreddits ban self-promotion outright. A ban is permanent and public.**
Check each subreddit's rules page and posting history before writing anything.

Plausible, in rough order of tolerance: r/iosapps (has a promo thread), r/apple (very strict),
r/productivity (strict), r/digitalminimalism (topical fit, strict), r/SideProject (permissive),
r/iOSProgramming (dev-angle post, permissive).

Best approach is a story post about the *problem* that mentions the app once at the end, not a
launch announcement.
