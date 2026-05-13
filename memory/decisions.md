# Decisions log

Decisions made during the May 13, 2026 planning pass. Future-you (or future-collaborator) can scan this to understand *why* the design is the way it is.

## 2026-05-13 — Name

**Decision**: App is named **Linger**.

**Why**: Verb-named, evocative, short, available in the exact category we're competing in. Subtitle "Stay close to your people" covers search keywords.

**Rejected**: Tend, Hearth, Kindred, Sonder — all taken in this category. Foyer, Plume, Vellum considered but Linger has stronger emotional resonance.

## 2026-05-13 — Positioning

**Decision**: Linger is a **calm, journal-like memory tool for 5–25 close people**, not a personal CRM and not a friendship reminder app.

**Why**: Two existing archetypes (heavy networker CRMs like Dex/Clay, light reminder apps like Garden/Catchup) both have well-documented gaps. The middle space — beautiful writing experience + small circle + on-device privacy — is open.

## 2026-05-13 — Privacy stance

**Decision**: Privacy-first. On-device storage by default. Optional iCloud sync. No accounts. No cloud LLM. No analytics SDK in v1.

**Why**: This is the strongest possible differentiator vs. Dex/Clay (both heavily cloud), and aligns with how a "journal about other people" should feel. Users explicitly said they don't want friend data in the cloud.

## 2026-05-13 — Free tier

**Decision**: 7-person limit on free tier. Premium $3.99/mo or $24.99/yr.

**Why**: 7 is generous enough to be useful, low enough to convert anyone with a real "circle." Pricing slot is calibrated to be below Dex ($10/mo) and above the $1.99 cheap-utility band.

## 2026-05-13 — No gamification

**Decision**: No streaks, no points, no badges, no plant/garden metaphor.

**Why**: User research shows gamification feels juvenile to adults using these tools. Tend/Garden compete on cute; Linger competes on calm. Different emotional register.

## 2026-05-13 — iOS-only, iOS-26-native

**Decision**: iPhone only at launch. Liquid Glass design language. SwiftData + CloudKit.

**Why**: Solo dev velocity. iOS users pay more. Liquid Glass is the new default and apps that don't adopt it look dated.

## 2026-05-13 — Premium feel via motion + typography, not custom UI

**Decision**: Use system controls everywhere. Premium feel comes from spring animations, generous spacing, typography (New York serif + SF Pro), contextual haptics — not from custom UI.

**Why**: Custom UI breaks the iOS 26 Liquid Glass system. Premium apps (Things 3, Day One, Bear) win by *enhancing* the native feel, not fighting it.

## 2026-05-13 — Could not access X feed (resolved later)

**Decision**: Substituted public X search and design blog research for personal X feed access.

**Why**: WebFetch returned HTTP 402 for authenticated x.com URLs. We could not scroll the user's personal X feed. The user can supplement at any time by screenshotting posts they find inspiring into `design/inspiration-x/`.

**Update (2026-05-13 evening)**: The user enabled the Claude-in-Chrome MCP. We pulled signals from the authenticated feed; results saved to `design/inspiration-x.md` and an agent memory. Strongest signal: the user follows @leouiux and the shadcn-registry motion ecosystem — layout-animated pills, iOS-faithful component rebuilds. Two upgrades applied to `web/`: layout-animated segmented pill on Person Detail, word-by-word stagger on the landing hero.

## 2026-05-13 — Stack reaffirmed: native SwiftUI

**Decision**: Build with native SwiftUI + SwiftData + CloudKit private DB + StoreKit 2. Reject Expo / React Native / Supabase as the v1 app stack. See `spec/stack.md` for the full matrix.

**Why**:
- *Brand pillar*: "On-device default. No analytics SDK. No cloud LLM ever." A Supabase Postgres breaks that promise; CloudKit private DB upholds it (E2E-encrypted on Advanced Data Protection devices, otherwise protected by Apple keys Apple cannot read).
- *iOS 26 Liquid Glass*: only SwiftUI binds `.glassEffect` natively. React Native approximations are exactly the "tasteless AI-aesthetic" the user explicitly disliked in his X feed (@FKThedesigner's Framer-vs-Claude critique).
- *Watch + Widget + Shortcuts*: WatchOS apps, WidgetKit lock-screen widgets, and App Intents are all Swift-first surfaces. v1 includes the Watch and lock-screen widget. Expo can't ship those.
- *StoreKit 2 native*: previously decided in `spec/monetization.md`. RN would force RevenueCat back in.

**On the user's existing subscriptions**:
- *Apple Developer ($99/yr)*: keep — required.
- *EAS (~$19/mo)*: cancel for Linger; useless without Expo.
- *Supabase Pro (~$25/mo)*: not used by Linger v1. Keep only if other projects justify it, or pair it with the eventual marketing-site waitlist (one table, RLS).

**How to apply**: For any new feature suggestion involving cross-platform, cloud-backed storage, or "let's add Firebase/Supabase," reject by default. Re-evaluate only if v1 has shipped, hit ≥$25K ARR, AND the user wants Android. Even then, Compose Multiplatform > Expo because the Watch/Widget gap doesn't close.
