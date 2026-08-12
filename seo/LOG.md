# SEO Log

Newest entries at the top. One entry per run. Be specific and be honest about flat days.

---

## 2026-08-13 — flat numbers; two commits still unshipped; the brand name is crowded

Sitemap fetch failure definitively cleared as a server-side problem. Two strategic corrections:
the brand SERP is harder than recorded, and the Reddit "unprompted mentions" were our own posts.

### 🔴 First and loudest: two days on, two commits are still not pushed

`origin/main` is at `64e0047`. The owner's local `seo/2026-08-12` carries **two further commits
that exist nowhere else**:

- `55045ae` — orphan-page fix (`/vs`, `/press`, `/52-weeks` had zero internal links), 42 schemeless
  relative hrefs made absolute, 8 over-length titles, 9 over-length meta descriptions.
- `f33d66d` — removes the bogus `SearchAction` schema; records the real backlink data.

Verified against the live site rather than assumed. Today `https://getweft.xyz/` still serves
`search_term_string` twice, still says `vs Clay` in the footer, still emits `href="about"`,
`href="support"`, `href="vs/dex"` schemeless; `/vs/clay` still carries the 85-character title.
None of it is live.

This matters more than usual because of what GSC says: **internal links = 1.** `55045ae` is the
direct fix for the single most damning number in this log, and it has been sitting in a local
branch for a day. This is the same failure as 08-12 — work lands in the checkout and never
reaches production.

### 🔎 …and we probably caused it. A stale lock has been blocking the repo for 26 hours

`/Users/amuwal_1/Developer/weft/.git/index.lock` exists, 0 bytes, owned by the sandbox user,
timestamped **Aug 12 11:48** — the exact minute `f33d66d` was committed. Our own 08-12 run left
it behind, and a stale `index.lock` blocks `git checkout`, `git merge` and `git add` for the
owner. That is a plausible mechanical explanation for why those two commits were never pushed:
**it may not have been an oversight, it may have been us locking their repo.**

This is the *second* time. The 08-11 run left one that sat ~18h and blocked a checkout on 08-12;
RUNBOOK gained a cleanup check because of it, and the check was performed this run — but the
lock is created by the fetch itself, so checking afterwards catches it without preventing it.
The sandbox **cannot** delete it (`rm` → "Operation not permitted"; the mount refuses the unlink
even though the file is owned by our uid), so it must go in the report every single time.

**Owner action, first thing:**
```
rm -f ~/Developer/weft/.git/index.lock
```

Standing fix worth making: the push instructions already prefer
`git push origin <branch>:main`, which needs no index and cannot be lock-blocked. Keep using that
form, and lead the report with the `rm` rather than burying it.

### GSC, read today via `/u/1/` — flat

| | 2026-08-12 | 2026-08-13 |
|---|---|---|
| Indexed | 1 | **1** |
| Not indexed | 4 | **4** |
| Impressions (90d) | 93 | **94** |
| Clicks (90d) | 5 | **5** |
| Avg position | 12.1 | **12** |
| External links | 33 | **33** |
| Internal links | 1 | **1** |
| Sitemap | Couldn't fetch | **Couldn't fetch** |

Queries unchanged: `weft app` 16 · `w0yft` 7 · `welft` 1. Flat, and flat is the honest reading —
nothing shipped since yesterday, so nothing should have moved.

### 🟢 Sitemap "Couldn't fetch": server side is definitively clear

Used **URL Inspection → TEST LIVE URL** on `https://getweft.xyz/sitemap.xml`. Result:
**"URL is available to Google."** That is a real-time fetch from Google's own infrastructure, so
it is proof rather than inference.

**And it retired a bad check.** The 08-12 run cleared the server side with `curl -A Googlebot` →
200. That was never valid evidence: **getweft.xyz sits behind Cloudflare** (nameservers
`erin/denver.ns.cloudflare.com`, `server: cloudflare`) in front of Vercel, and Cloudflare
classifies bots by IP and reverse DNS, not by user-agent string. A UA-spoofed curl from a random
datacentre IP tells you nothing about what real Googlebot sees. The live test is the only check
that settles it. **Rule: never clear a crawler-access question with a spoofed user-agent.**

Also recorded: inspection reports `sitemap.xml` itself as "URL is unknown to Google", last crawl
`N/A`. Google has genuinely never fetched it — consistent with a queue delay, not a rejection.

So: nothing to fix. If the status has not flipped by **2026-08-14** (48h), remove the sitemap in
GSC and re-submit. Do not go chasing the server.

### 🔴 Correction: the brand SERP is much more crowded than the playbook says

PLAYBOOK described the brand fight as contested by `weft.io` (logistics) and "weft" the textile
term. Ran the actual `weft app` SERP (`hl=en&gl=us`). Page one is dominated by **other live
products named Weft**:

| Product | Where | Verified |
|---|---|---|
| **Weft — Your Wardrobe, Elevated** | **getweft.app** | title fetched, live |
| Weft — Weave work that ships (Scrumban) | letsweft.com | title fetched, live |
| Weft.ai — price tracker | App Store, 5.0 (2) | SERP |
| Weft: Mind Maps | App Store, listed 4 days ago | SERP |
| WEFT FM — community radio 90.1 | weft.org, Play 4.9 (9) | SERP |
| Cityweft | app.cityweft.com | SERP |

`getweft.app` is **one TLD away from getweft.xyz** and is a different product. That is a standing
confusion risk, not just a ranking problem.

**What this changes.** "Get the brand query to top-3" was recorded as the cheapest near-term win.
Against five active same-name products it is not cheap, and the bare term `weft app` may not be
worth fighting for at all — much of its volume is not looking for this product. The winnable
query is the **qualified** one: `weft personal CRM`, `weft journal app`. Retarget accordingly.

### 🟢 Google's AI Overview already describes Weft correctly

On a `"getweft.xyz"` query, getweft.xyz returns **first**, with the intended title and
description, and the AI Overview summarises the product accurately — on-device, no cloud sync, no
AI or streaks, gentle nudges, free on the App Store. The AI-surface groundwork (`llms.txt`, FAQ
JSON-LD, server-rendered copy, no client-side rendering) is doing its job. Narrow, but real, and
it is the first evidence that any of it works.

### 🔴 Correction: the 3 Reddit links are our own posts

08-12 read them as unprompted third-party discussion and called them "a warmer starting point."
They are not. Both traceable posts are self-posts by `u/Cold-Tear-968`:

- r/apps — "[iOS] I made Weft — a calm personal CRM…" · **1 upvote, 0 comments**
- r/sideprojects — same post

No third-party thread exists. LAUNCH-KIT §5 is a cold start, and the 1-upvote/0-comment result on
r/apps is itself a data point about that copy.

### 🟡 Undocumented channel: there is an active Instagram presence

Searching `"getweft.xyz"` surfaced an official account **`weft.stay.close`** plus a steady stream
of creator posts ending "Free on the App Store — getweft.xyz": `itsalexalexander` (180+ likes, 1
week), `heartfelt_writing_journey` (400+ likes), `friendshipforadults`, `after5co`,
`journalbyalina`, `thetinywisdom`, `linesbyiman`, `sea.scary.in`, `dr.hiacynta`.

**This log has never mentioned it.** Instagram links are `nofollow` and will not move GSC's
referring-domain count, so it does not contradict any measurement here — but it means acquisition
is not idle while SEO is flat, and an SEO agent reasoning about "no distribution" has been working
from an incomplete picture.

**Question for the owner:** is this paid UGC, a creator programme, or organic? It changes what
"0 App Store ratings after 2.7 months" means — if these posts are driving installs and still
producing no ratings, the problem is the in-app ask, not reach.

### Shipped: App Store links now point at Apple's canonical slug

Apple has changed the listing slug. Measured today:
`…/weft-stay-close/id6770074864` → **301** → `…/weft-personal-crm-journal/id6770074864`.

All **17** links across 9 pages updated, removing a redirect hop from every download CTA on the
site. LAUNCH-KIT said "the slug is still `weft-stay-close` and should not be corrected" — that was
true on 08-12 and is false now; corrected there.

`trackName` re-checked and unchanged: `Weft: Personal CRM Journal`, v1.0.2, first released
2026-05-21, requires iOS 26.0, free, Lifestyle/Productivity, **`userRatingCount: 0`**.

### Post-deploy audit: clean

All **15** sitemap URLs fetched — **15/15 return 200**, zero redirects. The `/vs/` trailing-slash
bug fixed on 08-12 is confirmed live and gone. Backlog item satisfied for this deploy.

*(Method note: an earlier pass in this run appeared to show `/vs/` still 308ing. That was a stale
`/tmp/urls.txt` left by a previous run which a failed write did not overwrite — the shell reported
`Permission denied` and the loop silently read the old file. Write scratch files to a fresh
`mktemp -d`, and treat a failed write followed by a plausible result as a red flag.)*

### Content: none

Fifth run at zero, and the reason is sharper than before: internal links = 1, and the fix for that
is written and unpushed. Adding pages to a site Google has crawled and judged thin — while the
plumbing fix sits in a branch — would be the wrong move.

### Next run

1. **Were `55045ae` and `f33d66d` pushed?** Check first, say it loudly if not.
2. Sitemap status. If still "Couldn't fetch" at 48h+, remove and re-submit in GSC.
3. **After** the deploy lands: Request Indexing on `/` and `/vs`, and run
   `sh marketing/scripts/indexnow.sh` for the changed paths. Not before — it would re-cache the
   old pages.
4. Bing Webmaster Tools is now the top blocked item and has been for three runs.
5. Ask the owner about the Instagram channel.

---

## 2026-08-12 (later) — 🟢 MAJOR CORRECTION: the site IS verified and IS indexed

The owner opened Search Console and it was simply there. Everything below was then read
first-hand from GSC. **The core premise of the previous three runs was wrong.**

### What was wrong, and why

- **"Not verified in GSC" — false.** `sc-domain:getweft.xyz` has existed all along, under the
  owner's **second** Google account (`/u/1/`). The 08-11 run checked `/u/0/`
  (`amitmuwal@cuon.co.jp`), got "you do not have access," and reported a root cause. The playbook
  had explicitly flagged "it may be verified under a different Google account" as a caveat — and
  the run under-weighted its own caveat and led with the confident version. That is the actual
  process failure worth remembering, more than the wrong fact.
- **"Not indexed" — false.** GSC shows 1 page indexed and real search traffic.
- **Root cause of the wrong reading:** the `WebSearch` tool does not honour `site:`. Three runs
  fed it `site:getweft.xyz`, got generic `.xyz` TLD marketing pages, and scored that as "no
  results → not indexed." An unrelated result set was never evidence of anything. Recorded as a
  hard rule in PLAYBOOK and RUNBOOK: **GSC is the only source for index state.**

### The real numbers (GSC, read 2026-08-12)

**Page indexing:** 1 indexed · 4 not indexed —
2 "Alternate page with proper canonical tag", 1 "Page with redirect",
1 "Crawled - currently not indexed". So Google knows **5 URLs; the sitemap lists 15.**

**Performance, last 90 days:** 93 impressions · 5 clicks · 5.4% CTR · average position 12.1.

**Top queries:** `weft app` 16 impr · `w0yft` 7 · `welft` 1. All brand-navigational or typos.
Zero generic category terms — consistent with 1 indexed page and no authority.

### Shipped: sitemap submitted

Sitemaps was empty — `0 of 0`. **This part of the old diagnosis was real.** Submitted
`https://getweft.xyz/sitemap.xml` with the owner's explicit approval; GSC confirmed
"Sitemap submitted successfully" and the row now reads 1 of 1.

Status immediately after submission: **"Couldn't fetch", 0 discovered pages.** Checked the
obvious server-side causes and found none — as Googlebot: HTTP 200, `application/xml`, 4054 bytes,
zero redirects, parses as XML, 15 `<loc>` entries, no BOM before `<?xml`; `robots.txt` both
allows all and declares the sitemap. This is most likely the familiar transient state GSC shows
before it has actually attempted a fetch. **Not treating that as settled — next run must confirm
it flipped to "Success".** If it has not within ~48h, it is real and worth chasing.

That single submission plausibly matters more than anything else done this week: 10 of 15 URLs
were undiscovered purely because nothing ever told Google they existed.

### What this changes strategically

The framing shifts from "invisible to Google" to **"discovered, thin, and losing its own brand."**

- Position **12.1 for the site's own name** is the sharpest problem. A brand query should return
  1-3. `weft` is a textile term and `weft.io` is an established logistics company, so the brand
  SERP is contested. This is the most winnable near-term fight — and it is won with links and
  mentions, not pages.
- 1 indexed page and 0 referring domains. "Crawled - currently not indexed" is Google saying it
  looked and was unimpressed. More pages do not answer that; external signals do.
- The content ceiling stays at ~0-1/day for now. The reason changed but the answer did not.

### Also this run

- The competitor corrections were finally pushed as `seo/2026-08-12`, but the merge to `main`
  failed on a stale `.git/index.lock` **left by our own 08-11 run** — 0 bytes, ~18h old, owned by
  the sandbox user. The sandbox could not delete it (mount refuses cross-user unlink). Handed the
  owner `rm -f` plus `git push origin seo/2026-08-12:main`, which needs no checkout and cannot be
  lock-blocked. RUNBOOK now carries a cleanup check and that push form.
- Inline `#` comments in paste-ready command blocks broke on the owner's zsh
  (`interactive_comments` off) and were parsed as arguments. No comments in command blocks.
- **As of this entry the live site still serves the stale competitor facts** — the merge had not
  landed yet.

### Post-deploy audit — found and fixed the "Page with redirect" exclusion

The competitor corrections deployed (Vercel, commit `7a2a604`) and were verified live: `/vs/clay`
now titles "Weft vs Mesh (formerly Clay)" with zero `Mac-first`, `/vs/folk` reads $288/year,
`/vs/dex` reads $12/$20 per month. Only the one deliberate `clay.earth` rename sentence remains.

While checking, `/vs/` returned **308**. Chased it, and it is a real self-inflicted indexing bug
that maps directly onto a GSC exclusion:

- `vercel.json` sets `"trailingSlash": false`, so `/vs/` permanently redirects to `/vs`.
- But `sitemap.xml` listed `https://getweft.xyz/vs/`, and `marketing/vs/index.html` pointed its
  **canonical, both hreflang alternates, and `og:url`** at the same trailing-slash form — plus the
  four comparison pages linked `/vs/` in their breadcrumb JSON-LD.

So every self-reference for that page named a URL that redirects. That is almost certainly the
**"Page with redirect" = 1** exclusion, and plausibly feeds the canonical-alternate count too.
Fixed across 6 files; sitemap now has 0 trailing-slash URLs other than the root.

Second bug found the same way: `/blog/` → 308 → `/blog` → **404**. It appeared only inside the
blog post's `BreadcrumbList` JSON-LD as a "Blog" item — a breadcrumb asserting an index page that
has never existed. Removed the phantom item and renumbered; there is exactly one post, so the
honest breadcrumb is Weft > post.

Neither was findable from GSC's summary alone — both surfaced from auditing the live site against
the sitemap. Worth repeating after any deploy: **fetch every sitemap URL and assert 200.**

Validated after editing: all JSON-LD parses, sitemap and feed parse as XML, 15 URLs intact.

### Full technical audit + fixes — the discovery problem, found and fixed

Crawled all 15 sitemap URLs as Googlebot and rebuilt the internal link graph. The finding
explains the indexing numbers almost exactly.

**Three pages were unreachable by crawl — zero internal links, from anywhere:**
`/vs` (the comparison hub), `/press`, `/52-weeks`. They existed only in a sitemap that had
never been submitted, so there was no path to them at all.

**And the arithmetic lines up.** The homepage's only content links were `/vs/clay`, `/vs/dex`,
`/vs/folk`, `/vs/notion` and `/blog/why-another-personal-crm`. That is 5 pages — and GSC knows
about exactly 5 URLs. Google indexed the homepage and crawled what the homepage pointed at.
Everything else was invisible: no links in, no sitemap. This was never a penalty or a quality
problem. It was a plumbing problem.

Fixed:

- **`/vs` linked from 7 pages** (was 0) — "All comparisons" at the top of every Compare column.
  A hub page with no inbound links is the worst kind of orphan; it is the page meant to
  distribute authority to the four comparisons.
- **`/52-weeks` linked from 7 pages** (was 0), **`/press` from 14** (was 0).
- **42 schemeless relative hrefs made absolute** (`href="support"` → `/support`). They resolved
  correctly from `/` but would silently break from any nested path.
- **8 titles over Google's ~62-char display limit, shortened.** The worst was `/vs/clay` at 85
  chars — a third of it never displayed. Meaning and keywords preserved.
- **9 meta descriptions over ~160 chars, shortened.** Same reason.
- **Footer label "vs Clay" → "vs Mesh (Clay)"**, catching a spot the rename sweep had missed.
- **`en.json` kept in sync** for the two i18n-bound pages (`/`, `/terms`) so
  `inline-i18n-defaults.mjs` stays a no-op rather than reverting the new titles.

Verified after: 0 orphans, 0 titles over 62c, 0 descriptions over 160c, all JSON-LD parses,
sitemap and feed parse, all HTML tags balanced, `en.json` matches the inlined HTML.

*One false alarm worth recording so it is not re-investigated:* a naive `<ul>` grep reported an
imbalance on `/feature-requests`. It was the grep — it missed `<ul class="...">`. An
attribute-aware check shows every tag balanced. Do not trust bare-tag greps for markup checks.

### GSC drilldown — two more corrections, and a real bug

Stopped inferring and read the actual excluded URLs.

**I was wrong about the redirect exclusion.** Earlier today I said `/vs/` was "almost certainly"
the "Page with redirect" entry. It is not. The affected URL is **`http://getweft.xyz/`** — the
plain-HTTP homepage redirecting to HTTPS. That is normal, correct, and present on every HTTPS
site. Nothing to fix. The `/vs/` trailing-slash fix was still worth making on its own merits, but
it did not cause this and the exclusion will not clear because of it. Flagged so a future run does
not "validate fix" and wonder why nothing changes.

**"Alternate page with proper canonical tag" (2)** — both are homepage variants, both correctly
canonicalised, both benign:

- `https://getweft.xyz/?from=AppAgg.com&utm_campaign=AppAgg.com&utm_medium=referral&utm_source=AppAgg.com`
- `https://getweft.xyz/?q={search_term_string}`

The first is benign *and informative* — it is a referral URL, i.e. evidence of an inbound link.

**The second is a real bug, now fixed.** The homepage `WebSite` schema declared a
`potentialAction: SearchAction` with `urlTemplate: https://getweft.xyz/?q={search_term_string}`.
**The site has no search feature at all** — zero forms, no search input. So the markup advertised
a capability that does not exist, and Google dutifully crawled the literal placeholder as a URL.
Removed the `potentialAction` block; the other five schema types on the page are untouched and all
16 JSON-LD blocks across the site still parse.

### 🟢 Third false premise dead: the site is NOT at zero referring domains

GSC Links: **33 external links from 3 domains.**

| Linking site | Links |
|---|---|
| apple.com | 28 |
| **reddit.com** | **3** |
| appagg.com | 2 |

All target the homepage. The apple.com links are the App Store listing's "developer website"
field (the anchor text appears in English, Arabic, Spanish and Italian, which is the App Store
localising that label) — low value individually, but they are real and they are almost certainly
how Google discovered the site in the first place.

**The Reddit links are the interesting ones.** Three links, unprompted, before any outreach. GSC
will not reveal the source URLs for a domain property, so finding the threads is a manual job —
but somebody has already talked about this app somewhere, and that is a warmer starting point for
the LAUNCH-KIT Reddit section than a cold post.

**Internal links: 1.** Google found exactly one internal link across the whole site. That is the
single most damning number in this log, it corroborates the orphan finding precisely, and the
footer work done today is the direct fix for it.

### Deliberately NOT done: Request Indexing

Considered and rejected for now. Requesting indexing crawls the page *as it is at that moment*,
and the fixes from this run are committed but **not yet deployed**. Requesting now would have
Google re-cache the pre-fix pages. The correct order is deploy first, then request indexing on
`/` and `/vs`. Left for the owner or the next run.

### Next run

1. **GSC first, via `/u/1/`, with `&hl=en`.** Did the sitemap flip to "Success"? Did discovered
   pages rise? Did indexed rise off 1?
2. Confirm `main` merged and the Clay/Folk/Dex corrections are actually live.
3. Bing Webmaster — import from GSC now that the property is confirmed.
4. Then LAUNCH-KIT top-down. Links are now the main lever, not a prerequisite.

---

## 2026-08-12 (earlier)

**Index check — NO CHANGE. Still not indexed.** Day 3 of measurement, flat.

- `site:getweft.xyz` → no results for the domain; only generic `.xyz` TLD pages.
- Exact H1 `"Remember the people you love — one line at a time"` → no results, only unrelated
  quote-collection pages.

Flat is the expected reading. Nothing upstream has changed that would make indexing possible.

### 🔴 The main finding: yesterday's corrections never shipped

`origin/main` is still at `469be0b`. Branch `seo/2026-08-11` is **not on GitHub** —
`git ls-remote --heads origin` lists only `main`, `release/1.0.2` and `seo/sitemap-lastmod`.
The branch was landed into the owner's local checkout on 2026-08-11 and never pushed.

Confirmed against the live site rather than assumed. `https://getweft.xyz/vs/clay` today still
serves `Mac-first` three times and links `clay.earth` twice; `/vs/folk` still says
`$216+/year`; `/vs/dex` still says `$144/year ($12/month)`. So for a second day the site has been
publishing three false claims about competitors, including an entire comparison page written
against a product name that was retired in June 2025.

Nothing about yesterday's diagnosis was wrong. The work simply did not reach production, and a
day of it was nearly lost — the only copy was an unpushed branch in a scratch clone that a
container reset would have destroyed.

**Recovered.** Yesterday's commit was extracted with `git format-patch` and re-applied onto
`seo/2026-08-12`, which now carries both days' work. Re-verified after applying: no `Mac-first`
and no live `clay.earth` reference survives except the one deliberate sentence on `/vs/clay`
explaining the rename.

### GSC + Bing: blind this run

The Chrome bridge was connected (one macOS browser, local) but unusable. Search Console never
settled; Bing Webmaster returned `Frame with ID 0 was removed`; and a control navigation to
`example.com` also timed out after 45s waiting for `document_idle`. So this is the bridge or a
sleeping/locked desktop, not a GSC-specific problem — a scheduled run at 07:00 with nobody there
to clear a pending extension prompt is the likely cause.

**Stated plainly: this run could not confirm whether GSC verification has happened since
yesterday.** That is weaker information than yesterday, when the answer was a definitive "not
verified." Recorded as `unknown`, not carried forward as `NO`.

### Competitor facts — all four re-verified today, first-hand

Re-verified rather than trusted, because this run re-ships yesterday's claims and the runbook
forbids reporting anything not actually checked this run. Each against the vendor's own page:

- **Mesh** (me.sh/pricing) — Personal free up to 1,000 contacts, credit card required; Pro $10/mo;
  Team $40/seat/mo. Site footer lists macOS, web, Windows & iOS. Matches what shipped. ✅
- **Folk** (folk.app/pricing) — Standard $24/member/mo billed yearly, shown on the page as
  **$288 billed yearly**, or $30/mo billed monthly. Confirms the correction from `$216+`. ✅
- **Dex** (getdex.com/pricing) — Premium **$12/mo**, Professional **$20/mo**, with an
  Annual (40% off) / Quarterly (20% off) / Monthly toggle. The annual total still is not
  derivable from the page, so quoting per-month rates remains the honest call. Page also states
  "Start a 7-day free trial today," confirming the free-tier fix. ✅
- **Notion** (notion.com/pricing) — Free $0, Plus **$10/member/mo**, Business $20. The `/vs/notion`
  claims are correct. **Clears the oldest open maintenance item** — unchecked since May 2026.

The Automattic acquisition claim was also sourced properly this time: TechCrunch, 2025-06-12,
"Automattic acquires relationship manager Clay." Safe to state in the crm.org email.

### App Store: 0 ratings confirmed — and the app has been renamed

Queried the iTunes Lookup API directly (the HTML listing returns 0 bytes to this sandbox):

- `userRatingCount: 0`, `averageUserRating: 0` — **independently confirmed, no longer carried
  forward from notes.** Clears a backlog item.
- `releaseDate: 2026-05-21`, so the app is ~2.7 months old, not 3.
- `version: 1.0.2`, released 2026-08-04. `minimumOsVersion: 26.0` — confirms the "iOS 26 only"
  line in the Show HN draft. `formattedPrice: Free`. Genre Lifestyle / Productivity.
- **`trackName` is now `Weft: Personal CRM Journal`.** The launch kit was written when the app was
  "Weft — Stay Close."

That rename matters more than it looks. The AlternativeTo submission copy carried a name that no
longer matches the store listing, and a directory entry whose name disagrees with the App Store is
the kind of mismatch that gets a listing rejected or quietly de-duplicated. Fixed in LAUNCH-KIT §1,
with the old name kept as a former-name note since the store URL slug is still `weft-stay-close`.

### Competitive signal worth recording

Searching the Clay rebrand surfaced **trywend.io** — a rival personal CRM running this exact
playbook and winning it: "What Happened to Clay (clay.earth)? Clay Is Now Mesh", "Mesh (formerly
Clay) Alternatives in 2026", "Wend vs Mesh, formerly Clay (2026)". Dex is also ranking a
`/blog/mesh-review/` page.

Two honest readings. The strategy is sound — the rename genuinely is live search intent, and
`/vs/clay` is aimed at it correctly. But competitors are already indexed and answering that query
today, so this window is being consumed while Weft is invisible. It is an argument for urgency on
verification and links, not for writing more pages.

### Content

None. Correct number while unindexed — this is the third run in a row where the ceiling is zero
and the reason has not changed.

### Next run

1. Re-check index status.
2. **Check whether `seo/2026-08-12` was pushed.** If two days of corrections are still unshipped,
   say so first and loudly — it outranks everything else in this file.
3. Re-attempt GSC/Bing. If the bridge works, the first question is still verification + sitemap.
4. If GSC is verified: AlternativeTo and the crm.org correction email, in that order.

---

## 2026-08-11

**Index check — NO CHANGE. Still not indexed.**

- `site:getweft.xyz` → no results for the domain. Search engine returned generic `.xyz` TLD pages.
- Exact H1 `"Remember the people you love — one line at a time"` → no results. Only unrelated
  quote-collection pages.
- `getweft.xyz Weft personal CRM iOS` → no results mentioning the domain. (The Crunchbase "Weft"
  entry that surfaces is a 2013 logistics company at weft.io — unrelated, and worth remembering so
  it isn't mistaken for progress later.)

Day 2 of measurement, flat. Expected — nothing has changed upstream to make indexing possible.

### 🔴 Root cause found: getweft.xyz is not verified in Google Search Console

First run with access to the owner's browser, and it immediately answered the open question the
playbook flagged as the prime suspect.

Loaded GSC in the owner's logged-in Chrome. The session is signed in as `amitmuwal@cuon.co.jp`
and lands on `sc-domain:kurogane.app` — a different property, which shows the login works and GSC
is in use. Then:

- `sc-domain:getweft.xyz` → "You do not have access to this property"
- `https://getweft.xyz/` (URL-prefix variant) → same

So the domain was never added under this account, and the sitemap was therefore never submitted.
**Google may simply not know the site exists.** That is consistent with every other measurement:
crawlers get HTTP 200, robots and sitemap are clean, the H1 is server-rendered — and yet nothing
is indexed and no page anywhere links in. With no links and no submission there is no discovery
path at all.

*Caveat, stated plainly:* it is possible getweft.xyz is verified under a different Google account
(the owner also has a personal Gmail). Check that before re-verifying, to avoid a duplicate.

**Bing Webmaster Tools:** not signed in on this browser — landed on the signed-out marketing page.
Cannot confirm whether the site is submitted to Bing. Also unverified, in effect.

Did **not** attempt verification. It needs DNS/registrar access and is an account-settings change;
that is the owner's to do. Steps are written out in `LAUNCH-KIT.md` §0a.

### Shipped: competitor fact corrections

Ran the ≥30-day re-verification against each competitor's own pricing page. Found three real
errors, one severe. All fixed and validated.

**1. Clay no longer exists under that name — severe.** `/vs/clay` described "Clay (clay.earth)" as
a "beautiful Mac-first personal CRM" throughout. Clay was acquired by Automattic in June 2025 and
rebranded to **Mesh** (me.sh). Mesh's own site says "Available on macOS, Windows, Web, Android &
iOS" — so "Mac-first" was false too, independent of the rename. An entire comparison page was
arguing against a product under a retired name and a wrong platform story.

Fixed by rewriting the page around Mesh while **keeping the `/vs/clay` URL**. Deliberate call:
people still search "Clay", "what happened to Clay" is live intent, and moving the URL would have
cost the sitemap entry and any future equity for nothing. The page now opens by explaining the
rename, which is genuinely useful to a searcher and is the kind of thing answer engines quote.
"Clay" is retained in the title, H1, meta and schema `alternateName` so the keyword still matches.

Verified against me.sh/pricing: Personal free up to 1,000 contacts (credit card required), Pro
$10/mo billed annually for unlimited, Team $40/seat/mo. Updated the free-tier row (was "Limited
free / trial"), the people-cap row (was "Unlimited"), and the platform row. The ~$120/yr price
claim held up and was kept, restated as "$10/mo billed annually".

**2. Folk price was wrong.** Page claimed "$216+/year (team pricing)". folk.app/pricing lists
Standard at $24/member/month billed yearly = **$288/year**, or $30 billed monthly. Corrected in
the table and the prose.

**3. Dex price was unverifiable as stated.** Page claimed "$144/year ($12/month)". getdex.com's
pricing page shows Premium $12/mo and Professional $20/mo with an annual/quarterly/monthly toggle,
and it is not determinable from the page whether $12 is the annual-billed or monthly rate.
Replaced the derived annual figure with the two per-month prices, which are stated outright.
Also corrected the free tier from "Limited trial" to the stated "7-day free trial".

Swept the rest of the site for knock-on staleness: the `clay.earth` outbound link on the `/vs`
hub, "AI-heavy Mac-first" descriptors in three cross-page related-links blocks, the `/vs` hub
bullet, and the `feed.xml` summary. All updated. 41 edits total across 6 files.

Validated after editing: JSON-LD parses on all five `/vs` pages, `feed.xml` and `sitemap.xml`
parse as XML, comparison tables still have 3 cells per row, no `Mac-first` or live `clay.earth`
references remain.

**Not re-verified this run:** `/vs/notion` price claims ($10/mo Plus, free plan). Flagged in
BACKLOG. App Store rating count carried forward from prior notes as 0, not independently checked.

### Also: `seo/` did not exist

Cloned the repo and `seo/` was absent from `main` and from every branch — `git log --all -- seo/`
returns nothing, so the setup work referenced by the task was never merged. Recreated the memory
files from scratch this run: `PLAYBOOK.md`, `LAUNCH-KIT.md`, `RUNBOOK.md`, `LOG.md`, `BACKLOG.md`,
`metrics.csv`. Future runs now have memory, assuming this lands.

Two scripts the task procedure calls for are also missing: `marketing/scripts/build_page.py` and
`marketing/scripts/update_sitemap.py`. Only `indexnow.sh`, `iap-promo-images.py` and
`inline-i18n-defaults.mjs` exist. Noted in RUNBOOK and BACKLOG.

### Shipping arrangement resolved

The push failure was diagnosed properly rather than worked around. The sandbox is a separate Linux
VM with no `/Users` and no `~/.ssh`; the remote is SSH, so the key is simply absent. Network is
fine — `ssh -T git@github.com` reaches GitHub and returns "Permission denied (publickey)", and
port 22 is open.

The owner connected their checkout at `/Users/amuwal_1/Developer/weft` instead of mounting `.ssh`,
which is the right call — the private key stays on the Mac and is never readable in the sandbox.
Branch `seo/2026-08-11` was landed directly in their repo via
`git fetch /tmp/weft seo/2026-08-11:seo/2026-08-11`, which does not touch their working tree.
They were mid-release on `release/1.0.2` with six untracked files; all left alone. Verified with
`git fsck` and by re-parsing JSON-LD out of the branch contents.

Full procedure now written up in `RUNBOOK.md`. Future runs should commit into the connected
checkout and report the push commands, not produce patches.

### Next run

1. Re-check index status.
2. Check whether GSC verification happened. If yes: submit sitemap, request indexing on `/`, and
   record the first real impression numbers.
3. If GSC is verified, AlternativeTo and the crm.org correction email are the next two actions —
   both are written and ready in LAUNCH-KIT.
