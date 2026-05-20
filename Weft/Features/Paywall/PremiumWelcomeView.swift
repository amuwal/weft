import SwiftUI

/// Post-purchase celebration that replaces `PaywallView`'s contents on success.
/// Designed to feel like Linger — calm, deliberate, on-brand — not like a
/// transactional confirmation. The Weft brand mark (two sage dots connected
/// by a curve) draws itself as the moment of transition. That line is literally
/// the product metaphor — the weft thread between you and your people — so
/// using it as the celebration ties the unlock to what the app is *for*.
///
/// Sequence (timings tuned by hand on iPhone 17 Pro):
///   • 0.00s  success haptic, mark + dots appear at t=0 of stroke trim
///   • 0.20s  curve trims from 0 → 1 over weftCalm; right dot scales in at end
///   • 0.90s  hero title fades + rises in
///   • 1.30s  subtitle fades in
///   • 1.70s+ five feature pills cascade in 150ms apart, each + soft haptic
///   • 2.70s  "Begin" button fades in; user taps to dismiss the paywall
///
/// The user cannot escape the screen until "Begin" — by design. The Close
/// button at the top of `PaywallView` is hidden while this view is presented.
struct PremiumWelcomeView: View {
    /// Why we're celebrating. Drives copy and whether the feature cascade
    /// runs. The logo motion is identical across modes — it's the brand
    /// moment, so reusing it is the point.
    enum Mode {
        /// User just paid via StoreKit. Show full hero + subtitle + cascade.
        case freshPurchase
        /// Restore brought back an entitlement the user already owns. Skip
        /// the feature cascade — they know what Premium does — and use
        /// "Welcome back" framing instead.
        case restored
    }

    let mode: Mode
    let onContinue: () -> Void

    @State private var drawProgress: CGFloat = 0
    @State private var leftDotVisible = false
    @State private var rightDotVisible = false
    @State private var titleVisible = false
    @State private var subtitleVisible = false
    @State private var pillsVisibleCount = 0
    @State private var buttonVisible = false

    private let features: [(icon: String, line: LocalizedStringKey)] = [
        ("infinity", "Unlimited people"),
        ("cloud", "iCloud sync across devices"),
        ("rectangle.on.rectangle.angled", "Lock-screen & home-screen widgets"),
        ("square.and.arrow.up", "PDF & Markdown export"),
        ("photo.on.rectangle", "Photo memories")
    ]

    private var heroTitle: LocalizedStringKey {
        switch mode {
        case .freshPurchase: "Welcome to Premium"
        case .restored: "Welcome back"
        }
    }

    private var heroSubtitle: LocalizedStringKey {
        switch mode {
        case .freshPurchase:
            "Thanks. Weft is a one-person studio — your support is what keeps this calm."
        case .restored:
            "Your Premium is back on this device. Pick up where you left off."
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: Spacing.xl)
            brandMark
                .frame(width: 168, height: 132)
                .padding(.bottom, Spacing.l)
            hero
                .padding(.bottom, Spacing.xl)
            if mode == .freshPurchase {
                featureList
            }
            Spacer(minLength: Spacing.l)
            beginButton
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bg)
        .onAppear { runSequence() }
    }

    /// The Weft brand mark, traced over time. Built from a `Shape` (the curve)
    /// + two `Circle` dots rather than `Canvas` because `Path.trim` is
    /// animatable as a `Shape` modifier — SwiftUI will tick the trim value
    /// through every frame of the spring. Canvas, by contrast, doesn't
    /// interpolate state across an animation, so the curve would snap.
    private var brandMark: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let dotRadius: CGFloat = 11
            let left = CGPoint(x: 32, y: h * 0.72)
            let right = CGPoint(x: w - 32, y: h * 0.72)

            ZStack {
                BrandCurveShape()
                    .trim(from: 0, to: drawProgress)
                    .stroke(
                        Color.sage,
                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                    )
                dot(at: left, visible: leftDotVisible, radius: dotRadius)
                dot(at: right, visible: rightDotVisible, radius: dotRadius)
            }
        }
    }

    /// One brand-mark endpoint. Blooms from scale 0 → 1 with a soft spring —
    /// no hard pop, no halo (a halo ring read as a bug in the off-state).
    /// Both ends use identical params so they read as twins.
    private func dot(at point: CGPoint, visible: Bool, radius: CGFloat) -> some View {
        Circle()
            .fill(Color.sage)
            .frame(width: radius * 2, height: radius * 2)
            .scaleEffect(visible ? 1 : 0)
            .opacity(visible ? 1 : 0)
            .position(point)
    }

    private var hero: some View {
        VStack(spacing: Spacing.s) {
            Text(heroTitle)
                .font(.system(size: 34, design: .serif).weight(.medium))
                .foregroundStyle(Color.ink)
                .multilineTextAlignment(.center)
                .opacity(titleVisible ? 1 : 0)
                .offset(y: titleVisible ? 0 : 12)
            Text(heroSubtitle)
                .font(WeftFont.serifBody)
                .italic()
                .foregroundStyle(Color.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
                .opacity(subtitleVisible ? 1 : 0)
        }
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            ForEach(Array(features.enumerated()), id: \.offset) { idx, item in
                if idx < pillsVisibleCount {
                    HStack(spacing: 14) {
                        Image(systemName: item.icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.sageInk)
                            .frame(width: 28, height: 28)
                            .background(Color.sageWash, in: Circle())
                        Text(item.line)
                            .font(WeftFont.serifBody)
                            .foregroundStyle(Color.ink)
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .leading)),
                        removal: .opacity
                    ))
                }
            }
        }
        .padding(.horizontal, Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var beginButton: some View {
        Button {
            Haptic.soft.play()
            onContinue()
        } label: {
            Text("Begin")
        }
        .buttonStyle(WeftPrimaryButtonStyle())
        .opacity(buttonVisible ? 1 : 0)
        .offset(y: buttonVisible ? 0 : 8)
    }

    /// Orchestrates the cascade. `Task` + `try? await Task.sleep` gives a
    /// readable, single-thread timeline; no nested `asyncAfter` callbacks.
    ///
    /// Dots use `dotBloom` (a slower, softer custom spring) rather than
    /// `weftSpring` so the endpoint reveals feel born from the curve, not
    /// popped onto it. Right-dot timing is set so it lands *after* the curve
    /// has fully settled — appearing while the trim was still moving made
    /// the moment read as two overlapping events instead of one resolution.
    private func runSequence() {
        Haptic.success.play()
        let dotBloom: Animation = .spring(response: 0.55, dampingFraction: 0.88)
        Task { @MainActor in
            withAnimation(dotBloom) { leftDotVisible = true }
            try? await Task.sleep(for: .milliseconds(220))
            withAnimation(.weftCalm.speed(0.75)) { drawProgress = 1 }
            try? await Task.sleep(for: .milliseconds(880))
            withAnimation(dotBloom) { rightDotVisible = true }
            try? await Task.sleep(for: .milliseconds(260))
            withAnimation(.weftCalm) { titleVisible = true }
            try? await Task.sleep(for: .milliseconds(420))
            withAnimation(.weftCalm) { subtitleVisible = true }
            try? await Task.sleep(for: .milliseconds(420))
            if mode == .freshPurchase {
                for i in 0 ..< features.count {
                    withAnimation(.weftSpring) { pillsVisibleCount = i + 1 }
                    Haptic.soft.play()
                    try? await Task.sleep(for: .milliseconds(150))
                }
                try? await Task.sleep(for: .milliseconds(220))
            }
            withAnimation(.weftCalm) { buttonVisible = true }
        }
    }
}

/// The Weft brand curve as a SwiftUI `Shape` so `.trim` can animate it.
/// Endpoints sit at 72% of the height (centered with the dot circles) and
/// the control point lifts to 17% to give the gentle arc. Geometry derived
/// from the parent rect — works at any size.
struct BrandCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let endpointY = rect.height * 0.72
        p.move(to: CGPoint(x: 32, y: endpointY))
        p.addQuadCurve(
            to: CGPoint(x: rect.width - 32, y: endpointY),
            control: CGPoint(x: rect.width / 2, y: rect.height * 0.17)
        )
        return p
    }
}

#Preview("Fresh purchase") {
    PremiumWelcomeView(mode: .freshPurchase, onContinue: {})
}

#Preview("Restored") {
    PremiumWelcomeView(mode: .restored, onContinue: {})
}
