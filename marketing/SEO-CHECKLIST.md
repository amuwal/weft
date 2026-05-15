# Weft — SEO Launch Checklist

Everything that's now in code, plus the off-page actions only you can do.

## ✅ On-page (already shipped)

### Technical
- `sitemap.xml` with `xhtml:link hreflang` alternates for every URL
- `robots.txt` permissive + sitemap pointer
- `site.webmanifest` (PWA installable)
- `llms.txt` (emerging standard for AI crawlers — ChatGPT search, Perplexity, Google AI Overviews)
- Per-page canonical + `og:url` + `og:type` (website/article/profile)
- Per-page `hreflang` alternates (`en`, `ja`, `x-default`)
- Full favicon set (16/32/48/180/192/512/ico/svg) + apple-touch-icon
- OG/Twitter card image (1200×630, brand-correct)
- Theme-color meta for iOS browser chrome
- Bilingual content (auto-detects from `navigator.language`)

### Content
- Title tags carry "Personal CRM" + "iOS" + brand naturally
- Meta descriptions include "Dex / Clay / Folk alternative" + key feature signals
- New `<section class="learn">` with 1000+ words of indexable copy:
  - **What "personal CRM" actually means** — captures awareness intent
  - **Who Weft is for** — six concrete personas (engineer / new parent / freelancer / introvert / adult child / template fatigue)
  - **How Weft differs from Dex, Clay, Folk** — comparison intent
  - **Why iOS-only, why iOS 26** — platform intent
- Internal anchor text is descriptive (no "click here")
- Headings hierarchical (one H1 per page, H2/H3 nested)

### Structured data (JSON-LD)
- `Organization` (Weft, Tokyo)
- `WebSite`
- `Person` (the developer) — **E-E-A-T signal**
- `MobileApplication` with `featureList`, `keywords`, three `Offer` entries (free / monthly / yearly), `creator` + `author` linked to Person
- `FAQPage` with 8 questions/answers — rich results deprecated by Google in May 2026 but **still useful for AI Overviews** (ChatGPT, Perplexity, Google SGE all extract from this)
- `BreadcrumbList` on each doc page

## 🔴 Off-page — your action items

### Day 1 (do these now)

1. **Google Search Console**
   - https://search.google.com/search-console → Add property → `https://getweft.xyz`
   - Verify via DNS TXT record (Vercel/your registrar dashboard) or HTML file upload
   - Sitemaps → submit `https://getweft.xyz/sitemap.xml`
   - This is the **single most important** SEO action you can take. Without GSC, you're blind.

2. **Bing Webmaster Tools** (Bing powers DuckDuckGo + ChatGPT search)
   - https://www.bing.com/webmasters → Sign in → Add `https://getweft.xyz`
   - Submit sitemap
   - Bonus: Bing has "IndexNow" — instant indexing — see below

3. **IndexNow** (instant indexing across Bing, Yandex, Naver)
   ```bash
   curl "https://api.indexnow.org/indexnow?url=https://getweft.xyz/&key=YOUR-KEY"
   ```
   Generate a key at https://www.bing.com/indexnow and put `{KEY}.txt` containing the key at `https://getweft.xyz/{KEY}.txt`. Then ping the API on every meaningful update. (We can wire this into a Vercel deploy hook later.)

4. **Rich Results Test** — verify our JSON-LD is parsed correctly
   - https://search.google.com/test/rich-results?url=https%3A%2F%2Fgetweft.xyz%2F
   - Should detect: MobileApplication, Organization, FAQPage, Person, WebSite

### Week 1 (build credible backlinks)

5. **Indie communities** (high domain authority, indie-friendly):
   - **Indie Hackers** — post a "Show IH" with the story
   - **Hacker News** — Show HN: Weft, a quiet personal CRM for iOS
   - **Product Hunt** — schedule a launch (book a Tuesday/Wednesday for max reach)
   - **r/iOSApps**, **r/personalCRM** subreddits
   - **Apple Hobbyist / Apple Bot subreddits** for buzz

6. **iOS app review sites** that take indie submissions:
   - The Sweet Setup (https://thesweetsetup.com/contact/)
   - MacStories app submissions
   - 9to5Mac tips
   - iMore tips
   - Federico Viticci (@viticci on X) — direct DM
   - John Voorhees (@johnvoorhees)

7. **Linklog / personal blogs**: indie iOS Twitter is small. DM 5–10 builders with calm-tech aesthetics (Sebastiaan de With, Becky Hansmeyer, Christian Selig if still around, etc.) and offer them a free Premium code.

### Week 2–4 (compounding wins)

8. **App Store Optimization (ASO)** — separate but related:
   - App Store keyword field (100 chars, hidden): `personal CRM,stay in touch,friends,family,relationships,journal,reminders,contacts,memory,Dex,Clay,Folk`
   - App preview videos in JP + EN
   - Screenshots optimized for the localized stores

9. **Cross-link the marketing site from the App Store listing** (and vice versa) — both get a small ranking boost from the association.

10. **Update `og-image.png` for any new platforms**:
    - LinkedIn prefers 1200×627
    - WhatsApp uses og:image directly — already covered

### Month 2+ (the long game)

11. **Content cadence**: one indie blog post a month wins. Topic ideas with SEO juice:
    - *"Why I built another personal CRM (and what's wrong with the existing ones)"*
    - *"5 things I cut from Weft, and why"*
    - *"How I designed the calm-tech aesthetic"*
    - *"What I learned shipping an iOS app in 8 weeks"*
    - *"Personal CRM comparison: Weft vs Dex vs Clay vs Folk"* — pure ranking play

12. **Comparison pages** (huge intent capture): `/vs/dex`, `/vs/clay`, `/vs/folk`. People search "X vs Y" before buying. These convert.

13. **Free assets** that attract backlinks:
    - Print-friendly "questions to ask the people you love" PDF
    - Weft's design tokens / color palette as a downloadable asset
    - The bilingual landing page itself is share-worthy

## 📊 Monitoring (set up week 1)

- **Google Search Console**: impressions, clicks, position, top queries
- **Vercel Analytics**: free, privacy-friendly, page-load data
- **Cloudflare Web Analytics** (free, no JS bloat): optional layer

## ⚠️ Things NOT to do

- Don't keyword-stuff. Google's NLP detects it and demotes you.
- Don't buy backlinks. They look fine for a month then tank the site.
- Don't auto-translate the site — our manual JA translation is a quality signal.
- Don't gate content behind email signup. Hurts crawlability.
- Don't add cookie banners we don't need (we collect zero data).

## Honest expectations

Brand search ("Weft personal CRM") should reach page 1 within a few weeks once Google has indexed the site and the brand has any external mentions.

Generic high-intent terms ("personal CRM iOS") will take **6–12 months minimum** to crack page 1 against Dex/Clay/Folk — they have years of backlinks, App Store reviews, and brand recognition. The compounding strategy: (a) the comparison content captures their downstream search traffic, (b) backlinks from launches accumulate, (c) AI Overviews (Google SGE, ChatGPT search) start citing Weft from the FAQ schema + llms.txt. AI surfaces are the new high-value real estate — that's where the immediate wins live.
