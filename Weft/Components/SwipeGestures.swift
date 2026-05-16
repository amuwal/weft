import SwiftUI

extension View {
    /// Swipe-to-act gesture for a person card.
    /// Layers seven small physics behaviors to make the interaction feel hand-built:
    ///   1. `.interactiveSpring` on every offset change so drag tracking is interrupt-friendly.
    ///   2. Exponential rubber-band past commit threshold (tanh-shaped, not linear `* 0.7`).
    ///   3. Magnetic snap within `magnetRange` of the threshold line.
    ///   4. Velocity-aware decision: a fast flick commits even below the distance threshold.
    ///   5. Three-tier haptics: light tick at 80% of threshold, medium impact on threshold cross,
    ///      success notification on commit.
    ///   6. Card-background tint crossfade (sage for caught-up, warm for snooze).
    ///   7. Icon spring-pop + 1.5° tilt on threshold cross — subtle 3D handheld feel.
    func swipeGestures(
        threshold: CGFloat = 96,
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
    @State private var hasTickedApproach = false
    @State private var hasTickedThreshold = false

    /// How close to `threshold` (in pt) before magnetic snap kicks in.
    private let magnetRange: CGFloat = 14
    /// Velocity past which we treat the gesture as a deliberate flick.
    private let flickVelocity: CGFloat = 800

    func body(content: Content) -> some View {
        content
            .background(alignment: .leading) { actionLabel(.caughtUp) }
            .background(alignment: .trailing) { actionLabel(.snooze) }
            .overlay {
                // Subtle action-color wash that bleeds onto the card itself,
                // proportional to drag progress. Capped at 14% so text stays readable.
                RoundedRectangle(cornerRadius: Radius.cardLarge, style: .continuous)
                    .fill(tintWash)
                    .opacity(min(progress * 0.14, 0.14))
                    .allowsHitTesting(false)
            }
            .offset(x: offset)
            .rotation3DEffect(
                .degrees(rotationDegrees),
                axis: (x: 0, y: 1, z: 0),
                anchor: .center,
                perspective: 0.6
            )
            .scaleEffect(1 - min(abs(offset) / 2400, 0.04))
            .opacity(isFlying ? 0 : 1)
            // `simultaneousGesture` so a tap still flows through to the underlying
            // NavigationLink while a real horizontal drag activates the swipe.
            .simultaneousGesture(
                DragGesture(minimumDistance: 10)
                    .onChanged(handleDrag)
                    .onEnded(handleEnd)
            )
    }

    // MARK: - Computed state

    private enum Direction { case caughtUp, snooze }

    /// Normalized drag progress in [0, 1+], unbounded past threshold.
    private var progress: CGFloat {
        abs(offset) / threshold
    }

    private var rotationDegrees: Double {
        // Subtle Y-axis tilt — capped at ±1.6° so it reads as physical, not gimmicky.
        let raw = (offset / threshold) * 1.6
        return Double(max(min(raw, 1.6), -1.6))
    }

    private var tintWash: Color {
        offset > 0 ? .sage : .warm
    }

    // MARK: - Drag handlers

    private func handleDrag(_ value: DragGesture.Value) {
        guard !isFlying else { return }
        let dx = value.translation.width
        let dy = value.translation.height
        // Let vertical scrolling win.
        guard abs(dx) > abs(dy) else { return }

        let target = rubberBanded(dx)
        let snapped = applyMagnet(target)

        withAnimation(.weftDrag) {
            offset = snapped
        }

        emitDragHaptics(forNewOffset: snapped)
    }

    private func handleEnd(_ value: DragGesture.Value) {
        let velocity = value.predictedEndTranslation.width - value.translation.width
        let crossedDistance = abs(offset) > threshold
        let flickRight = velocity > flickVelocity && offset > threshold * 0.4
        let flickLeft = velocity < -flickVelocity && offset < -threshold * 0.4

        if offset > 0, crossedDistance || flickRight {
            commit(direction: .caughtUp, throwVelocity: max(velocity, 600))
        } else if offset < 0, crossedDistance || flickLeft {
            commit(direction: .snooze, throwVelocity: min(velocity, -600))
        } else {
            // Settle back. Soft haptic if we got past the approach tick threshold,
            // so the bounce-back feels deliberate.
            if hasTickedApproach { Haptic.soft.play() }
            withAnimation(.weftReturn) { offset = 0 }
            resetTicks()
        }
    }

    // MARK: - Physics

    /// Rubber-band past `threshold`. Up to threshold we follow the finger 1:1 (with a hair of
    /// resistance for the asymmetric snooze direction). Beyond threshold, additional
    /// drag is dampened by a `tanh` curve so the card slows to a stop at ~2× threshold.
    private func rubberBanded(_ dx: CGFloat) -> CGFloat {
        let sign: CGFloat = dx >= 0 ? 1 : -1
        let magnitude = abs(dx)
        // Snooze (left) is slightly heavier — biases users toward "caught up" since
        // that's the action you want to encourage. Asymmetric on purpose.
        let baseResistance: CGFloat = sign > 0 ? 1.0 : 0.85
        if magnitude <= threshold {
            return sign * magnitude * baseResistance
        }
        let overshoot = magnitude - threshold
        // tanh saturates smoothly; max additional travel ≈ threshold * 0.85
        let damped = (threshold * 0.85) * tanh(overshoot / (threshold * 0.85))
        return sign * (threshold + damped) * baseResistance
    }

    /// Magnetic snap near the commit line. If the drag passes within `magnetRange`
    /// of `±threshold`, we pull it a bit further so it locks visually onto the line.
    /// The "lock" is what makes Things-3-style swipes feel satisfying.
    private func applyMagnet(_ x: CGFloat) -> CGFloat {
        let distanceToCommit = abs(x) - threshold
        guard abs(distanceToCommit) <= magnetRange, abs(x) > threshold - magnetRange else {
            return x
        }
        let sign: CGFloat = x >= 0 ? 1 : -1
        // Pull 30% of the remaining gap toward the threshold line.
        let pull = distanceToCommit * -0.30
        return x + sign * pull
    }

    // MARK: - Haptics

    private func emitDragHaptics(forNewOffset newOffset: CGFloat) {
        let absOffset = abs(newOffset)
        let approachPoint = threshold * 0.78

        if absOffset >= approachPoint, !hasTickedApproach {
            Haptic.soft.play()
            hasTickedApproach = true
        } else if absOffset < approachPoint - 8 {
            // Reset the approach tick if the user drags back well past the trigger,
            // so they get the tick again on a second approach. The -8 hysteresis
            // prevents oscillation right at the edge.
            hasTickedApproach = false
        }

        if absOffset >= threshold, !hasTickedThreshold {
            Haptic.medium.play()
            hasTickedThreshold = true
        } else if absOffset < threshold - 8 {
            hasTickedThreshold = false
        }
    }

    private func resetTicks() {
        hasTickedApproach = false
        hasTickedThreshold = false
    }

    // MARK: - Commit

    private func commit(direction: Direction, throwVelocity: CGFloat) {
        Haptic.success.play()
        isFlying = true
        // Throw distance scales with velocity, capped so the animation duration stays
        // reasonable. Velocity is in pt/s; we want the card to clear the screen.
        let throwDistance = max(min(abs(throwVelocity) * 0.8, 1100), 700)
        let signed: CGFloat = direction == .caughtUp ? throwDistance : -throwDistance

        withAnimation(.weftCommit) {
            offset = signed
        }

        // Fire the action immediately so SwiftData / Today screen recomputes.
        switch direction {
        case .caughtUp: onCaughtUp()
        case .snooze: onSnooze()
        }

        // Reset state after the fly-out + a beat for the data layer to settle.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.42) {
            offset = 0
            isFlying = false
            resetTicks()
        }
    }

    // MARK: - Action labels behind the card

    @ViewBuilder
    private func actionLabel(_ direction: Direction) -> some View {
        let isCaughtUp = direction == .caughtUp
        let active = isCaughtUp ? offset > threshold : offset < -threshold
        let approaching = isCaughtUp ? offset > threshold * 0.78 : offset < -threshold * 0.78
        let visible = isCaughtUp ? offset > 12 : offset < -12
        let opacity = visible ? min(progress, 1) : 0

        HStack(spacing: 8) {
            Image(systemName: isCaughtUp ? "checkmark.circle.fill" : "moon.zzz.fill")
                .font(.system(size: 16, weight: .semibold))
                // Icon spring-pops on threshold cross.
                .scaleEffect(active ? 1.18 : approaching ? 1.06 : 1.0)
                .animation(.weftPress, value: active)
                .animation(.weftPress, value: approaching)
            Text(isCaughtUp ? "Caught up" : "Snooze")
                .font(WeftFont.caption.weight(.semibold))
        }
        .foregroundStyle(active ? labelTint(isCaughtUp) : labelTint(isCaughtUp).opacity(0.55))
        .opacity(opacity)
        .padding(.leading, isCaughtUp ? 24 : 0)
        .padding(.trailing, isCaughtUp ? 0 : 24)
    }

    private func labelTint(_ caughtUp: Bool) -> Color {
        caughtUp ? .sage : .warm
    }
}

// MARK: - Press scale for cards

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
            .animation(.weftPress, value: pressed)
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
