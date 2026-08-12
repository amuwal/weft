# Weft SEO Playbook

The strategy file. Read this first, every run. It changes rarely; `LOG.md` changes daily.

Site: https://getweft.xyz · App Store: https://apps.apple.com/us/app/weft-stay-close/id6770074864
Goal: grow organic traffic. Long-run target 10,000 visits/day — see "Honest expectations".

---

## Diagnosis (as of 2026-08-13) — corrected twice, read the correction notice

> **Correction notice.** The 2026-08-10 and 08-11 versions of this file said the site was *not
> indexed* and *not verified in Google Search Console*. **Both were wrong.** They were corrected
> on 2026-08-12 by reading GSC directly. If you are an agent resuming this work, discard any
> memory of "the site is invisible to Google" — it is not, and acting on that premise wastes runs.

Measured in GSC on 2026-08-12:

1. **The domain IS verified.** Property `sc-domain:getweft.xyz` exists and is live. It sits under
   the owner's **second** Google account — the console URL is `/u/1/`, not `/u/0/`. The 08-11 run
   checked only `/u/0/` (`amitmuwal@cuon.co.jp`), found no access, and wrongly concluded the
   property had never been created. **Always check `/u/1/` before concluding anything is missing.**
2. **The site IS indexed, and ranking.** Page indexing: **1 indexed**, 4 not indexed.
   Last 90 days: **93 impressions, 5 clicks, 5.4% CTR, average position 12.1.**
3. **The sitemap had never been submitted.** Sitemaps was empty (`0 of 0`) until it was submitted
   on 2026-08-12. Google knew about **5 URLs; `sitemap.xml` lists 15.** Ten pages were never
   discovered. This is the one part of the old diagnosis that was real, and it is now fixed.
4. **Every query is brand or a typo of it.** `weft app` (16 impr), `w0yft` (7), `welft` (1).
   Zero generic category terms.
5. **NOT zero referring domains — that was the third false premise.** GSC Links, read
   2026-08-12: **33 external links from 3 domains** — `apple.com` 28 (the App Store "developer
   website" link, in several languages), **`reddit.com` 3**, `appagg.com` 2. All point at the
   homepage. **Corrected 2026-08-13: the 3 Reddit links are our own self-posts**
   (`u/Cold-Tear-968` in r/apps — 1 upvote, 0 comments — and r/sideprojects). Nobody has
   mentioned Weft on Reddit unprompted. Do not plan outreach around a warm thread that
   does not exist.
6. **Internal links: 1.** Google found exactly one internal link across the entire site. This
   independently corroborates the orphan finding and was the real constraint on crawling.
7. **0 App Store ratings** at ~2.7 months (`userRatingCount: 0`, iTunes Lookup API, 2026-08-12).

### Methodology correction — this caused the error, do not repeat it

**The `WebSearch` tool is not a reliable index check.** Three consecutive runs ran
`site:getweft.xyz`, got back generic `.xyz` TLD marketing pages, and recorded "not indexed."
Returning unrelated results for a `site:` query is the signature of a tool that **does not honour
the `site:` operator at all** — it was never evidence of anything.

**GSC is the ground truth for index state. Read it. Never report index status from `WebSearch`
alone, and never report a number that came from a tool you have not confirmed answers the
question you asked.**

**Second rule, added 2026-08-13: never clear a crawler-access question with a spoofed
user-agent.** `getweft.xyz` sits behind **Cloudflare** in front of Vercel, and Cloudflare
classifies bots by IP and reverse DNS, not by the `User-Agent` string. `curl -A Googlebot`
from the sandbox proves nothing about what real Googlebot sees. The check that actually
settles it is **GSC → URL Inspection → TEST LIVE URL**, which fetches from Google's own
infrastructure.

### What actually follows

The problem was never "Google does not know this site exists." It is:

- **Discovery** — 10 of 15 URLs were undiscovered. Just fixed via sitemap submission; the next
  runs should watch discovered-pages climb and the indexed count rise off 1.
- **A crowded brand name** — position **12 for the site's own name**. Measured on the live
  `weft app` SERP 2026-08-13, and it is worse than "contested": page one is full of **other live
  products called Weft** — `getweft.app` (a wardrobe app, **one TLD from our domain**),
  `letsweft.com` (a Scrumban task manager), Weft.ai (price tracker), Weft: Mind Maps, WEFT FM
  (community radio), Cityweft. Five-plus active same-name products.

  **So the bare term `weft app` is probably not worth fighting for** — most of its volume is not
  looking for this product, and winning it would take authority we will not have for a year.
  Target the **qualified** query instead: `weft personal CRM`, `weft journal app`. On an exact
  `"getweft.xyz"` query the site already ranks **#1** with a correct AI Overview, so the entity
  is understood; what is missing is volume on qualified terms, which is a content-and-links
  problem rather than a brand-defence one.
- **Thinness and no authority** — 1 indexed page and 0 referring domains. "Crawled - currently
  not indexed" on a URL is Google saying it saw the page and did not think it worth keeping.
  More pages will not fix that; external signals will.

## Priority order

1. ~~Verify GSC + submit the sitemap.~~ **Both done.** Verified all along (under `/u/1/`);
   sitemap submitted 2026-08-12. Now: **watch it.** Confirm the sitemap status flips from
   "Couldn't fetch" to "Success", and watch discovered pages and the indexed count (currently 1).
2. **Bing Webmaster Tools** — still not set up. Import the property from GSC, which is fast now
   that GSC is confirmed. Bing is what ChatGPT search runs on and participates in IndexNow.
3. **Links and distribution.** Work `LAUNCH-KIT.md` top-down. This is now the *main* lever:
   the site is indexed but has no authority and loses its own brand SERP.
4. **Keep existing pages factually correct.** Competitor facts decay fast in this category.
5. **Only then, content.**

---

## Hard rules

- Never publish an unverified claim about a competitor's price, platform or status. Re-verify
  anything older than ~30 days against the competitor's own page, not a third-party listicle.
- Never write a listicle where Weft wins by default. Biased ranking listicles built for AI
  ingestion have been against Google's spam policy since May 2026.
- Never buy links or citation placements. Never attempt prompt injection or "recommendation
  poisoning."
- Read a community's self-promotion rules before posting. Roughly 39% of the obvious subreddits
  ban it outright, and a ban is permanent and public.
- Never introduce client-side rendering for page content — AI crawlers don't execute JavaScript.
  The i18n layer must keep shipping English defaults inline in the HTML.
- Hard ceiling of 1-2 genuinely new pages per day. While the site is unindexed the right number
  is usually zero.
- **Ask before changing** pricing, product claims, the App Store listing, or the iOS app source
  (`Weft/`, `WeftWidget/`, `WeftTests/`, `project.yml`). The site is `marketing/`.

## Voice

Calm, plain, honest to a fault. Every comparison page says where the competitor is genuinely
better and where Weft's own approach costs you something. No superlatives, no urgency, no
"revolutionary." If a sentence would embarrass you in a year, cut it.

---

## Honest expectations

Compounding daily traffic multiplication is not achievable through SEO. Indexing alone takes
weeks, and this site is starting from zero with no links.

- **Brand search** ("Weft personal CRM") — partly working: 94 impressions in 90 days at position
  12. But see the crowded-name finding above: top-3 on the bare word `weft` is **not** the cheap
  win it was recorded as, because five other products carry the name. Qualified brand terms are
  the realistic target.
- **Generic high-intent terms** ("personal CRM iOS") — 6-12 months minimum against Dex and Mesh,
  who have years of links and reviews.
- **The realistic near-term win is AI surfaces.** ChatGPT search runs on Bing, which indexes far
  faster than Google and participates in IndexNow. `llms.txt` and the FAQ JSON-LD are already in
  place. Getting into Bing is the cheapest path to first traffic.

Report flat and down days plainly. Distinguish a one-off spike (a launch, a link) from the
underlying trend.
