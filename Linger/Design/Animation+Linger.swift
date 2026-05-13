import SwiftUI

extension Animation {
    /// Default for opens, transitions, and most state changes.
    static let lingerSpring: Animation = .spring(response: 0.4, dampingFraction: 0.78)

    /// Press / tap feedback. Faster, snappier.
    static let lingerPress: Animation = .spring(response: 0.15, dampingFraction: 0.7)

    /// Long, calm transitions: empty-state reveals, sheet dismiss.
    static let lingerCalm: Animation = .spring(response: 0.6, dampingFraction: 0.85)
}
