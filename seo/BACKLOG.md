# Backlog

Ordered by value. Move items to `LOG.md` when done.

## Blocked on the owner (highest value, cannot be agent-executed)

- [ ] 🔴 **Push the SEO branches.** Two days of competitor corrections are written and still not
      live. `origin/main` is at `469be0b`; `seo/2026-08-11` was never pushed and `seo/2026-08-12`
      carries both days. Until this lands the site keeps publishing three false competitor claims.
      This is now the single most valuable action available, ahead of GSC verification, because
      the fix already exists and is just sitting there.

- [x] ~~Verify getweft.xyz in GSC + submit sitemap.~~ **Both resolved 2026-08-12.** It was
      verified all along under the second Google account (`/u/1/`); the sitemap was genuinely
      missing and is now submitted.
- [ ] **Confirm the sitemap fetch succeeded.** Status was "Couldn't fetch" right after submission
      with 0 discovered pages. Server side is clean (Googlebot 200, valid XML, robots allows).
      Almost certainly transient — but verify it flips to "Success" within ~48h, and chase it if
      not.
- [ ] **Get the indexed count off 1.** Google knows 5 of 15 URLs and indexes 1. Watch discovered
      pages after the sitemap is processed.
- [x] ~~"Page with redirect" (1)~~ — **found and fixed 2026-08-12.** Sitemap + canonical +
      hreflang + og:url all named `/vs/`, which 308s to `/vs` under `trailingSlash: false`.
      Also fixed a phantom `/blog/` breadcrumb pointing at a 404. Re-check GSC in a few days to
      confirm the exclusion clears.
- [ ] **Add a post-deploy check that every sitemap URL returns 200.** Both bugs above were
      invisible in GSC's summary and took ten seconds to find by fetching the sitemap URLs.
      Cheap, and it would have caught this months ago.
- [ ] **Investigate the remaining exclusion reasons** once more URLs are discovered: 2 "Alternate page
      with proper canonical" (probably the en/ja hreflang pairs — likely benign), 1 "Page with
      redirect", 1 "Crawled - currently not indexed" (the meaningful one: a quality/authority
      signal, not a technical fault).
- [ ] **Sign in to Bing Webmaster Tools and add the site.** Import from GSC once 0a is done.
      Bing is the fastest path to being visible to ChatGPT search.

## Now the main lever — brand SERP and links

- [ ] **Position 12.1 for the site's own brand name.** Should be 1-3. Contested by `weft.io`
      (logistics) and "weft" the textile term. Winnable with mentions and links, not with pages.
      This is now the clearest measurable target: watch average position on `weft app`.

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
- [ ] Re-check the App Store `trackName` each run — it changed once already (to
      "Weft: Personal CRM Journal") without the marketing copy following.

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
