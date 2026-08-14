# Backlog

Ordered by value. Move items to `LOG.md` when done.

## Blocked on the owner (highest value, cannot be agent-executed)

- [ ] 🔴 **Remove the stale git lock — do this before anything else.**
      ```
      rm -f ~/Developer/weft/.git/index.lock
      ```
      0 bytes, dated **Aug 12 11:48**, left by our own 08-12 run. Still present on 2026-08-15,
      **~75 hours old**. It blocks `checkout`, `merge` and `add`, and is the most likely mechanical
      reason nothing has been pushed since. **Fourth consecutive run reporting it.** The sandbox
      cannot delete it — re-attempted 2026-08-15, `rm` → "Operation not permitted"; the mount
      refuses a cross-user unlink even though our own uid owns the file.

- [ ] 🔴 **Push three days of finished work.** `origin/main` is still `64e0047`. Local-only:
      | Branch | Adds | Contains |
      |---|---|---|
      | `seo/2026-08-12` | `55045ae`, `f33d66d` | orphan-page fix, 42 absolute hrefs, title/desc lengths; removes bogus `SearchAction` |
      | `seo/2026-08-13` | `6b6a5aa` | canonical App Store slug, brand-SERP + Reddit corrections |
      | `seo/2026-08-14` | `4214ae7` | 44 `index.html` links → `/`, root favicon rewrite, `vs/notion` x-default |
      | `seo/2026-08-15` | today's commit | arg-driven `indexnow.sh` (was pinging a stale hardcoded list), new `check-live-urls.sh` |

      Use the lock-proof form, which needs no index and cannot be blocked:
      ```
      git push origin seo/2026-08-15:main
      ```
      This is pure delivery — the work is done, verified, and invisible until this runs.
      **Proof it has not shipped, measured 2026-08-15:** `https://getweft.xyz/favicon.ico`
      still returns **404**. That rewrite was committed on 08-14; a successful push makes it 200.
      Use that URL as the one-second check for whether the push landed.

- [x] ~~Verify getweft.xyz in GSC + submit sitemap.~~ **Both resolved 2026-08-12.** It was
      verified all along under the second Google account (`/u/1/`); the sitemap was genuinely
      missing and is now submitted.
- [ ] **Sitemap still "Couldn't fetch" — re-submitted 2026-08-14.** Type `Unknown`, `Last read`
      still empty, 0 discovered, 48h after the original submission. Server side is definitively
      clear (08-13 URL Inspection live test: *"URL is available to Google"*; 08-14 Crawl Stats
      host status: *"No problems"*, 491 successful requests). **Do not chase the server.**
      Re-submitted 2026-08-14 (additive, not deleted) — GSC confirmed "Sitemap submitted
      successfully" and the Submitted date moved to Aug 14.

      **2026-08-15: still `Couldn't fetch`, `Type: Unknown`, `Last read` empty, 0 discovered** —
      72h after the first submission, 24h after the re-submission. Server re-confirmed clean
      again today (`HTTP/2 200`, `application/xml`, 4,053 bytes, 15 `<loc>`, valid XML, robots
      allows and names it). **The delete-and-re-add lever was deliberately NOT pulled today** —
      the re-submission was only 24h old and deleting would have destroyed the evidence of
      whether it works. 🔴 **TRIGGER: if `Last read` is still empty on 2026-08-16, delete the
      sitemap entry and re-add it.** That is the last remaining lever; after it, escalate to
      accepting that discovery must come from links instead.

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
- [ ] **Request indexing on `/` and `/vs` — AFTER the current fixes deploy.** Doing it before
      deploy would re-cache the old pages.
- [x] ~~Find the 3 Reddit threads linking to getweft.xyz.~~ **Found 2026-08-13, and they are
      ours.** Two self-posts by `u/Cold-Tear-968`: r/apps (**1 upvote, 0 comments**) and
      r/sideprojects. There is **no** unprompted third-party thread. LAUNCH-KIT §5 is a cold
      start. The 1-upvote result on r/apps is also a verdict on that copy — rewrite before
      reusing it.
- [ ] **Investigate the remaining exclusion reason** once more URLs are discovered: 2 "Alternate page
      with proper canonical" (probably the en/ja hreflang pairs — likely benign), 1 "Page with
      redirect", 1 "Crawled - currently not indexed" (the meaningful one: a quality/authority
      signal, not a technical fault).
- [ ] **Sign in to Bing Webmaster Tools and add the site.** Import from GSC once 0a is done.
      Bing is the fastest path to being visible to ChatGPT search.

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

## 🔴 Process — read this before running again

**Five consecutive runs, five flat entries.** Each of the last four found and fixed a real
technical defect; **all four fixes are unpushed.** There is no remaining agent-findable technical
fault that is worth a daily run, and everything in `LAUNCH-KIT.md` requires creating accounts,
sending mail as the owner, or posting publicly — none of which an automated run may do.

**The project is gated on ~20 minutes of owner time, in this order:**

1. `rm -f ~/Developer/weft/.git/index.lock`
2. `git push origin seo/2026-08-15:main` — ships four days of fixes
3. Bing Webmaster Tools: sign in, import the property from GSC, submit the sitemap
4. AlternativeTo listing — copy is ready in LAUNCH-KIT §1

**Recommendation: pause the daily run, or drop it to weekly, until 1 and 2 are done.** Resume the
daily cadence when there is something new to measure. Running daily against a blocked queue
produces log entries, not traffic.

## Competitive watch

- [ ] **trywend.io is executing this playbook and ranking for it.** Live and indexed as of
      2026-08-12: "What Happened to Clay (clay.earth)? Clay Is Now Mesh", "Mesh (formerly Clay)
      Alternatives in 2026", "Wend vs Mesh, formerly Clay (2026)". Dex ranks `/blog/mesh-review/`.
      The rebrand-intent window is real but is being taken while Weft is invisible. Argues for
      urgency on verification and links — **not** for writing more pages.
