import SwiftUI

extension Animation {
    /// Default for opens, transitions, and most state changes.
    static let weftSpring: Animation = .spring(response: 0.4, dampingFraction: 0.78)

    /// Press / tap feedback. Faster, snappier.
    static let weftPress: Animation = .spring(response: 0.15, dampingFraction: 0.7)

    /// Long, calm transitions: empty-state reveals, sheet dismiss.
    static let weftCalm: Animation = .spring(response: 0.6, dampingFraction: 0.85)

    /// Used during an active drag — interruptible, blends smoothly when the gesture changes.
    /// `.interactiveSpring` is iOS's purpose-built spring for finger-driven motion.
    static let weftDrag: Animation = .interactiveSpring(
        response: 0.18,
        dampingFraction: 0.86,
        blendDuration: 0.12
    )

    /// The "settle back to zero" spring after a non-committing drag — soft, organic.
    static let weftReturn: Animation = .spring(response: 0.42, dampingFraction: 0.82)

    /// Commit / fly-out — slightly bouncy to feel rewarding without going cartoonish.
    static let weftCommit: Animation = .spring(response: 0.32, dampingFraction: 0.76)
}
