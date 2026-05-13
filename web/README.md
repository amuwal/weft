# Linger — Web UI Framework

> A standalone HTML/CSS/JSX framework that mirrors the iOS app's visual language. Use it for design reviews, marketing landing pages, and as a reference when porting to SwiftUI.

This is **not** the production app (that's SwiftUI). This is the mockup framework — every screen rendered in a working iPhone frame in your browser, so you can validate the visual language end-to-end before writing a line of Swift.

## Layout

```
web/
├── index.html              ← 10 screens in iPhone frames
├── components.html         ← design-system showcase (color, type, motion, icons)
├── css/
│   ├── tokens.css          ← single source of truth — colors, type, spacing, springs
│   ├── base.css            ← reset + typography
│   ├── liquid-glass.css    ← iOS 26 Liquid Glass surfaces
│   ├── motion.css          ← spring keyframes + reveal helpers
│   └── components.css      ← cards, pills, buttons, segmented, toggle, modal
├── js/
│   └── interactions.js     ← tab/seg/chip toggling, modal open, swipe gestures
├── assets/
│   ├── app-icon.svg        ← light variant
│   ├── app-icon-dark.svg
│   ├── app-icon-tinted.svg
│   └── icons.svg           ← SF-Symbols-style sprite (~30 icons)
└── components/             ← optional React/JSX ports (motion.dev / Framer Motion)
    ├── PersonCard.jsx      ← swipe-to-resolve card with rubber-band drag
    ├── Tabbar.jsx          ← Liquid Glass tab bar + FAB
    ├── AddNoteSheet.jsx    ← drag-to-dismiss modal sheet
    └── SmartText.jsx       ← word-by-word stagger (inspired by @leouiux)
```

## Run

```bash
cd web
python3 -m http.server 4173
# open http://localhost:4173
```

## What's mocked

10 screens from `/design/screens.md`:

1. Onboarding — welcome screen + rhythm picker
2. Today — three cards, empty calm state
3. People — grouped list + fuzzy search
4. Person Detail — Notes tab + Threads tab
5. Quick-add note sheet (modal)
6. Add person sheet (modal)
7. Settings
8. Paywall (Premium)
9. Home / lock-screen widgets (S, M, L) + tinted lock-screen variant
10. Apple Watch

Plus a `components.html` page with color swatches, the type scale, the SVG icon sprite, motion demos for each named spring, the haptic vocabulary, and live samples of every component.

## Design tokens

Edit `css/tokens.css` to retune the whole system. Tokens map 1:1 to the values in `/design/design-language.md`:

```css
--bg:    #F8F5EF;   /* aged paper */
--ink:   #1B1A17;   /* primary text */
--sage:  #5C7A66;   /* accent */
--warm:  #C68A3A;   /* "today" highlight */

--spring:      cubic-bezier(.22, 1.36, .36, 1);   /* lingerSpring   */
--spring-press:cubic-bezier(.34, 1.56, .64, 1);   /* lingerPress    */
--spring-calm: cubic-bezier(.16,  .9,  .3, 1);    /* lingerCalm     */
```

## Typography

System fonts first — `New York` for display, `SF Pro` for body, `SF Pro Rounded` for captions. `Newsreader` is loaded from Google Fonts as a cross-platform fallback so the framework looks consistent on Linux/Windows browsers too.

## Liquid Glass

`css/liquid-glass.css` defines a `.glass` class that uses `backdrop-filter: saturate(160%) blur(28px)` with a doubled-layer rim highlight to approximate iOS 26 Liquid Glass. Apply `.warm-tint` or `.sage-tint` for contextual coloring. Falls back to a solid warm tint where `backdrop-filter` is unsupported.

## Motion / haptics

Web cannot fire Taptic Engine vibration, but `interactions.js` triggers a 480ms ring of sage glow around the screen when a swipe completes successfully — a visual stand-in for the `.success` haptic. The named springs match the SwiftUI extension in `/design/motion-and-haptics.md`.

## Porting to SwiftUI

The token names are 1:1 with the SwiftUI variables you'll create:

| Web CSS                       | SwiftUI                                       |
|-------------------------------|-----------------------------------------------|
| `var(--bg)`                   | `Color("bg")`                                 |
| `var(--sage)`                 | `Color("accent")`                             |
| `var(--spring)`               | `.spring(response: 0.4, dampingFraction: .78)`|
| `.glass`                      | `.background(.regularMaterial)` + tint        |
| `.tabbar-host`                | `TabView` with `.tabViewStyle(.sidebarAdaptable)` (iOS 26) |

## What's *not* in this framework

- Real data — every screen uses sample copy from the spec
- Network calls
- Theme persistence (the dark toggle resets on reload)
- Real Taptic / accessibility audit (do that pass in SwiftUI, not web)
