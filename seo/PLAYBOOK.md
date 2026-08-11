# Weft SEO Playbook

The strategy file. Read this first, every run. It changes rarely; `LOG.md` changes daily.

Site: https://getweft.xyz · App Store: https://apps.apple.com/us/app/weft-stay-close/id6770074864
Goal: grow organic traffic. Long-run target 10,000 visits/day — see "Honest expectations".

---

## Diagnosis (as of 2026-08-11)

Three facts, all measured rather than assumed:

1. **The site is not indexed.** `site:getweft.xyz` returns nothing. An exact-phrase search of the
   homepage H1 returns nothing. No page anywhere on the web mentions the domain.
2. **The domain is not verified in Google Search Console.** Confirmed 2026-08-11 by loading GSC in
   the owner's browser: both `sc-domain:getweft.xyz` and `https://getweft.xyz/` return
   "You do not have access to this property" under `amitmuwal@cuon.co.jp`. That account has
   `kurogane.app` verified, so the login works — getweft.xyz was simply never added.
   *Caveat: it may be verified under a different Google account. Confirm before re-verifying.*
3. **Zero referring domains, and the App Store listing has 0 ratings after 3 months.**

Crawlers are **not** blocked — Googlebot, bingbot, GPTBot, ClaudeBot and PerplexityBot all get
HTTP 200. `robots.txt` is permissive, `sitemap.xml` is well-formed and lists 15 URLs, the homepage
H1 is server-rendered in the HTML (verified via a Googlebot user-agent fetch), and JSON-LD parses.

**So this is not an on-page SEO problem.** A 3-month-old `.xyz` domain with zero referring domains
gives Google no discovery path and no trust signal, and nothing was ever submitted to tell Google
the site exists.

### What follows from the diagnosis

- **Verification and links outrank writing new pages** until the index check flips.
- Do not respond to flat traffic numbers by publishing more pages. Pages that aren't indexed
  cannot receive traffic, and adding more does not make the existing ones index faster.
- One real inbound link from a site Google already crawls is worth more than a week of writing.

---

## Priority order

1. **Verify GSC + submit the sitemap.** The single highest-value action available, and it is
   blocked on the owner — an agent should not verify domains or touch DNS. Until this is done
   every run is flying blind and Google may not know the site exists at all.
2. **Bing Webmaster Tools.** Bing is what ChatGPT search runs on, and it participates in IndexNow.
   Not signed in as of 2026-08-11.
3. **Links and distribution.** Work `LAUNCH-KIT.md` top-down.
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

- **Brand search** ("Weft personal CRM") — reachable within weeks of indexing *plus* any external
  mention.
- **Generic high-intent terms** ("personal CRM iOS") — 6-12 months minimum against Dex and Mesh,
  who have years of links and reviews.
- **The realistic near-term win is AI surfaces.** ChatGPT search runs on Bing, which indexes far
  faster than Google and participates in IndexNow. `llms.txt` and the FAQ JSON-LD are already in
  place. Getting into Bing is the cheapest path to first traffic.

Report flat and down days plainly. Distinguish a one-off spike (a launch, a link) from the
underlying trend.
