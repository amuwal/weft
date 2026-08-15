# Backlog

Ordered by value. Move items to `LOG.md` when done.

## Blocked on the owner (highest value, cannot be agent-executed)

- [ ] 🔴 **Remove the stale git lock — do this before anything else.**
      ```
      rm -f ~/Developer/weft/.git/index.lock
      ```
      0 bytes, dated **Aug 12 11:48**, left by our own 08-12 run. Still present on 2026-08-16,
      **~96 hours old**. **Fifth consecutive run reporting it.** The sandbox cannot delete it —
      the mount refuses a cross-user unlink even though our own uid owns the file.
      **Note: the push happened anyway**, so the lock was never the reason nothing shipped —
      that inference (recorded on 08-14 and 08-15) was wrong. It is still worth clearing, but it
      is now housekeeping, not a blocker.

- [x] ~~🔴 **Push three days of finished work.**~~ **SHIPPED 2026-08-16.** `origin/main` on
      GitHub is now **`67e587c`** — the tip of `seo/2026-08-15`, carrying all five SEO commits.
      Verified by the one-second check rather than assumed: **`https://getweft.xyz/favicon.ico`
      returns 200** (it was 404 on 08-14 and 08-15). `check-live-urls.sh`: 15/15 200, no redirects.
      ⚠️ **The owner's *local* `main` is stale at `469be0b`** — their checkout has not been fetched
      since. Base new branches on **GitHub's** `main`, and do not trust `origin/main` as read from
      inside the mounted checkout.

- [x] ~~Verify getweft.xyz in GSC + submit sitemap.~~ **Both resolved 2026-08-12.** It was
      verified all along under the second Google account (`/u/1/`); the sitemap was genuinely
      missing and is now submitted.
- [ ] 🟢 **Sitemap: the FILE IS FINE. Stop debugging it.** Settled 2026-08-16 by external
      evidence: **Bing Webmaster Tools reads the identical file with Status `Success`, 15 URLs
      discovered, 0 errors, 0 warnings** (last crawl 8/7/2026). A second search engine parsing it
      cleanly ends the file-defect hypothesis that four runs spent time on.

      Sandbox checks concur and are now redundant: no BOM, strict XML parse OK, 15 `<loc>`, no
      illegal control bytes, no non-ASCII, `application/xml`, correct encoding negotiation.

      **Two reading errors to not repeat:**
      1. The GSC Sitemaps **list view** shows `Last read` **blank**; the **drill-down page** shows
         **`Last read: 8/14/26`** with *"Sitemap could not be read."* Google fetched it and failed
         to parse. Prior runs read the blank column as "never fetched." **Open the drill-down.**
      2. **URL Inspection → TEST LIVE URL on the sitemap URL itself** (first done 08-16) returns
         **"URL is available to Google."** Google's own infrastructure fetches it fine right now.

      **Delete-and-re-add executed 2026-08-16** — the 08-15 trigger fired. ("Remove sitemap" lives
      on the **drill-down** `⋮` menu; the list-row kebab has no delete.) Re-added immediately:
      *"Sitemap submitted successfully"*, Submitted = Aug 16. Status still read `Couldn't fetch`
      seconds later, which is too early to mean anything.
      🔴 **Verdict due 2026-08-18.** If the fresh record still shows no `Last read` in the
      drill-down by then, **accept it and move on** — discovery must come from links and internal
      crawling, exactly as it already does on Bing. **Do not delete-and-re-add again;** the lever
      is spent and produced no new information.

- [x] ~~Root cause of the low page count~~ — **found 2026-08-12: 3 orphan pages and a homepage
      that linked only 5 content pages, which is exactly the 5 URLs GSC knows.** Fixed; `/vs`
      now has 7 inbound links, `/press` 14, `/52-weeks` 7.
- [ ] **Get the indexed count off 1.** Google knows 5 of 15 URLs and indexes 1. Watch discovered
      pages after the sitemap is processed.
- [x] ~~"Page with redirect" (1)~~ — **found and fixed 2026-08-12.** Sitemap + canonical +
      hreflang + og:url all named `/vs/`, which 308s to `/vs` under `trailingSlash: false`.
      Also fixed a phantom `/blog/` breadcrumb pointing at a 404. Re-check GSC in a few days to
      confirm the exclusion clears.
- [x] ~~**Post-deploy check that every sitemap URL returns 200.**~~ Run 2026-08-13:
      **15/15 return 200**, zero redirects; the `/vs/` 308 is confirmed gone from production.
      Keep running this every deploy — it is ten seconds and it caught two real bugs on 08-12.
      *Gotcha:* write the URL list to a fresh `mktemp -d`, not a fixed `/tmp` path. A previous
      run's file survived a failed write and produced a convincing false positive this run.
- [x] ~~"Alternate page with proper canonical" (2)~~ — identified 2026-08-12: an AppAgg referral
      URL (benign) and `?q={search_term_string}` from a bogus `SearchAction` in the homepage
      schema. The site has no search; the block is removed. Should clear on re-crawl.
- [x] ~~"Page with redirect" (1)~~ — it is `http://getweft.xyz/` → HTTPS. **Normal. Do not
      "fix" it and do not run Validate Fix expecting it to clear.**
- [x] ~~**Request indexing on `/` and `/vs` — AFTER the current fixes deploy.**~~ **Done
      2026-08-16, and went far wider than planned.** The deploy landed, so this unblocked. **Nine
      pages** were pushed into Google's priority crawl queue: `/vs/clay`, `/vs`, `/vs/dex`,
      `/vs/notion`, `/vs/folk`, `/blog/why-another-personal-crm`, `/52-weeks`, `/about`, `/press`.
      All nine returned *"Indexing requested — URL was added to a priority crawl queue."*

      **Every one of them first reported "URL is unknown to Google"**, with `Last crawl: N/A`,
      `Sitemaps: No referring sitemaps detected` and `Referring page: None detected`. That is
      page-by-page proof the discovery failure is **total**. `/` was skipped (already the one
      indexed page); `/support`, `/feedback`, `/feature-requests`, `/privacy`, `/terms` skipped as
      low value.

      *Gotchas for next time:* the inspection box is a controlled React input — `form_input` does
      not take and a post-modal click does not focus it; **`triple_click` then `type` with a
      trailing newline** works. The "Indexing requested" dialog is **modal** and `Escape` does not
      close it — click **Dismiss** first, or the next click hits `REQUEST AGAIN` and burns quota.
- [x] ~~Find the 3 Reddit threads linking to getweft.xyz.~~ **Found 2026-08-13, and they are
      ours.** Two self-posts by `u/Cold-Tear-968`: r/apps (**1 upvote, 0 comments**) and
      r/sideprojects. There is **no** unprompted third-party thread. LAUNCH-KIT §5 is a cold
      start. The 1-upvote result on r/apps is also a verdict on that copy — rewrite before
      reusing it.
- [ ] **Investigate the remaining exclusion reason** once more URLs are discovered: 2 "Alternate page
      with proper canonical" (probably the en/ja hreflang pairs — likely benign), 1 "Page with
      redirect", 1 "Crawled - currently not indexed" (the meaningful one: a quality/authority
      signal, not a technical fault).
- [x] ~~**Sign in to Bing Webmaster Tools and add the site.**~~ 🔴 **IT WAS ALREADY DONE —
      this item was wrong for five runs.** Opened Bing 2026-08-16: `getweft.xyz` is a live
      property and has been since at least **2026-08-05**, with the sitemap submitted and crawled.
      The 08-11 run loaded Bing once, hit a signed-out landing page, wrote "not signed in," and
      four later runs copied that forward. **Same error class as the GSC `/u/0/` vs `/u/1/`
      mistake: a signed-out page is evidence about the browser session, not about whether the
      property exists.** Re-check adverse findings before inheriting them.

      **Current Bing state (2026-08-16):** sitemap `Success`, **15 URLs discovered**, 0 errors.
      Search Performance **0 clicks / 0 impressions**. Site Explorer → Indexed URLs:
      **"No data available"** — so Bing has discovered all 15 and **indexed 0**. Discovery works
      there; the authority problem is identical to Google's.

- [x] ~~**The 20% redirect share in Crawl Stats.**~~ **Found and fixed 2026-08-14.** 44 links
      across 6 pages pointed at `index.html`, which 308s to `/` under `cleanUrls` +
      `trailingSlash: false`. A fifth of Google's crawl budget was spent on a redirect we aimed
      it at. All 298 internal hrefs are now root-absolute. **Measurable prediction: after this
      deploys, the 301 share should fall well below 20% and Discovery should rise off 2%.**
      Check Crawl Stats a few days post-deploy — if it does not move, the diagnosis was wrong.
      **Still unverifiable on 2026-08-15: the fix has not deployed, so 301 remains 21% and
      Discovery 2%.** The prediction stands untested until the push happens.

- [ ] 🟡 **Crawl rate is falling.** Total requests over the trailing 90 days went **495 (08-14)
      → 454 (08-15)** — same window length, ~8% fewer. Hosts report "No problems" and response
      time is 259 ms, so this is not a health problem; with Discovery stuck at 2% it reads as
      Google gradually losing interest in a site where it never finds anything new. Watch this
      number each run. It should recover after the unpushed fixes deploy; if it keeps falling
      *after* a deploy, that is a real signal and not noise.

- [ ] 🟡 **`www.getweft.xyz` has no DNS record.** Found 2026-08-16: `dig +short www.getweft.xyz`
      returns nothing and `curl` reports "Could not resolve host". Not a sandbox artifact — plain
      DNS resolution works fine there. This plausibly explains the **"DNS error <1%"** line in the
      08-14 Crawl Stats read, since a `sc-domain` property makes Google try `www` too. **Impact is
      small and it is NOT a cause of the indexing problem.** A `www` CNAME to the apex would
      silence it. DNS is the owner's to change.

- [x] ~~Root `/favicon.ico` 404~~ — **fixed 2026-08-14** with a Vercel rewrite to
      `/assets/favicon.ico`. The HTML always pointed at the asset path, but browsers and crawlers
      request the root path by convention.

- [x] 🚫 ~~**`/app-ads.txt` 404**~~ — **declined 2026-08-14, CONFIRMED CLOSED 2026-08-15. Do not
      reopen.** The 08-15 run read "By Googlebot type" for the first time and found **AdsBot is
      34% of all crawl requests** — a much larger share than the earlier note implied, which is
      why it deserved one proper check rather than a reflex. Checked: crawl budget only binds on
      large sites, and at ~5 requests/day this site is orders of magnitude below any budget, so
      the 404s cost nothing. Google states a missing `app-ads.txt` does not affect Search, and
      Weft sells no ads, so the file would assert nothing. **Settled. Future runs: stop
      re-discovering this.**

- [ ] ❓ **Owner decision: the `ja` hreflang points at pages that serve English.** Seven pages
      declare `hreflang="ja"` → `?lang=ja`, but that URL returns **byte-identical English HTML**
      (67,046 bytes, zero CJK, `<html lang="en">`, canonical back to the English URL). The i18n
      layer is client-side, so a crawler never sees Japanese. Two options, and this is a product
      call, not an SEO one:
      **(a)** drop the `ja` annotations until Japanese is server-rendered — honest today, loses
      nothing real, stops Google crawling 7 duplicate URLs;
      **(b)** server-render the Japanese pages — the i18n data already exists in `i18n/ja.json`.
      Deliberately not changed by the agent. Low urgency: Google is handling the duplicates
      correctly and no real page is blocked.

- [x] ~~`vs/notion.html` missing `x-default`~~ — **fixed 2026-08-14.** It declared `hreflang="en"`
      alone among the five `/vs` pages.

## Now the main lever — brand SERP and links

- [ ] **Retarget off the bare brand term.** Position 12 on `weft app`, but the 2026-08-13 SERP
      read shows **five-plus live products named Weft** — `getweft.app` (wardrobe app),
      `letsweft.com` (Scrumban), Weft.ai, Weft: Mind Maps, WEFT FM, Cityweft. Top-3 there is not
      the cheap win it was recorded as. **Track `weft personal CRM` / `weft journal app` instead**
      and watch those in the GSC query table.
- [ ] **`getweft.app` is a different live product one TLD from our domain.** Standing brand-
      confusion risk. Nothing to do technically, but worth the owner knowing; it also argues for
      always writing the full name "Weft: Personal CRM Journal" in directory listings and press.
- [ ] 🟡 **Ask the owner about the Instagram channel.** `weft.stay.close` plus a stream of creator
      posts (`itsalexalexander` 180+ likes, `heartfelt_writing_journey` 400+, `friendshipforadults`,
      `after5co`, `journalbyalina`, `thetinywisdom`…) all ending "Free on the App Store —
      getweft.xyz". **This log had no record of it.** Instagram links are `nofollow` so they will
      not move GSC, but it means distribution is running. Is it paid UGC, a creator programme, or
      organic? If it is driving installs and still yielding **0 ratings**, the bottleneck is the
      in-app review ask, not reach.

## Next up (agent-executable once the above unblocks)

- [ ] AlternativeTo listing — copy is written and ready in LAUNCH-KIT §1.
- [ ] crm.org correction email — copy ready in LAUNCH-KIT §3. Their roundup still says Clay.
      Now doubly worth sending, since we have verified the current Mesh facts ourselves.
- [ ] SaaSHub + Indie Hackers product listings.
- [ ] Indie iOS press, one at a time, with promo codes.

## Deliberately held back

- [ ] **Show HN and Product Hunt.** Both are one-shot. Do not fire until GSC is verified and the
      site is indexed, or most of the compounding benefit is wasted.

## Maintenance

- [x] ~~Re-verify `/vs/notion` claims against notion.so/pricing.~~ **Done 2026-08-12** —
      Free $0, Plus $10/member/mo, Business $20. Page claims are correct; no edit needed.
- [x] ~~Re-verify App Store rating count directly.~~ **Done 2026-08-12** — iTunes Lookup API
      returns `userRatingCount: 0`. Confirmed, not carried forward.
- [ ] **Still 0 ratings at ~2.7 months.** Worth its own decision: an in-app review prompt after a
      few weeks of use is the standard fix, but it touches the iOS source and needs the owner's
      say-so. Ratings are also an App Store *search* ranking input, which is a separate discovery
      channel from the website and not blocked on any of the SEO work.
- [x] ~~Confirm the IndexNow key file matches what `indexnow.sh` sends.~~ **Verified
      2026-08-15.** `https://getweft.xyz/0325d2ef1f3c51e28992f5b343647609.txt` returns 200 and
      its body is exactly the key the script sends. Mechanism is sound.
- [ ] Competitor re-verification is due every ~30 days. Next: **2026-09-10**.
      Watch specifically: Mesh pricing (post-Automattic, likely to move), Dex annual pricing
      ambiguity, Folk tier renames. All four re-verified 2026-08-12; next due **2026-09-11**.
- [x] ~~Re-check the App Store `trackName` each run.~~ Checked 2026-08-13: unchanged at
      `Weft: Personal CRM Journal`. **But the URL slug moved** — `weft-stay-close` now **301s** to
      `weft-personal-crm-journal`. All 17 site links updated this run. Keep checking both fields.
- [ ] **Still 0 App Store ratings.** `userRatingCount: 0`, re-confirmed 2026-08-13. See the
      Instagram item — if that channel is driving installs, this is an in-app-prompt problem and
      it touches the iOS source, so it needs the owner's say-so.

## Tooling

- [x] ~~`indexnow.sh` takes no arguments.~~ **Rewritten 2026-08-15.** It had been ignoring its
      documented arguments and POSTing a **hardcoded list of 10 URLs on every run** — the exact
      key-throttling behaviour the runbook warns against, inside the tool meant to prevent it.
      The list had also drifted, missing 5 of the site's 15 URLs (`/vs`, `/vs/notion`,
      `/52-weeks`, `/press`, `/support`). Now argument-driven, rejects non-`/` paths, and
      **pre-checks that every path returns 200 before submitting** — a 404 or redirect in an
      IndexNow payload is worse than no ping. `--all` reads the live sitemap instead of a literal.
- [x] ~~Automate the post-deploy 200 check.~~ **`marketing/scripts/check-live-urls.sh`, added
      2026-08-15.** Fresh `mktemp -d` (the false-positive gotcha) and deliberately no `curl -L`,
      so a redirect reports as a redirect. Ran clean: 15/15 200. **Run this after every deploy.**
- [ ] `marketing/scripts/build_page.py` — referenced by the run procedure, does not exist.
      Needed so new pages stop being hand-copied shells. *Low priority: the right number of new
      pages is currently zero, so nothing is blocked on this.*
- [ ] `marketing/scripts/update_sitemap.py` — same. Must preserve `xhtml:link hreflang`
      alternates for every URL.

## Process — read this before running again

**2026-08-16 changed the picture.** The push landed, so the six-run stalemate is broken and the
"pause the daily run" recommendation from 08-15 is **withdrawn** — there is now something real to
measure for the next few days.

**Two premises inherited across multiple runs turned out to be false**, both disproved by simply
looking again:

| Believed | Actually |
|---|---|
| Bing was never set up (5 runs) | Live property since ~Aug 5, sitemap crawled |
| The sitemap file is broken (4 runs) | Bing parses it perfectly — 15 URLs, 0 errors |

Both came from a single adverse observation that was never re-tested. **The standing lesson —
now with three instances, counting the GSC `/u/0/` mistake — is: re-verify a blocking negative
before building a run's plan on it.**

**What actually matters now, in order:**

1. **Watch the indexed count.** Nine pages are in Google's priority crawl queue as of 08-16 and
   the site's internal links were fixed site-wide in the same deploy. If *Indexed* does not move
   off **1** within about a week, the problem is authority, not plumbing, and no further on-site
   work will help.
2. **Links. This is the whole remaining story.** 33 external links from 3 domains, and **zero are
   third-party** (28 Apple, 3 our own Reddit self-posts, 2 appagg). Everything in `LAUNCH-KIT.md`
   is owner-gated — creating accounts, sending mail as the owner, posting publicly — and has been
   untouched for six runs.
3. `rm -f ~/Developer/weft/.git/index.lock` — housekeeping now, not a blocker.

**Do not publish new content** while nine pages sit unindexed in a crawl queue. Adding a tenth
page dilutes the exact signal we just asked Google to evaluate.

## Competitive watch

- [ ] **trywend.io is executing this playbook and ranking for it.** Live and indexed as of
      2026-08-12: "What Happened to Clay (clay.earth)? Clay Is Now Mesh", "Mesh (formerly Clay)
      Alternatives in 2026", "Wend vs Mesh, formerly Clay (2026)". Dex ranks `/blog/mesh-review/`.
      The rebrand-intent window is real but is being taken while Weft is invisible. Argues for
      urgency on verification and links — **not** for writing more pages.
