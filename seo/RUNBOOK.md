# Runbook — the daily procedure

## Every run, in order

0. **Before any analysis, find the real head of this work.** It is usually **not** GitHub. While
   pushes are blocked, finished branches live only in the owner's connected checkout. A run that
   clones GitHub and starts diagnosing will re-derive findings that were made and fixed days ago —
   this happened on 2026-08-14, which independently re-found the `SearchAction` and schemeless-href
   bugs that 08-13 had already fixed.

   ```
   ls /sessions/<session>/mnt/weft/.git/refs/heads/seo/
   git clone -q --no-checkout /sessions/<session>/mnt/weft /tmp/owner && cd /tmp/owner
   git log --oneline origin/main..refs/remotes/origin/seo/<latest>
   ```

   Build today's branch on the newest local `seo/*` branch, not on `origin/main`.

   ⚠️ **The owner's local refs go stale.** On 2026-08-16 their local `main` was `469be0b` while
   **GitHub's `main` was `67e587c`** — they had not fetched since the push. A clone of the mounted
   checkout therefore branches from four-day-old code. **Compare the mounted checkout against a
   fresh GitHub clone and branch from whichever is genuinely newer.**
   Then check the lock (it blocks the owner, not you) and report it if present:
   ```
   ls -la /sessions/<session>/mnt/weft/.git/index.lock
   ```


1. **Read GSC first — it is the ground truth.** Through the owner's logged-in Chrome
   (`mcp__claude-in-chrome__*`, load via ToolSearch). **The property lives under the SECOND
   Google account: use `/u/1/` in every URL.** `/u/0/` returns "you do not have access" and has
   already caused one false "not verified" conclusion.

   - Page indexing: `https://search.google.com/u/1/search-console/index?resource_id=sc-domain%3Agetweft.xyz&hl=en`
   - Performance:   `.../u/1/search-console/performance/search-analytics?resource_id=...&num_of_days=90`
   - Sitemaps:      `.../u/1/search-console/sitemaps?resource_id=...`

   Append `&hl=en` — the account's default UI language is Japanese.
   Record indexed count, not-indexed count + reasons, impressions, clicks, CTR, position, and
   sitemap status. If the bridge is down, write "blind" — never invent numbers, and never
   substitute a `WebSearch` result for a GSC number.

   ⚠️ **On the Sitemaps report, always click through to the sitemap's own page.** The list view
   leaves `Last read` blank even when a read happened; the drill-down shows the real date and the
   real error string. Four runs misdiagnosed this. "Remove sitemap" also lives only on the
   drill-down `⋮` menu.

1b. **Read Bing Webmaster Tools too — it is set up and it is the cheapest second opinion.**
   `https://www.bing.com/webmasters/home` (the owner is signed in; the page takes ~20s to render,
   do not conclude "signed out" from an early screenshot). Check **Sitemaps** (status, URLs
   discovered) and **Site Explorer → Indexed URLs**.

   As of 2026-08-16: sitemap `Success`, **15 URLs discovered, 0 errors**; Site Explorer
   **"No data available"** — discovered 15, indexed 0; 0 clicks / 0 impressions.

   **Bing is the control experiment.** When Google reports a problem with a file, check whether
   Bing reports the same problem. On 08-16 it did not, which is what proved `sitemap.xml` was
   never the fault.

1b. **URL Inspection: one URL per round trip, and verify the header.** Added 2026-08-17 after a
   near-miss. Batching four inspections with short waits returned, for every one of them, the
   *previous* URL's data under the new URL's header — `/vs` came back carrying `/vs/clay`'s
   canonical, which would have been logged as a canonical bug and "fixed." The GSC SPA swaps the
   header before the detail panel. **Wait ≥15s and confirm the URL printed in the page header
   matches what you typed before recording any verdict.**

   Filing a request: **`triple_click` the box, then `type` the URL with a trailing newline**
   (it is a controlled React input; `form_input` does not take). The confirmation dialog is
   **modal** — click **Dismiss**, or the next click lands on `REQUEST AGAIN` and burns quota.

1c. **Request Indexing is the discovery mechanism on this site — the sitemap is not.** Proven
   2026-08-17: nine requested pages indexed within 24h, the unrequested control did not. When a
   page is genuinely new or genuinely changed, file it through URL Inspection. Do not wait on
   the sitemap, and do not debug the sitemap; that investigation is closed.

   Bing has the same feature (URL Inspection → **Request indexing**, ~100 URLs/day) and it is
   **not** the same thing as an IndexNow ping — on 08-17 Bing showed URLs as IndexNow-received
   *and* "Discovered but not crawled." Its dialog carries the same two hazards: verify the URL
   inside the dialog before clicking Submit (a mistyped entry silently re-fires the previous
   URL — one duplicate was caught and cancelled), and the window can resize mid-session, moving
   the Submit button.

2. **Do NOT use `WebSearch` for anything requiring operator precision.** It honours **neither
   `site:` nor quoted exact phrases.** The `site:` failure fooled three runs into "not indexed."
   The exact-phrase failure was demonstrated on 2026-08-17: a `"..."` query returned a page that
   could not contain the phrase. It is fine for discovering that external pages exist on a topic,
   and for competitor facts — never for index state, ranking, or presence/absence of a page.

3. **Work `LAUNCH-KIT.md` top-down.** Log what you actually submitted and what came back.

4. **Fix anything factually wrong.** Re-verify any competitor claim older than ~30 days against
   the competitor's own page.

5. **Only then, content.** Ceiling 1-2 new pages/day; usually zero while unindexed.

## Requesting indexing (the lever that bypasses a broken sitemap)

When pages are undiscovered and the sitemap is not delivering, **URL Inspection → Request
Indexing** puts a URL straight into Google's priority crawl queue. Nine pages were queued this way
on 2026-08-16. Quota is roughly 10-12/day per property, so spend it on pages with real content.

**Only do this after a deploy that actually changed the pages** — requesting a re-crawl of
unchanged pages wastes quota and tells Google nothing new.

The UI is fiddly; this recipe works:

1. **`triple_click`** the inspection box at the top, then **`type` the URL with a trailing
   newline.** Do not use `form_input` — the box is a controlled React input and ignores a
   programmatic value set. A plain click straight after closing a dialog does not focus it either.
2. Wait ~10s for the inspection to resolve, and **check the URL shown under the header** before
   clicking anything.
3. Click **REQUEST INDEXING**, then wait ~25-30s through the "Testing if live URL can be indexed"
   modal until **"Indexing requested"** appears.
4. **Click `Dismiss`.** That dialog is modal and **`Escape` does not close it.** If you skip this,
   your next click lands on `REQUEST AGAIN` and re-submits the page you just did. That burned two
   requests on 08-16.

## Shipping

```bash
git checkout -b seo/$(date +%F)
# ... changes in marketing/ ...
git add -A && git commit -m "SEO: <what and why>"
git push -u origin seo/$(date +%F)   # then merge to main; Vercel auto-deploys from marketing/
```

After merging, always:
```bash
sh marketing/scripts/check-live-urls.sh              # every sitemap URL must be a clean 200
```

Then, if pages changed:
```bash
sh marketing/scripts/indexnow.sh /vs/clay /vs/dex    # ONLY changed paths
```
As of 2026-08-15 `indexnow.sh` actually honours these arguments — before that it silently ignored
them and pinged a hardcoded 10-URL list every time. It now also refuses to submit any path that
does not return 200.
Pinging unchanged URLs gets the key throttled. Google does not participate in IndexNow; Bing does,
and Bing is what ChatGPT search runs on.

### Pushing — read this, it is settled

**The sandbox cannot push, and that is expected. Do not try to fix it.**

The shell runs in a Linux VM that is *not* the owner's Mac — there is no `/Users`, and `~/.ssh`
is not mounted. The remote is `git@github.com:amuwal/weft.git` (SSH), so a push from the sandbox
fails on a missing key. Network is fine: `ssh -T git@github.com` reaches GitHub and returns
"Permission denied (publickey)". Confirmed 2026-08-11.

**Never ask for `.ssh` to be mounted.** Private key material should not be readable in the
sandbox. This is a deliberate boundary, not an obstacle to route around.

**The working arrangement:** the owner's checkout at `/Users/amuwal_1/Developer/weft` is
connected, and appears to bash at `/sessions/<session>/mnt/weft`. Commit into it directly, then
the owner pushes.

Safe procedure — never disturb their working tree or current branch (they are often mid-release
on `release/1.0.2` with uncommitted files):

**Never force-update or delete a ref inside the mounted checkout.** Added 2026-08-17 after doing
exactly that: an amended commit needed a force-fetch, `git update-ref -d` failed silently, and it
stranded a zero-byte `refs/heads/<branch>.lock` that the sandbox cannot delete — a second stale
lock on top of the 08-12 `index.lock`. **If a commit needs amending after it has been landed,
fetch it under a NEW branch name** (`seo/YYYY-MM-DD-final`) and tell the owner which one is real.
Cheap; leaves nothing behind.

**Clean up after yourself.** A `git fetch` (or even `git status`) run from the sandbox against the
mounted checkout can strand a zero-byte `.git/index.lock`. One from 2026-08-11 sat for ~18 hours
and blocked the owner's `git checkout` the next day. The sandbox usually **cannot delete it**
(the mount refuses cross-user unlink), so the owner has to. Always finish by checking, and if one
is present say so in the report with the exact `rm` command:

```bash
ls -la /sessions/<session>/mnt/weft/.git/index.lock 2>/dev/null && \
  echo "STALE LOCK — owner must run: rm -f ~/Developer/weft/.git/index.lock"
```

Prefer `git push origin <branch>:main` from the owner's machine over
`checkout main && merge` — it needs no index and cannot be blocked by a lock.

```bash
# work in a scratch clone
git clone /sessions/<session>/mnt/weft /tmp/work && cd /tmp/work
git checkout -b seo/$(date +%F) main
# ...edit marketing/ and seo/, commit...

# land the branch in their repo WITHOUT checking anything out
cd /sessions/<session>/mnt/weft
git fetch /tmp/work seo/$(date +%F):seo/$(date +%F)
```

`git fetch <path> branch:branch` creates the branch without touching their index, working tree or
HEAD. Verify with `git fsck` afterwards — the mount emits harmless `unable to unlink tmp_obj`
warnings during fetch; the objects themselves land fine, but check rather than assume.

Then report the two commands for the owner to run:

```bash
git push -u origin seo/YYYY-MM-DD
git checkout main && git merge --ff-only seo/YYYY-MM-DD && git push origin main
```

If the folder is ever *not* connected, fall back to
`git format-patch main --stdout > /tmp/seo-$(date +%F).patch`, deliver it, and say so at the top
of the report.

## Scripts

Present in `marketing/scripts/`: `indexnow.sh` (argument-driven since 2026-08-15),
`check-live-urls.sh` (added 2026-08-15), `iap-promo-images.py`, `inline-i18n-defaults.mjs`.

`indexnow.sh --all` was used once, on 2026-08-16, and the bar for reusing it is high: that deploy
rewrote internal links on every page, which is the documented site-wide condition. Default to
naming changed paths.

**Not present**, though earlier task notes referenced them: `build_page.py`, `update_sitemap.py`.
Either write them or edit `sitemap.xml` by hand and copy an existing page shell. If you hand-edit
the sitemap, keep the `xhtml:link hreflang` alternates intact for every URL.

## Is it actually deployed?

One-second check, and use it before believing any fix is live:

```bash
curl -s -o /dev/null -w '%{http_code}\n' https://getweft.xyz/favicon.ico
```

404 = the 2026-08-14 branch has not been pushed. 200 = it has.
**As of 2026-08-16 this returns 200** — the push landed and `origin/main` is `67e587c`. Keep the
check: it is the fastest way to tell whether the newest branch is actually live.

## Verification before reporting

- JSON-LD on every touched page still parses.
- `feed.xml` and `sitemap.xml` still parse as XML.
- Comparison tables still have 3 cells per row.
- No claim in the report that you did not actually verify this run.
