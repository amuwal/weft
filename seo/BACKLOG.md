# Backlog

Ordered by value. Move items to `LOG.md` when done.

## Blocked on the owner (highest value, cannot be agent-executed)

- [ ] 🔴 **Remove the stale git lock — do this before anything else.**
      `rm -f ~/Developer/weft/.git/lock`
      0 bytes, dated **Aug 12 11:48**, left by our own 08-12 run, and it blocks `checkout`,
      `merge` and `add`. **Probably the reason the two commits below were never pushed.** Second
      occurrence in three days; the sandbox cannot delete it itself.

- [ ] 🔴 **Push `55045ae` and `f33d66d` (+ today's `seo/2026-08-13`).** `origin/main` is at
      `64e0047`. The competitor corrections did land and are live. But two commits after them
      exist **only** in the owner's local checkout and were never pushed:
      `55045ae` (orphan-page fix, absolute hrefs, title/description lengths) and
      `f33d66d` (removes the bogus `SearchAction`, records backlink data).
      Confirmed unshipped 2026-08-13 by fetching the live site: `search_term_string` still
      present, footer still `vs Clay`, `href="about"` still schemeless, `/vs/clay` title still
      85 chars.
      **`55045ae` is the direct fix for GSC's "internal links = 1"**, which is the single worst
      number in the log. This is the highest-value action available and it is pure delivery —
      the work is already done.

- [x] ~~Verify getweft.xyz in GSC + submit sitemap.~~ **Both resolved 2026-08-12.** It was
      verified all along under the second Google account (`/u/1/`); the sitemap was genuinely
      missing and is now submitted.
- [ ] **Sitemap still "Couldn't fetch" at ~26h (checked 2026-08-13).** Type `Unknown`, no
      `Last read`, 0 discovered. **Server side is now definitively clear**: URL Inspection →
      TEST LIVE URL on `sitemap.xml` returns *"URL is available to Google"*, a real fetch from
      Google's own infrastructure. Inspection also reports the file as "unknown to Google",
      last crawl `N/A` — Google has never fetched it, which fits a queue delay, not a rejection.
      **Do not chase the server.** If it has not flipped by **2026-08-14**, remove the sitemap in
      GSC and re-submit.
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
- [ ] Confirm the IndexNow key file at `/0325d2ef1f3c51e28992f5b343647609.txt` matches what
      `indexnow.sh` sends before relying on it.
- [ ] Competitor re-verification is due every ~30 days. Next: **2026-09-10**.
      Watch specifically: Mesh pricing (post-Automattic, likely to move), Dex annual pricing
      ambiguity, Folk tier renames. All four re-verified 2026-08-12; next due **2026-09-11**.
- [x] ~~Re-check the App Store `trackName` each run.~~ Checked 2026-08-13: unchanged at
      `Weft: Personal CRM Journal`. **But the URL slug moved** — `weft-stay-close` now **301s** to
      `weft-personal-crm-journal`. All 17 site links updated this run. Keep checking both fields.
- [ ] **Still 0 App Store ratings.** `userRatingCount: 0`, re-confirmed 2026-08-13. See the
      Instagram item — if that channel is driving installs, this is an in-app-prompt problem and
      it touches the iOS source, so it needs the owner's say-so.

## Missing tooling

- [ ] `marketing/scripts/build_page.py` — referenced by the run procedure, does not exist.
      Needed so new pages stop being hand-copied shells.
- [ ] `marketing/scripts/update_sitemap.py` — same. Must preserve `xhtml:link hreflang`
      alternates for every URL.

## Competitive watch

- [ ] **trywend.io is executing this playbook and ranking for it.** Live and indexed as of
      2026-08-12: "What Happened to Clay (clay.earth)? Clay Is Now Mesh", "Mesh (formerly Clay)
      Alternatives in 2026", "Wend vs Mesh, formerly Clay (2026)". Dex ranks `/blog/mesh-review/`.
      The rebrand-intent window is real but is being taken while Weft is invisible. Argues for
      urgency on verification and links — **not** for writing more pages.
