# Features — v1 (MVP)

Shipping target: 4–5 weeks solo. Everything below is "do this; everything else is later or never."

## Core flows

### 1. Onboarding (no signup)
- 3 light steps: welcome → import contacts (optional, multi-select up to 10) → set default rhythm.
- No email, no password, no terms-of-service wall. Privacy notice in-line.

### 2. Today (home tab)
- Surfaces 0–3 people. Selection is rule-based, not ML:
  - Time since last touchpoint > person's rhythm → eligible
  - Score = (overdue ratio) × (relationship weight, inner > family > close > work > other)
  - Cap at 3. If no one eligible: empty calm state.
- Each card shows: name + reason (last note's open thread, or "It's been N weeks")
- Actions: tap → detail; swipe right → caught up; swipe left → snooze 3 days

### 3. People list
- Grouped by relationship type. Search field. Long-press for quick actions.
- Dot indicator per person: green (recent) / cream (within rhythm) / amber (overdue).

### 4. Person detail
- Header: name, relationship, rhythm, "last seen" pill
- Segmented: **Notes** / **Threads** / **Log**
- Add note button (sticky bottom)
- Edit person via top-right

### 5. Add note (modal)
- Person picker (defaults to last)
- Free text body, markdown invisibly supported
- "Follow up" toggle → adds a Thread with date
- Save closes sheet; updates Today card to "caught up" if applicable

### 6. Add person (modal)
- Name, relationship pill, rhythm pill, optional birthday

### 7. Settings
- iCloud sync toggle (default ON if signed into iCloud, else OFF — never required)
- Daily nudge time (default 9:00 AM, can disable)
- Appearance (theme + accent picker)
- Data: export PDF / export Markdown / delete all
- Premium status + restore purchase

## Data model

```swift
struct Person {
    let id: UUID
    var name: String
    var relationshipType: RelationshipType  // inner, close, family, work, other
    var rhythm: Rhythm                      // weekly, biweekly, monthly, quarterly, none
    var birthday: Date?
    var avatar: Image?                      // optional photo
    var createdAt: Date
    var pinned: Bool                        // surface to top of People list
}

enum Rhythm: Int {
    case weekly = 7
    case biweekly = 14
    case monthly = 30
    case quarterly = 90
    case none = 0
}

struct Note {
    let id: UUID
    let personId: UUID
    var body: String                        // markdown
    var createdAt: Date
    var photoIds: [UUID]                    // attached photos (premium)
}

struct Thread {
    let id: UUID
    let personId: UUID
    let sourceNoteId: UUID?                 // note that spawned it
    var body: String                        // "follow up on…"
    var dueDate: Date
    var resolvedAt: Date?
}

struct Touchpoint {
    let id: UUID
    let personId: UUID
    let createdAt: Date
    let kind: Kind                          // .note, .markedCaughtUp, .imported
}
```

Storage: SwiftData (iOS 17+ required). CloudKit private database for sync.

## Free vs. Premium

| Feature | Free | Premium |
|---|---|---|
| People | 7 max | Unlimited |
| Notes / Threads / Log | ✓ | ✓ |
| iCloud sync | — | ✓ |
| Apple Watch | — | ✓ |
| Photo memories | — | ✓ |
| PDF / Markdown export | — | ✓ |
| Custom accent color | — | ✓ |
| Lock screen widget | ✓ | ✓ |
| Apple Shortcuts | — | ✓ |

Pricing: $3.99/mo · $24.99/yr · 7-day free trial. Never lifetime (sustainable model).

## What ships in v1, what doesn't

In: everything above.
Out (deferred to v2+): see [features-v2.md](features-v2.md).

## v1 build order (recommended)

1. Data model + SwiftData persistence (week 1)
2. People list + Person detail (week 1-2)
3. Add note flow (week 2)
4. Today screen + scoring logic (week 2)
5. Settings + iCloud sync (week 3)
6. Widget + Apple Watch (week 3)
7. Paywall + StoreKit 2 + RevenueCat or native (week 4)
8. Polish pass: motion, haptics, empty states, copy (week 4)
9. TestFlight beta (week 4–5)
