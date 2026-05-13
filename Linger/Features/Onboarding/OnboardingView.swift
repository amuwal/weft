import SwiftData
import SwiftUI

struct OnboardingView: View {
    enum Step: Hashable { case welcome, rhythm }

    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @AppStorage("defaultRhythmRaw") private var defaultRhythmRaw: Int = Rhythm.monthly.rawValue
    @State private var step: Step = Self.initialStep

    private static var initialStep: Step {
        ProcessInfo.processInfo.arguments.contains("--rhythm") ? .rhythm : .welcome
    }

    var body: some View {
        ZStack {
            Color.bg.ignoresSafeArea()
            radialGlow
            content
                .animation(.lingerSpring, value: step)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .welcome: welcome
        case .rhythm: rhythmPicker
        }
    }

    private var radialGlow: some View {
        RadialGradient(
            colors: [Color.warmWash.opacity(0.7), Color.bg.opacity(0)],
            center: .top,
            startRadius: 40,
            endRadius: 540
        )
        .ignoresSafeArea()
    }

    private var welcome: some View {
        VStack(spacing: Spacing.huge) {
            Spacer()
            arcIcon
            VStack(spacing: Spacing.m) {
                Text("Linger.")
                    .font(.system(size: 46, design: .serif).weight(.medium))
                    .foregroundStyle(Color.ink)
                Text("A quiet place for the\npeople who matter.")
                    .font(.system(size: 22, design: .serif))
                    .foregroundStyle(Color.muted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            Spacer()
            Button("Begin") { withAnimation(.lingerSpring) { step = .rhythm } }
                .buttonStyle(LingerPrimaryButtonStyle())
                .padding(.horizontal, Spacing.huge)
            Text("No account, no cloud by default.\nEverything stays on your phone.")
                .font(LingerFont.caption)
                .foregroundStyle(Color.whisper)
                .multilineTextAlignment(.center)
                .padding(.bottom, Spacing.xl)
        }
    }

    private var rhythmPicker: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            Button {
                Haptic.selection.play()
                withAnimation(.lingerSpring) { step = .welcome }
            } label: {
                Label("Back", systemImage: "chevron.left")
                    .font(LingerFont.caption)
                    .foregroundStyle(Color.muted)
            }
            .buttonStyle(.plain)
            .padding(.top, Spacing.xxl)

            Text("Step 2 of 2")
                .font(LingerFont.caption)
                .foregroundStyle(Color.muted)
            Text("How often\nshould we surface them?")
                .font(.system(size: 30, design: .serif).weight(.medium))
                .lineSpacing(2)
                .foregroundStyle(Color.ink)
            Text("Don't worry about getting this right. You can change it per person, anytime.")
                .font(LingerFont.serifBody)
                .foregroundStyle(Color.muted)
                .padding(.top, 4)

            FlowChipsLayout(spacing: 8) {
                ForEach(Rhythm.allCases) { rhythm in
                    Button(rhythm.label) {
                        defaultRhythmRaw = rhythm.rawValue
                        Haptic.selection.play()
                    }
                    .buttonStyle(ChipStyle(isSelected: defaultRhythmRaw == rhythm.rawValue))
                }
            }
            .padding(.top, Spacing.s)

            Spacer()

            HStack(spacing: Spacing.m) {
                Button("Skip", action: complete)
                    .buttonStyle(LingerGhostButtonStyle())
                Button("Continue", action: complete)
                    .buttonStyle(LingerPrimaryButtonStyle())
            }
            .padding(.bottom, Spacing.xl)
        }
        .padding(.horizontal, Spacing.xl)
    }

    private var arcIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.surface)
                .frame(width: 96, height: 96)
                .shadow(color: Color.ink.opacity(0.06), radius: 18, y: 8)
            Canvas { ctx, size in
                var path = Path()
                path.move(to: CGPoint(x: 18, y: size.height * 0.7))
                path.addQuadCurve(
                    to: CGPoint(x: size.width - 18, y: size.height * 0.7),
                    control: CGPoint(x: size.width / 2, y: size.height * 0.25)
                )
                ctx.stroke(path, with: .color(.sage), style: .init(lineWidth: 4, lineCap: .round))
                let dotR: CGFloat = 6
                ctx.fill(
                    Path(ellipseIn: CGRect(
                        x: 12,
                        y: size.height * 0.7 - dotR,
                        width: dotR * 2,
                        height: dotR * 2
                    )),
                    with: .color(.sage)
                )
                ctx.fill(
                    Path(ellipseIn: CGRect(
                        x: size.width - 24,
                        y: size.height * 0.7 - dotR,
                        width: dotR * 2,
                        height: dotR * 2
                    )),
                    with: .color(.sage)
                )
            }
            .frame(width: 70, height: 70)
        }
    }

    private func complete() {
        Haptic.success.play()
        withAnimation(.lingerCalm) { onboardingComplete = true }
    }
}

struct ChipStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LingerFont.caption)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? Color.ink : Color.surface, in: Capsule())
            .overlay(Capsule().strokeBorder(Color.ink.opacity(isSelected ? 0 : 0.1), lineWidth: 0.5))
            .foregroundStyle(isSelected ? Color.bg : Color.ink)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.lingerPress, value: configuration.isPressed)
    }
}

struct LingerGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LingerFont.body.weight(.semibold))
            .foregroundStyle(Color.ink)
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(Color.surface, in: Capsule())
            .overlay(Capsule().strokeBorder(Color.ink.opacity(0.16), lineWidth: 0.5))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.lingerPress, value: configuration.isPressed)
    }
}

/// Flow / wrap layout for the chip row.
private struct FlowChipsLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let width = proposal.width ?? 320
        var current: CGFloat = 0
        var height: CGFloat = 0
        var lineHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if current + size.width > width {
                current = 0
                height += lineHeight + spacing
                lineHeight = 0
            }
            current += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: width, height: height + lineHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal _: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) {
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

#Preview {
    OnboardingView()
}
