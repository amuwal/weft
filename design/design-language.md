# Linger — design language

## Pillars

1. **Calm > productive.** Feel closer to Day One/Bear than to Notion or a CRM. The app should make you exhale, not produce.
2. **Content-first.** The names of your people and the notes you write are the heroes. Chrome recedes.
3. **iOS 26-native.** Liquid Glass everywhere it ships. Use system controls; resist custom UI that fights the OS.
4. **Whisper, don't shout.** No badges, no streaks, no red dots, no nagging. Reminders are gentle "today's people" lists, not push notifications by default.
5. **Typography led.** Reading and writing are the primary actions. Type does heavy lifting; ornament is sparse.

## Color

Light mode:
- Background: warm off-white (`#F8F5EF` — like aged paper, not pure white)
- Surface (cards): pure white with a 6% warm-gray shadow at y=4, blur=12
- Primary text: ink (`#1B1A17`)
- Secondary text: muted (`#6B6862`)
- Accent: muted sage (`#5C7A66`) — warm green, not the typical garden-app emerald
- Warm (used sparingly for "today"): amber (`#C68A3A`)

Dark mode:
- Background: deep ink (`#16141 0`) — not pure black; never pure black
- Surface: slate (`#22201C`)
- Primary text: `#EDE8DC`
- Secondary text: `#8E8A82`
- Accent: lifted sage (`#7FA48A`)
- Warm: muted amber (`#D5A767`)

Avoid:
- System blue chrome
- Pure black backgrounds (too OLED-cliché)
- Rainbow/AI gradient sparkles
- Hard saturated colors

## Typography

System fonts only (faster, accessible, native feel).

- **Display / large headings**: New York (Apple's serif), weight Medium — used sparingly. The hero "Who's on your mind today?" or a person's name on detail screen.
- **Body / UI**: SF Pro, Regular — generous line height (1.5 of font size).
- **Captions / metadata**: SF Pro Rounded, Regular at small sizes — softens timestamps and pill-style metadata.
- **No monospace** — this isn't a dev tool.

Sample hierarchy:
- Display 32pt New York Medium
- Title 22pt SF Pro Semibold
- Body 17pt SF Pro Regular
- Caption 13pt SF Pro Rounded Regular

## Spacing

Generous. Think Things 3 over default UIKit density.
- Base unit: 4pt
- Card padding: 20pt
- Section gap: 32pt
- Touch targets: 44pt minimum (HIG)
- Tab bar / nav: stock iOS 26 Liquid Glass — do not customize

## Iconography

- **SF Symbols only**, weight Regular, scale Medium.
- Reasons: looks native, ships free, scales with Dynamic Type and accessibility.
- One exception: the app icon (see below).

## App icon (direction, not final art)

A single low arc — like a connecting line between two soft dots — on the off-white background, sage stroke. Suggests connection without being literal (no hearts, no chat bubbles, no people silhouettes). Memorable in a row of icons because of its quietness.

Variants:
- Light mode: sage arc on cream
- Dark mode: cream arc on sage
- Tinted (iOS 18+): monochrome stroke

## Shadow & depth

- Cards rest with `shadowRadius: 12, y: 4, opacity: 0.06` in light mode; `opacity: 0.5` and slightly tighter in dark.
- Liquid Glass surfaces (tab bar, sheets, nav) use Apple's defaults — do not stack shadows on top.

## Corner radii

- Cards: 16pt
- Buttons / pills: capsule (full pill, height-derived)
- Sheets: 24pt (Apple default for iOS 26 sheets)

## Empty states

Empty states are an opportunity. A new "People" list shows a single line of New York serif:

> "Who matters to you?"

…with a single subtle button: "Add the first person." No illustration, no empty-state mascot.

## Voice & microcopy

- Warm, lowercase where it fits, but never twee.
- "Who's on your mind today?" not "Today's reminders"
- "Add a person" not "+ New contact"
- "Last seen" not "Last interaction logged"
- "It's been a while" not "OVERDUE"
- Never use words: "track", "manage", "ping", "engagement", "streak"
