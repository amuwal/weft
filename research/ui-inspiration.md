# UI/UX inspiration

The reference set for what "premium iOS app" means in 2026.

## Reference apps to study (and exact things to steal)

### Things 3 (Cultured Code)
- **Steal**: motion polish. Every transition is intentional — to-do opens into a "white piece of paper" with details tucked away until needed.
- **Steal**: hidden complexity. Date/tag/checklist fields exist but are tucked in a corner. You can use the app forever without seeing them.
- **Steal**: "wider spacing that feels a bit more relaxed" — Things 3's spacing is generous. Not Apple's default density.
- **Award**: Multiple Apple Design Awards.

### Day One Journal
- **Steal**: editor is "clean, distraction-free" — open, type, done. No formatting toolbar visible by default.
- **Steal**: automatic metadata (location, weather, music). Linger's analog: automatic touchpoint dating, smart suggestion of who you saw based on calendar/contacts.
- **Steal**: media-rich entries. Photos make notes memorable.
- **Award**: Apple Design Award winner. App of the Year.

### Bear
- **Steal**: typography is the product. Premium serif/mono pairing, generous line height.
- **Steal**: markdown that doesn't feel nerdy. Renders inline as you type.

### Linear (web/iOS)
- **Steal**: "not every element should carry equal visual weight." Use weight/color hierarchy ruthlessly.
- **Steal**: custom theme support — let users pick accent color.
- **Steal**: keyboard-first thinking, even on iOS. Quick capture should be ⌘N from anywhere.

### Tiimo (Apple iPhone App of the Year 2025)
- **Steal**: "soothing colors" — calming palette, not stimulating
- **Steal**: turning a chore into "a calming activity" — emotional positioning matters

### Apple's own iOS 26 apps (Camera, Photos, Music)
- **Steal**: Liquid Glass tab bar, content-first chrome that recedes on scroll

## iOS 26 Liquid Glass — what we MUST do

iOS 26 introduced Liquid Glass as the universal design language. As of May 2026 it's the new normal — apps that don't adopt it look dated.

Key principles:
- **Translucency with refraction** — tab bars, sheets, toolbars float over content
- **Receding chrome** — tab bar shrinks on scroll to bring focus to content
- **No mixed-era components** — if we recompile with Xcode 26, system controls become Liquid Glass. We MUST update any custom components to match or the app will feel jarringly half-old.
- **Reflections, depth, subtle motion** on touch

Libraries/refs:
- ryanashcraft/FabBar — Liquid Glass tab bar with FAB
- unionst/union-tab-view — custom Liquid Glass tab bar
- conorluddy/LiquidGlassReference — comprehensive reference doc
- swiftwithmajid.com — "Glassifying tabs in SwiftUI" tutorial

## 2026 design trends to adopt (carefully)

- **Intentional minimalism** — empty space + thin fonts is over. New minimalism uses subtle 3D, soft shadows, layered depth.
- **Spring physics everywhere** — `.spring(dampingFraction: 0.6, response: 0.4)` is the modern default. No linear or ease.
- **Contextual haptics** — every meaningful interaction has a haptic that matches the action's emotional weight (selection for navigation, success for completed, soft for create).
- **Asymmetric timing on transitions** — premium apps don't use the same animation forward and back; the "open" feels heavier than the "close."

## Trends to avoid

- **Neumorphism** — still dated.
- **Glassmorphism without iOS 26 system support** — looks fake unless you go all-in on Liquid Glass.
- **AI sparkle overload** — purple/iridescent "AI" gradients are 2024 cliché.
- **Streaks and gamification** — wrong emotional register for this app.
- **Onboarding screens with stock illustrations** — instant downgrade signal.

## Couldn't-access notes

The original instruction was to scroll the user's X feed for design inspiration. WebFetch returned HTTP 402 for x.com/home — authenticated feeds aren't reachable via this tool. I substituted with public X search results, design blog roundups, and Apple's own developer gallery. If access to the personal feed is possible via another mechanism (a saved bookmarks file, a screenshot, copy-pasted content), we can extract feed-specific signals later. Recommendation: when you next see an X post you love the design of, screenshot it into `design/inspiration-x/` and we'll review.
