# SEO Log

Newest entries at the top. One entry per run. Be specific and be honest about flat days.

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
