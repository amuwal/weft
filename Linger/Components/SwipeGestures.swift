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
            .background(alignment: .leading) {
                actionLabel(
                    text: "Caught up",
                    icon: "checkmark.circle.fill",
                    tint: .sage,
                    active: offset > threshold
                )
                .opacity(offset > 12 ? min(offset / threshold, 1) : 0)
                .padding(.leading, 24)
            }
            .background(alignment: .trailing) {
                actionLabel(
                    text: "Snooze",
                    icon: "moon.zzz.fill",
                    tint: .muted,
                    active: offset < -threshold
                )
                .opacity(offset < -12 ? min(abs(offset) / threshold, 1) : 0)
                .padding(.trailing, 24)
            }
            .offset(x: offset)
            .opacity(isFlying ? 0 : 1)
            .scaleEffect(1 - min(abs(offset) / 2000, 0.05))
            // simultaneousGesture so a short tap still flows through to the
            // underlying NavigationLink while a real horizontal drag activates
            // the swipe action.
            .simultaneousGesture(
                DragGesture(minimumDistance: 14)
                    .onChanged { value in
                        guard !isFlying else { return }
                        let x = value.translation.width
                        // Only engage horizontally — let vertical scrolling win.
                        guard abs(x) > abs(value.translation.height) else { return }
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

    private func actionLabel(text: String, icon: String, tint: Color, active: Bool) -> some View {
        Label { Text(text) } icon: { Image(systemName: icon) }
            .font(LingerFont.caption.weight(.semibold))
            .foregroundStyle(active ? tint : tint.opacity(0.55))
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
