import SwiftUI

extension View {
    func swipeGestures(
        threshold: CGFloat = 90,
        onCaughtUp: @escaping () -> Void,
        onSnooze: @escaping () -> Void
    ) -> some View {
        modifier(SwipeGestures(threshold: threshold, onCaughtUp: onCaughtUp, onSnooze: onSnooze))
    }
}

private struct SwipeGestures: ViewModifier {
    let threshold: CGFloat
    let onCaughtUp: () -> Void
    let onSnooze: () -> Void

    @State private var offset: CGFloat = 0
    @State private var isFlying = false

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .opacity(isFlying ? 0 : 1)
            .scaleEffect(1 - min(abs(offset) / 2000, 0.05))
            .gesture(
                DragGesture(minimumDistance: 8)
                    .onChanged { value in
                        guard !isFlying else { return }
                        let x = value.translation.width
                        offset = x > 0 ? min(x * 0.7, 220) : x * 0.25
                    }
                    .onEnded { value in
                        let x = value.translation.width
                        if x > threshold {
                            commit(direction: 1, action: onCaughtUp)
                        } else if x < -threshold {
                            commit(direction: -1, action: onSnooze)
                        } else {
                            withAnimation(.lingerSpring) { offset = 0 }
                        }
                    }
            )
    }

    private func commit(direction: CGFloat, action: @escaping () -> Void) {
        isFlying = true
        withAnimation(.lingerSpring) {
            offset = direction * 600
        }
        action()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            offset = 0
            isFlying = false
        }
    }
}

extension View {
    /// Tiny press-down scale used on tappable cards.
    func pressable() -> some View {
        modifier(Pressable())
    }
}

private struct Pressable: ViewModifier {
    @State private var pressed = false
    func body(content: Content) -> some View {
        content
            .scaleEffect(pressed ? 0.97 : 1)
            .animation(.lingerPress, value: pressed)
            .onLongPressGesture(
                minimumDuration: 0,
                maximumDistance: .infinity,
                perform: {},
                onPressingChanged: { isPressing in
                    pressed = isPressing
                    if isPressing { Haptic.soft.play() }
                }
            )
    }
}
