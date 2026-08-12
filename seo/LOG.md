# SEO Log

Newest entries at the top. One entry per run. Be specific and be honest about flat days.

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
