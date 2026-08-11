# Backlog

Ordered by value. Move items to `LOG.md` when done.

## Blocked on the owner (highest value, cannot be agent-executed)

- [ ] **Verify getweft.xyz in Google Search Console + submit sitemap.** See LAUNCH-KIT §0a.
      Everything else is guesswork until this exists. Check the personal Gmail account first in
      case it is already verified there.
- [ ] **Sign in to Bing Webmaster Tools and add the site.** Import from GSC once 0a is done.
      Bing is the fastest path to being visible to ChatGPT search.

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

- [ ] Re-verify `/vs/notion` claims against notion.so/pricing — not checked since May 2026.
      Page currently asserts a free plan and $10/mo Plus.
- [ ] Re-verify App Store rating count directly; currently carried forward as 0 from task notes.
- [ ] Confirm the IndexNow key file at `/0325d2ef1f3c51e28992f5b343647609.txt` matches what
      `indexnow.sh` sends before relying on it.
- [ ] Competitor re-verification is due every ~30 days. Next: **2026-09-10**.
      Watch specifically: Mesh pricing (post-Automattic, likely to move), Dex annual pricing
      ambiguity, Folk tier renames.

## Missing tooling

- [ ] `marketing/scripts/build_page.py` — referenced by the run procedure, does not exist.
      Needed so new pages stop being hand-copied shells.
- [ ] `marketing/scripts/update_sitemap.py` — same. Must preserve `xhtml:link hreflang`
      alternates for every URL.
