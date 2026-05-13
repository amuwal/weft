# Stack decision

> Decided **2026-05-13** after re-evaluating against existing tooling (Supabase Pro, EAS, Apple Developer account).

## Decision

**Native SwiftUI, no cross-platform shell.**

| Layer | Choice | Why this, not that |
|---|---|---|
| Language | Swift 6 | Strict concurrency. SwiftData's macros assume Swift 5.9+. Nothing else gives WatchOS + WidgetKit + StoreKit 2 in one codebase. |
| UI | SwiftUI (iOS 26 SDK) | Liquid Glass is a *first-class* SwiftUI material (`.glassEffect`, `.glassBackgroundEffect`). React Native / Expo cannot bind it. |
| Local DB | SwiftData (iOS 17+ API) | Wraps Core Data, macro-driven schema, free CloudKit mirror via `ModelConfiguration(cloudKitDatabase: .private(...))`. |
| Sync | CloudKit private database | Zero infra. End-to-end Apple. The user pays via their iCloud subscription, *we* pay nothing. Maps directly to the privacy brand pillar. |
| Payments | StoreKit 2 native + `ProductSubscription` API | Fewer moving parts than RevenueCat for a single-platform app. Less to break, no third-party dashboard, no extra cost. |
| Push (silent re-sync hint) | APNs via CloudKit subscriptions | Already wired by CloudKit. No FCM needed. |
| Watch | WatchOS 11 target, SwiftUI | Real Watch app needs to live in the same target group. Expo doesn't ship a usable Watch target. |
| Widgets | WidgetKit (Swift) | Required for the lock-screen tinted widget. Expo can't reach the system extension surface. |
| Shortcuts | App Intents framework | Voice/Shortcuts integration is one Swift macro per intent. Trivial in native, exotic in RN. |
| Analytics at launch | **None.** | Spec says no analytics SDK in v1. If we add one v2+, use TelemetryDeck (privacy-first, Swift package). |
| Marketing site / waitlist | Astro + Tailwind, on Cloudflare Pages | Plain static. Reuse the iPhone-frame HTML from `web/` as the hero. |

## What about your existing subscriptions?

You currently pay for:
- **Supabase Pro** (~$25/mo)
- **EAS** (~$19/mo)
- **Apple Developer** ($99/yr)

For Linger specifically:

- **Apple Developer**: keep — required to ship to App Store + TestFlight.
- **EAS**: **cancel for this project.** EAS only ships Expo apps. If you have an Expo project running elsewhere, keep it there. Otherwise, every cent against Linger is wasted — CI is Xcode Cloud (free up to 25 hr/mo) or Fastlane.
- **Supabase Pro**: **not used by Linger.** Reasons:
  1. **Brand pillar #1 is "on-device default."** Routing notes about your friends through a third-party Postgres breaks the most important promise.
  2. CloudKit handles all sync — for free.
  3. There is no v1 feature that needs server compute.

  But Supabase **could** be used outside the app for:
  - The **public marketing site's waitlist signup** (one table, RLS, fine).
  - **App Store Review reply automation** later.
  - A v2+ "anonymous device → device" share-snippet link feature (if we ever ship it; it's currently in `non-goals`).

  If those aren't already worth $25/mo, downgrade to free tier.

## Concretely — Day 1 setup

```bash
# Xcode 26+ from /Applications (must support iOS 26 SDK)
xcode-select -p
xcodebuild -version

mkdir -p ~/Developer/Linger && cd ~/Developer/Linger
mint install yonaskolb/xcodegen          # optional, helps keep .xcodeproj out of git
# or: open Xcode → File → New → App → "Linger", iOS, SwiftUI, Storage: SwiftData, Include Tests
```

Bundle id: `com.<your-tld>.linger`. Apple Watch + Widget Extension added immediately so the target structure is right from day 1.

## Project structure

```
Linger.xcodeproj/
LingerApp/
├── App/
│   ├── LingerApp.swift                ← @main, ModelContainer setup, CloudKit
│   └── RootView.swift                 ← TabView with Liquid Glass tab bar
├── Model/
│   ├── Person.swift                   ← @Model class, mirrors features-v1.md
│   ├── Note.swift
│   ├── Thread.swift
│   ├── Touchpoint.swift
│   └── Rhythm.swift                   ← enum Rhythm: Int, Codable
├── Features/
│   ├── Today/TodayView.swift
│   ├── People/PeopleListView.swift
│   ├── PersonDetail/PersonDetailView.swift
│   ├── AddNote/AddNoteSheet.swift
│   ├── AddPerson/AddPersonSheet.swift
│   ├── Settings/SettingsView.swift
│   └── Paywall/PaywallView.swift
├── Components/
│   ├── PersonCard.swift               ← matches web/components/PersonCard.jsx
│   ├── DotIndicator.swift
│   ├── SegmentedControl.swift         ← the morphing-pill segmented (style only — system has it now in iOS 26)
│   └── SmartText.swift                ← word-by-word stagger using PhaseAnimator
├── Design/
│   ├── Tokens.swift                   ← maps to web/css/tokens.css
│   ├── Animation+Linger.swift         ← Animation.lingerSpring etc.
│   └── Haptics.swift                  ← wraps UIImpactFeedbackGenerator
├── Services/
│   ├── ScoringService.swift           ← "who's on your mind today" rule engine
│   ├── EntitlementService.swift       ← StoreKit 2 / ProductSubscription wrapper
│   └── SyncService.swift              ← CloudKit availability + status
├── Resources/
│   ├── Assets.xcassets                ← reuse SVGs from web/assets/ as PDFs (Single Scale, Preserve Vector Data)
│   └── Localizable.xcstrings          ← strings catalog
└── Linger.entitlements                ← iCloud · CloudKit · App Sandbox · Family Sharing

LingerWatch/                           ← simple "Today's person + Saw them" tap
LingerWidget/                          ← WidgetKit, three sizes + tinted
LingerTests/                           ← Swift Testing (`#expect`)
LingerUITests/                         ← XCUITest happy path
```

## Library / SPM choices

Lean. The brand is "system controls only" — every external dep is a brand risk.

**Required:**
- *(none — everything we need ships in iOS 26)*

**Justified:**
| Package | Purpose | URL |
|---|---|---|
| swift-collections | `OrderedDictionary` for the People list section ordering | `apple/swift-collections` |
| swift-async-algorithms | `AsyncTimerSequence` for nudge scheduling | `apple/swift-async-algorithms` |

**Optional, only if a real pain point appears:**
| Package | Purpose | Caveat |
|---|---|---|
| TelemetryDeck | Privacy-first analytics, EU-hosted, no PII | Only after v1 ship. Spec says no analytics at launch. |
| Sentry-Cocoa | Crash reporting | Same — defer past v1 unless TestFlight crashes mount up. |

**Explicitly NOT using:**
- RevenueCat — StoreKit 2 + 1-platform = direct is cleaner.
- Realm / GRDB — SwiftData covers it.
- Firebase / Supabase SDKs — breaks the on-device pillar.
- Lottie — no illustrations. Native SwiftUI shapes only.
- Anything that ships its own UI components (TPPasscodeViewController, etc.) — Liquid Glass demands system controls.

## iOS 26 Liquid Glass — implementation pointers

The web framework approximates Liquid Glass; SwiftUI does it natively:

```swift
// Tab bar
TabView { … }
    .tabViewStyle(.sidebarAdaptable)        // iOS 26
    .background(.glass)                      // Liquid Glass material
    .glassEffect(.regular, in: .capsule)

// Sheet
.sheet(isPresented: $showAddNote) {
    AddNoteSheet()
        .presentationDetents([.medium, .large])
        .presentationBackground(.glass)
        .presentationCornerRadius(28)
}
```

References saved in `research/ui-inspiration.md`:
- `ryanashcraft/FabBar` — Liquid Glass tab bar with floating-action button
- `unionst/union-tab-view` — custom Liquid Glass tab bar
- `conorluddy/LiquidGlassReference` — comprehensive reference doc
- `swiftwithmajid.com` "Glassifying tabs in SwiftUI"

## StoreKit 2 — minimum viable monetization

```swift
@MainActor @Observable final class Entitlements {
    private static let groupID = "linger_premium"
    private(set) var isPremium = false
    func bootstrap() async {
        for await result in Transaction.currentEntitlements where
            result.payloadValue.subscriptionGroupID == Self.groupID {
            isPremium = result.payloadValue.revocationDate == nil
        }
    }
}
```

In App Store Connect:
- Subscription group: `linger_premium`
- Product ids: `linger_premium_monthly` ($3.99) / `linger_premium_yearly` ($24.99)
- 7-day intro offer only on yearly
- Family Sharing enabled

## Sync / privacy notes

```swift
let schema = Schema([Person.self, Note.self, Thread.self, Touchpoint.self])
let config = ModelConfiguration("Linger", schema: schema, cloudKitDatabase: .private("iCloud.com.<tld>.linger"))
let container = try ModelContainer(for: schema, configurations: [config])
```

CloudKit private DB is **end-to-end-encrypted** with the user's iCloud Advanced Data Protection key (if they have it). For everyone else it's protected by Apple's standard key, but Apple cannot read the records. No further work needed for "private by default" — this is what makes the architecture win on the brand promise.

## Testing & CI

- **Swift Testing** (`#expect`) — newer, simpler than XCTest.
- **Xcode Cloud** for the build/test/TestFlight pipeline. 25 free hours/mo on the developer plan. No EAS, no Bitrise.
- **TestFlight** beta: 100 internal testers free, 10K external via public link.

## Estimated wall-clock to v1

- Week 1: data model + SwiftData + People list + Person detail
- Week 2: Add note flow + Today scoring
- Week 3: Settings + iCloud + Widget + Watch
- Week 4: Paywall + polish + TestFlight beta
- Week 5: bug bash, App Store submission

Same 4–5 week estimate as `features-v1.md`. SwiftUI is faster for this app than RN because almost every screen maps to one stock view.

## When to revisit

Switch to a cross-platform stack only if **all three** of these become true:
1. v1 has shipped and earned $25K+ ARR
2. You decide to build a Mac app — note: SwiftUI gives you Mac for free.
3. You decide to build Android — at which point evaluate Compose Multiplatform or KMP (NOT Expo, because the Watch + WidgetKit problem doesn't go away).

Until then: native, single-platform, Swift.
