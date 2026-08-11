# Runbook — the daily procedure

## Every run, in order

1. **Index check first.** Use the WebSearch tool, not curl — engines block scrapers.
   - `site:getweft.xyz`
   - the exact H1: `"Remember the people you love — one line at a time"`
   Record both in `LOG.md` as an explicit line and as a row in `metrics.csv`.
   **The day this flips to real results, say so loudly** and shift the balance toward content.

2. **Try GSC + Bing Webmaster** through the owner's logged-in Chrome
   (`mcp__claude-in-chrome__*`, load via ToolSearch). Only works when their desktop is connected.
   If you cannot reach it, write "blind" in the log — never invent numbers.
   First check every time: is the domain verified and the sitemap submitted?

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

After merging, if pages changed:
```bash
sh marketing/scripts/indexnow.sh /vs/clay /vs/dex   # ONLY changed paths
```
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

Present in `marketing/scripts/`: `indexnow.sh`, `iap-promo-images.py`, `inline-i18n-defaults.mjs`.

**Not present**, though earlier task notes referenced them: `build_page.py`, `update_sitemap.py`.
Either write them or edit `sitemap.xml` by hand and copy an existing page shell. If you hand-edit
the sitemap, keep the `xhtml:link hreflang` alternates intact for every URL.

## Verification before reporting

- JSON-LD on every touched page still parses.
- `feed.xml` and `sitemap.xml` still parse as XML.
- Comparison tables still have 3 cells per row.
- No claim in the report that you did not actually verify this run.
