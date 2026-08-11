# Launch Kit — the priority queue

Copy-paste-ready assets, ordered by value per unit of effort. Work top-down. Log every submission
in `LOG.md` with the date and what came back.

**Status legend:** `TODO` · `SUBMITTED (date)` · `LIVE (url)` · `REJECTED (reason)`

---

## 0. Blocked on the owner — do these first, they gate everything

### 0a. Google Search Console — `TODO` 🔴
Verified 2026-08-11: getweft.xyz is **not** a property under `amitmuwal@cuon.co.jp`.

1. https://search.google.com/search-console → Add property → Domain → `getweft.xyz`
2. Verify via DNS TXT at the registrar (domain property), or upload the HTML file (URL-prefix).
3. Sitemaps → submit `https://getweft.xyz/sitemap.xml`
4. URL Inspection on `https://getweft.xyz/` → Request Indexing.

*Agents must not do this.* It requires DNS/registrar access and is an account-settings change.

### 0b. Bing Webmaster Tools — `TODO` 🔴
Not signed in as of 2026-08-11. https://www.bing.com/webmasters → add `getweft.xyz` → submit
sitemap. You can import the property directly from GSC once 0a is done, which is much faster.
Bing matters disproportionately here: it indexes faster than Google and it is what ChatGPT
search reads.

### 0c. IndexNow key — `TODO`
`marketing/scripts/indexnow.sh` exists. Confirm the key file at
`https://getweft.xyz/0325d2ef1f3c51e28992f5b343647609.txt` matches the key the script sends, then
ping only changed paths. Pinging unchanged URLs gets the key throttled.

---

## 1. Directory listings — no gatekeeper, permanent, crawled

These are the cheapest real links available. None require a launch date.

### AlternativeTo — `TODO`
https://alternativeto.net/manage/new-app/ — list Weft as an alternative to Dex, Mesh, Monica,
Notion. High domain authority, and it is a common source for AI answer engines.

> **Name:** Weft — Stay Close
> **Category:** Personal CRM / Productivity · **Platform:** iOS
> **License:** Freemium
> **Short description:** A private, on-device personal CRM for iOS. Weft holds the 5-25 people you
> actually want to stay close to — not a contact database. You write one line about someone after
> you talk; the app remembers it and quietly reminds you who you have not spoken to in a while.
> There is no account, no server, and no cloud AI. Notes stay on your phone unless you turn on
> Apple's end-to-end-encrypted iCloud sync. Free for 7 people forever; $18.99/year or $39.99 once.

### Other directories — `TODO`
- **Product Hunt** — see §2, needs a scheduled date.
- **Indie Hackers** products directory — free listing, allows a founder story.
- **SaaSHub** — https://www.saashub.com/submit — mirrors AlternativeTo, separately crawled.
- **Apple's own "Made in Japan" / indie roundups** — see §4.

---

## 2. Show HN + Product Hunt — one shot each, do not waste them

Do **not** fire these until GSC is verified. If the launch lands while the site is invisible to
Google you lose most of the compounding benefit.

### Show HN — `TODO`
Post Tue-Thu, 8-10am ET. Title must start `Show HN:`. No marketing voice; HN punishes it.

> **Title:** Show HN: Weft – an on-device personal CRM for the 25 people you actually care about
>
> **Body:**
> I built this because I realised I had not called my closest friend in four months, and I only
> noticed by accident.
>
> Every personal CRM I tried was built for networkers — thousands of contacts, LinkedIn
> enrichment, pipeline views. I did not want a pipeline for my friends. I wanted somewhere to
> write "she is worried about her mum's surgery on the 14th" and be reminded of it before I next
> called her.
>
> So Weft caps you at ~25 people on purpose. There is no account and no server — I cannot see your
> notes because there is nowhere for them to go. Storage is on-device, with optional iCloud sync
> that is end-to-end encrypted by Apple. No cloud LLM anywhere in the product; I think an
> auto-generated summary of a friend defeats the point.
>
> Trade-offs, honestly: iOS 26 only, so most of the world cannot run it. No web app. No import,
> so you type the names in yourself. If you need to track 500 people, Dex or Mesh will serve you
> far better and I would rather you used them.
>
> Free for 7 people, $18.99/year or $39.99 once. Solo dev in Tokyo.
> https://getweft.xyz

### Product Hunt — `TODO`
Book a Tuesday or Wednesday. Needs: gallery images, a 60s demo video, first comment ready.
Reuse the Show HN body, softened, for the first comment.

---

## 3. The crm.org correction email — `TODO`

crm.org's personal-CRM roundup still lists Clay at clay.earth. Clay was acquired by Automattic in
June 2025 and is now **Mesh** at me.sh. A correction email is a legitimate reason to make contact
and often earns a mention.

> **Subject:** Correction for your personal CRM roundup — Clay is now Mesh
>
> Hi — small factual note on your personal CRM roundup: Clay (clay.earth) was acquired by
> Automattic in June 2025 and has rebranded to Mesh, at me.sh. The old name and domain still
> appear in the piece. Their pricing page now lists a free Personal tier up to 1,000 contacts and
> Pro at $10/month billed annually.
>
> Unrelated, and entirely up to you: I make a small iOS personal CRM called Weft
> (https://getweft.xyz) — on-device, no account, capped at ~25 people by design. It is a
> deliberately narrow tool and not a fit for every roundup, but if you ever cover the
> privacy-first end of the category I would be glad to answer questions.
>
> Either way, thanks for maintaining the list.

**Rule:** send the correction because it is true and useful. Do not condition it on coverage.

---

## 4. Indie iOS press — `TODO`

Small, personal, one at a time. Include a promo code. Never BCC a list.

- **The Sweet Setup** — https://thesweetsetup.com/contact/
- **MacStories** — app submissions; Federico Viticci and John Voorhees
- **9to5Mac** / **iMore** tips lines
- **Six Colors** (Jason Snell) — occasional indie roundups
- **Japanese Mac/iOS blogs** — an underused angle: solo dev in Tokyo, bilingual site

> **Pitch (keep it this short):**
> Weft is a personal CRM for iOS that caps you at ~25 people on purpose. No account, no server, no
> cloud AI — notes live on device, with optional E2EE iCloud sync. Built by one person in Tokyo.
> Free for 7 people; $18.99/yr or $39.99 once. Happy to send a promo code.
> https://getweft.xyz

---

## 5. Reddit — `TODO`, read the rules first

**~39% of the obvious subreddits ban self-promotion outright. A ban is permanent and public.**
Check each subreddit's rules page and posting history before writing anything.

Plausible, in rough order of tolerance: r/iosapps (has a promo thread), r/apple (very strict),
r/productivity (strict), r/digitalminimalism (topical fit, strict), r/SideProject (permissive),
r/iOSProgramming (dev-angle post, permissive).

Best approach is a story post about the *problem* that mentions the app once at the end, not a
launch announcement.
