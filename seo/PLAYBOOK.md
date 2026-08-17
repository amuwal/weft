# Weft SEO Playbook

The strategy file. Read this first, every run. It changes rarely; `LOG.md` changes daily.

Site: https://getweft.xyz · App Store: https://apps.apple.com/us/app/weft-stay-close/id6770074864
Goal: grow organic traffic. Long-run target 10,000 visits/day — see "Honest expectations".

---

## Diagnosis (as of 2026-08-17) — discovery is SOLVED; read the top block first

> **🟢 2026-08-17 — THE DISCOVERY PROBLEM IS SOLVED, AND THE SITEMAP WAS NEVER THE ANSWER.**
> Indexed pages went **1 → 10 in 24 hours.** All nine URLs filed through **URL Inspection →
> Request Indexing** on 08-16 now report "URL is on Google — Page is indexed." `/support`, the
> control page nobody requested, still reports "URL is not on Google." Same domain, same sitemap,
> same deploy, same internal links — the only difference is the request. **That is causal:
> Request Indexing did it. Not the sitemap, not IndexNow, not the deploy.**
>
> Google has *still* never successfully read the sitemap, and it did not matter.
>
> **Two standing corollaries:**
> 1. **Request Indexing is the discovery mechanism on this site.** When a page is genuinely new
>    or genuinely changed, file it. Do not wait on the sitemap and do not debug the sitemap.
> 2. **The remaining problem is authority, not discovery.** Ten indexed pages, zero third-party
>    links, position ~12 on the site's own brand name. Only links move that, and none of the
>    link work is agent-executable.
>
> ⚠️ **The Page indexing report lags URL Inspection by 2–3 days.** On 08-17 it still read
> "Indexed 1" while inspection showed ten. Trust inspection; treat the aggregate report as history.
>
> **Correction notice — now three separate false premises, all found the same way.** Each was
> a blocking negative that got recorded once and copied forward without re-testing.
>
> | Believed | For how long | Actually | Disproved |
> |---|---|---|---|
> | Site not indexed / not verified in GSC | 08-10 → 08-11 | Verified all along, under `/u/1/` | 08-12 |
> | Zero referring domains | 08-10 → 08-11 | 33 links from 3 domains | 08-12 |
> | **Bing Webmaster Tools never set up** | **08-11 → 08-15 (5 runs)** | **Live property since ~Aug 5** | **08-16** |
> | **The sitemap file is broken/unreadable** | **08-12 → 08-15 (4 runs)** | **Bing parses it: 15 URLs, 0 errors** | **08-16** |
> | **The sitemap is what blocks discovery** | **08-12 → 08-16 (5 runs)** | **Irrelevant — 10 pages indexed without it** | **08-17** |
> | **Bing indexes faster than Google** | **08-10 → 08-16** | **Bing has crawled 0 pages in 12 days** | **08-17** |
>
> If you are an agent resuming this work: discard any memory of "the site is invisible to Google,"
> "Bing is not set up," or "the sitemap is malformed." **Before you build a run around a blocking
> negative, spend one minute re-testing it.** Three times now, the blocker was not real.

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

**Third rule, added 2026-08-16: a blank column in a list view is not a measurement.** The GSC
Sitemaps list showed `Last read` empty for four runs and was read as "Google never fetched it."
The **drill-down page for the same sitemap** said `Last read: 8/14/26` — it had fetched and failed
to parse. **Open the detail view before concluding anything from a summary table.**

**Fourth rule, added 2026-08-16: when one engine disagrees with another about the same file,
believe the file.** Bing reads `sitemap.xml` with `Success` / 15 URLs / 0 errors. That single
external fact ended four runs of file debugging. **A second search engine is the cheapest
independent check available — use it early, not last.**

**Second rule, added 2026-08-13: never clear a crawler-access question with a spoofed
user-agent.** `getweft.xyz` sits behind **Cloudflare** in front of Vercel, and Cloudflare
classifies bots by IP and reverse DNS, not by the `User-Agent` string. `curl -A Googlebot`
from the sandbox proves nothing about what real Googlebot sees. The check that actually
settles it is **GSC → URL Inspection → TEST LIVE URL**, which fetches from Google's own
infrastructure.

### What actually follows

The problem was never "Google does not know this site exists." It is:

- **Discovery — worse than "10 of 15 undiscovered," and now measured page by page.** On
  2026-08-16 every page inspected individually returned **"URL is unknown to Google"** with
  `Last crawl: N/A`, `No referring sitemaps detected` and `Referring page: None detected` —
  `/vs`, `/vs/clay`, `/vs/dex`, `/vs/folk`, `/vs/notion`, `/blog/why-another-personal-crm`,
  `/52-weeks`, `/about`, `/press`. The failure is **total**, not partial. Two causes, both now
  addressed: the sitemap never delivered discovery on Google's side, and internal links were
  broken until the 08-16 deploy. All nine were manually pushed into the priority crawl queue.
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
- **No authority** — as of 08-17, **10 indexed pages and still 0 third-party referring domains**
  (33 external links: 28 Apple, 3 our own Reddit self-posts, 2 appagg). Indexing was the
  bottleneck; it no longer is. "Crawled - currently not indexed" is Google saying it saw a page
  and did not think it worth keeping. More pages will not fix that; external signals will.

## Priority order

1. ~~Verify GSC + submit the sitemap.~~ **Done** (08-12).
2. ~~Bing Webmaster Tools.~~ **It was already set up** — confirmed 08-16. Property live since
   ~Aug 5; sitemap `Success`, 15 URLs discovered, 0 errors. Bing has indexed **0** of them.
3. ~~Ship the pending fixes.~~ **Done 08-16** — `origin/main` = `67e587c`, favicon 200, 15/15 live.
4. ~~Watch the indexed count.~~ **ANSWERED 08-17: 1 → 10.** All nine requested pages indexed;
   the unrequested control `/support` is not. Plumbing was never the constraint. **Request
   Indexing is the discovery mechanism here** — use it deliberately for genuinely new or
   genuinely changed pages.
5. **🔴 Links and distribution — now the ONLY lever left.** Work `LAUNCH-KIT.md` top-down. Every
   on-site action an agent can take has been taken. Ten indexed pages with zero third-party links
   still rank ~12 for their own brand name. Every item is owner-gated; untouched for seven runs.
6. **Keep existing pages factually correct.** Competitor facts decay fast in this category.
7. **Content last, and still zero — but for a new reason.** The nine freshly indexed pages have
   not yet earned a single impression. Measure how they perform before writing a tenth.

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

- **Brand search** ("Weft personal CRM") — partly working: 97 impressions in 90 days at position
  11.7. But see the crowded-name finding above: top-3 on the bare word `weft` is **not** the cheap
  win it was recorded as, because five other products carry the name. Qualified brand terms are
  the realistic target.
- **Generic high-intent terms** ("personal CRM iOS") — 6-12 months minimum against Dex and Mesh,
  who have years of links and reviews.
- **"Bing indexes far faster than Google" — measured FALSE for this site on 2026-08-17.** Google
  went 1 → 10 indexed pages in 24 hours off Request Indexing. Bing has had a cleanly parsed
  sitemap since Aug 5, received all 15 URLs via IndexNow on Aug 16, and has **crawled zero pages**
  — its own URL Inspection reads "Discovered but not crawled." The AI-surfaces thesis may still be
  right about *value*, but it is wrong about *speed*, and no run should assume Bing is the quick
  path to first traffic. `llms.txt` and the FAQ JSON-LD are in place regardless. 10 URLs were
  submitted through Bing URL Submission on 08-17 — that experiment is still open.

Report flat and down days plainly. Distinguish a one-off spike (a launch, a link) from the
underlying trend.
