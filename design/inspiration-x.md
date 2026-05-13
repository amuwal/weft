# Inspiration — X feed pass (2026-05-13)

Captured from the user's authenticated X home feed + targeted searches via the Chrome MCP browser. Anonymized; signals only.

## Accounts the user follows that map to Linger's aesthetic

- **@leouiux (Léo)** — *most relevant.* Builds shadcn-registry components with real motion:
  - **"Smart Animate Text"** — text animation primitive (probably layout-animated character morph).
  - **"iOS switch rebuilt in React"** — `npx shadcn@latest add` style registry. Reference for our `.toggle`.
  - **"Navigation Menu driven by motion"** — single morphing viewport, layout-animated pill, direction-aware transitions. Direct reference for our `.seg` segmented control.
  - **Cool interactive square pattern for backgrounds.**
- **@Ali Bey** — "bottom tab bar with smooth animation" — reference for our Liquid Glass tab bar press behavior.
- **@Stefan** — UI for audio player with transcriptions (texture / typography polish).
- **@Codrops** — sharing @basementstudio explorations of the **HTML-in-Canvas** proposal. Not for v1, but flag for v2 if motion needs offload.
- **@FKThedesigner** — "Framer vs Claude design feud" — note: the community thinks Claude-generated UIs often look "tasteless." Strong reason to *not* default to AI-aesthetic gradient slop.
- **@FHILY** — Anime.js + Claude for animated websites. Anime.js is a lighter alternative to motion.dev when the JSX path isn't in play.
- **@Viktor Oddy** — Claude Code tutorial for interactive animated websites.
- **@Landseer Enga** — Claude Code writing test plans against live iPhone. Workflow tip for future Linger Swift build.

## Registry libraries cited in the user's feed (all shadcn-style)

1. `skiper-ui.com` — @Gur__vi
2. `pro.cult-ui.com` — @nolansym
3. `ui.unlumen.com` — @leouiux
4. `ui.watermelon.sh` — @wate…

These are the shape of how Linger's JSX components should ship if we want to be discoverable in 2026: a registry with `npx shadcn add @linger/person-card` style installs. *Future-state, not v1.*

## Themes recurring across the feed

| Theme | Signal strength | What to apply to Linger |
|---|---|---|
| Layout-animated pills / morphing tabs | high | Upgrade `.seg` segmented control: animated underline pill that morphs between Notes/Threads/Log, not just `aria-selected` swap. |
| iOS-faithful component rebuilds | high | Toggle, segmented, sheet drag already match. Add: subtle "soft drag" rubberband on chip selection. |
| Smart animated text on hero | medium | Apply line-by-line / character-by-character morph to the "A quiet place" landing hero. |
| Anti-AI-slop aesthetic | high | Already aligned — no purple gradients, no Inter, no centered hero with "magic sparkle." Confirmed via @FKThedesigner critique. |
| Audio player + transcription UI | low | Not in scope (v3 if voice notes). |
| Scroll-based zoom / parallax | low | Skip — conflicts with "calm > productive" pillar. |

## Things in the feed that confirm a Linger non-goal

- Many tweets glorify gradient-heavy, motion-maximalist AI-generated marketing sites. Linger explicitly rejects that register. The X feed reinforces that the *quiet* end of the market is undeserved.

## What was NOT in the feed (and is still genuinely useful)

- Day One / Bear / Things 3 internals — none discussed publicly; rely on `research/ui-inspiration.md`.
- iOS 26 Liquid Glass implementation details — none on this pass.

## Action items for the framework

1. ✅ Capture insights (this file).
2. Upgrade `.seg` segmented control with a layout-animated pill (motion.dev or a CSS-only translate trick).
3. Add a smart-animate-text style stagger to the "A quiet place" landing hero — word-by-word rise with serif weight breathing.
4. Defer the shadcn registry shape to v2.
