# Handoff — Linger

> Read this first. If you're a new agent picking this up, this is your orientation.

## What this is

**Linger** is an iOS app in the planning phase as of **2026-05-13**. It's a calm, on-device, journal-like memory tool for 5–25 close people. Not a CRM, not a friendship-reminder app, not gamified. Positioning: *"Day One quality of writing + Things 3 quality of polish, but about other people."*

Tagline: **"A quiet place for the people who matter."**
Subtitle (App Store): **"Stay close to your people"**

## Status

- ✅ Market research done (competitive landscape, user pain points, UI/UX references)
- ✅ Name chosen (Linger)
- ✅ Design language drafted (color, typography, motion, haptics)
- ✅ v1 feature spec written + data model sketched
- ✅ Non-goals defined (this is the most important file — protects scope)
- ✅ Monetization decided ($3.99/mo · $24.99/yr · 7-person free tier)
- ❌ No code yet
- ❌ No icon designed
- ❌ No Figma designs (only ASCII wireframes in `design/screens.md`)
- ❌ User's personal X feed was NOT scraped (auth-only, WebFetch returned 402) — see `memory/decisions.md`

## Read in this order

1. **[README.md](README.md)** — 30-second pitch + competitive positioning
2. **[spec/non-goals.md](spec/non-goals.md)** — what Linger is NOT (read before adding features)
3. **[spec/features-v1.md](spec/features-v1.md)** — what to build
4. **[design/screens.md](design/screens.md)** — 10 screens with wireframes
5. **[design/design-language.md](design/design-language.md)** — color, type, voice
6. **[design/motion-and-haptics.md](design/motion-and-haptics.md)** — spring values, haptic vocabulary
7. **[spec/monetization.md](spec/monetization.md)** — pricing model
8. **[memory/decisions.md](memory/decisions.md)** — *why* each decision was made
9. **[memory/open-questions.md](memory/open-questions.md)** — what's not decided yet
10. **[research/](research/)** — background only; skip unless you want to challenge a decision

## If you're here to…

### …start coding the iOS app
- Stack: SwiftUI, SwiftData, CloudKit private database, StoreKit 2 native (no RevenueCat), iOS 26 deployment target
- Start with the data model in `spec/features-v1.md` and the People list + Person detail screens
- Build order is at the bottom of `spec/features-v1.md`
- Use system controls only. Adopt iOS 26 Liquid Glass — see `research/ui-inspiration.md` for the GitHub references
- Spring values are codified in `design/motion-and-haptics.md` as an `Animation` extension

### …design the app icon or Figma screens
- Brief is in `design/design-language.md` ("App icon" section)
- Direction: a single low arc — connecting line between two soft dots — sage on warm cream. Not literal (no hearts, no people, no chat bubbles)
- Tinted variant required for iOS 18+ lock screen
- Use system fonts only in mockups (New York for display, SF Pro for body, SF Pro Rounded for captions)

### …expand or change the scope
- **STOP and read `spec/non-goals.md` first.** It exists because scope creep will kill this app's calm tone.
- Common requests that should be rejected: LinkedIn integration, AI message-writing, streaks/gamification, web app, Android port, couples mode, Slack integration
- If a request feels reasonable but isn't in v1, add it to `spec/features-v2.md` with a justification

### …pick a different name
- Linger was chosen because Tend, Hearth, Kindred, Sonder, Cairn are all taken in this category — see `spec/naming.md` for the bake-off
- The fallback if Linger doesn't work: **Foyer**

### …prepare for launch
- TestFlight after v1 build (~5 weeks of build time)
- Build-in-public on X is the marketing plan
- Year-1 realistic target: $25-35K ARR; upside path needs Apple feature or PR moment
- No paid ads at launch

### …work on the X-feed gap
- The original ask included "scroll my X feed for design inspiration" — this was not possible because WebFetch can't auth into x.com
- If the user provides screenshots, drop them in `design/inspiration-x/` (folder doesn't exist yet — create it)
- Or ask the user for their X handle and try to fetch the public profile

## Hard constraints — do not violate

1. **No gamification.** No streaks, no points, no badges, no plant/garden metaphors.
2. **Privacy is the brand.** On-device default. Optional iCloud sync. No analytics SDK at launch. No cloud LLM ever.
3. **iOS-only.** No Android, no web. (Mac later is fine; Mac at launch is not.)
4. **System UI, native feel.** Premium comes from typography, motion, and haptics — NOT from custom UI fighting iOS 26 Liquid Glass.
5. **Small circle, not big network.** The product is for 5-25 people. Resist features that scale to hundreds.
6. **Verbs to avoid in UI copy:** track, manage, ping, engagement, streak, level up, optimize.

## Quick facts (for cold context)

| Field | Value |
|---|---|
| Working name | Linger |
| Subtitle | Stay close to your people |
| Category | Lifestyle (primary) / Productivity (secondary) |
| Platform | iOS 26+ iPhone (Watch + widget included) |
| Pricing | $3.99/mo · $24.99/yr · 7-day trial · 7-person free tier |
| Stack | SwiftUI, SwiftData, CloudKit, StoreKit 2 |
| Build time estimate | 4–5 weeks solo |
| Direct competitors | Dex, Clay/Mesh, Garden, Kindred, Tend variants |
| North-star app references | Day One, Things 3, Bear, Linear, Tiimo |

## What to do *right now* if you just walked in

If the user hasn't given a new instruction:
1. Ask the user what they want next: design the icon? Wireframe in Figma? Start the Xcode project? Refine the spec?
2. Do not start coding unprompted — the user might prefer to validate with mockups or a landing page first
3. Do not re-do the market research; it's done. Cite from `research/` if useful.

If the user gave a new instruction, treat the files in this folder as the authoritative spec. If you must contradict a decision in `memory/decisions.md`, *update that file* with the new decision and the reason, don't just diverge silently.
