# Motion & haptics

The 5% of polish that separates premium from generic.

## Motion principles

- Spring physics, never linear. Default spring: `.spring(response: 0.4, dampingFraction: 0.78)`. Slightly underdamped so it has personality without overshooting.
- Asymmetric forward/back. Opening a person detail feels weightier (longer, more arc) than closing.
- Matched geometry transitions when a card opens into a screen — the card title and avatar morph into the detail header.
- Reduced motion respected — gracefully fall back to dissolve transitions when user has reduced-motion on.

## Specific motion moments

### Tap a person card on Today
1. Card scales to 0.97 on press (`response: 0.15, dampingFraction: 0.7`)
2. On release, card lifts (shadow grows, scale 1.02 briefly) and starts a matched geometry transition to detail view
3. Detail header materializes from the card's position
4. Body content fades in below with 60ms stagger between Notes/Threads/Log items

### Swipe right on a card ("caught up")
1. Card slides right ~30% with rubber band
2. Card scales down to 0.9 as it slides
3. Releases past threshold → success haptic + sage check icon appears in card's place
4. Card dissolves after 600ms

### Pull to refresh on Today
- Disabled. There's nothing to refresh. (Sync happens silently in background.)

### Quick-add note save
1. Save button presses (scale 0.96)
2. Sheet dismisses with default iOS 26 dismissal
3. Soft success haptic
4. If saving from Today screen and the target person was in today's list, their card softly fades to "caught up" state

### App icon → first screen
- Use system launch screen (no custom splash).
- First content fade-in uses 0.45s spring after launch.

## Haptic vocabulary

Apply Apple's contextual haptic guidance, never gratuitous:

| Action | Haptic |
|---|---|
| Tab switch | `.selection` (light) |
| Tap card → open detail | `.soft` from `UIImpactFeedbackGenerator` |
| Long-press on person | `.medium` |
| Save note | `.success` from `UINotificationFeedbackGenerator` |
| Swipe "caught up" past threshold | `.success` |
| Snooze swipe | `.soft` |
| Delete confirm | `.warning` |
| Error (e.g., save failed) | `.error` |
| Premium paywall purchase complete | `.success` + a single 0.4s spring scale of the checkmarks |

Never:
- Vibrate on every keystroke
- Haptic on scroll
- Heavy haptic anywhere — it reads as cheap

## "Premium feel" micro-interactions

1. **Tab bar press** — Liquid Glass tab bar already has the bubbly interactive glass effect on touch-down (iOS 26 system default). Don't replace it.
2. **Card press scale** — 0.97 with spring. Tiny. Almost subliminal.
3. **Text field focus** — caret pulses with 1.2s breathing rhythm (system default; don't override).
4. **Number changes** — animated count-ups on rhythm changes ("every 2 weeks" → "every 3 weeks").
5. **Long-press menu** — fade in over 180ms with material blur of background.

## SwiftUI implementation notes

Spring values to use throughout:
```swift
extension Animation {
    static let lingerSpring = Animation.spring(response: 0.4, dampingFraction: 0.78)
    static let lingerPress = Animation.spring(response: 0.15, dampingFraction: 0.7)
    static let lingerCalm = Animation.spring(response: 0.6, dampingFraction: 0.85)
}
```

Use `matchedGeometryEffect` for card → detail. Use `phaseAnimator` (iOS 17+) for any sequential micro-animations on save success.

Reference: `swiftwithmajid.com` for Liquid Glass tab bar implementation, Apple Developer "Discover how apps are using the new design" gallery.
