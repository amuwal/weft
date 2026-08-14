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

2. **Do NOT use `WebSearch` as an index check.** It does not honour the `site:` operator; it
   returns generic `.xyz` pages regardless of reality, and three runs misread that as "not
   indexed." It is still fine for finding *external mentions* and competitor facts — just never
   for index state.

3. **Work `LAUNCH-KIT.md` top-down.** Log what you actually submitted and what came back.

4. **Fix anything factually wrong.** Re-verify any competitor claim older than ~30 days against
   the competitor's own page.

5. **Only then, content.** Ceiling 1-2 new pages/day; usually zero while unindexed.

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

**Not present**, though earlier task notes referenced them: `build_page.py`, `update_sitemap.py`.
Either write them or edit `sitemap.xml` by hand and copy an existing page shell. If you hand-edit
the sitemap, keep the `xhtml:link hreflang` alternates intact for every URL.

## Is it actually deployed?

One-second check, and use it before believing any fix is live:

```bash
curl -s -o /dev/null -w '%{http_code}\n' https://getweft.xyz/favicon.ico
```

404 = the 2026-08-14 branch has not been pushed. 200 = it has.

## Verification before reporting

- JSON-LD on every touched page still parses.
- `feed.xml` and `sitemap.xml` still parse as XML.
- Comparison tables still have 3 cells per row.
- No claim in the report that you did not actually verify this run.
