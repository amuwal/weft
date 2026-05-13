import SwiftUI

struct OnboardingView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @State private var step: Step = .welcome
    @State private var defaultRhythm: Rhythm = .monthly

    enum Step { case welcome, rhythm }

    var body: some View {
        ZStack {
            Color.bg.ignoresSafeArea()
            switch step {
            case .welcome: welcome
            case .rhythm: rhythmPicker
            }
        }
    }

    private var welcome: some View {
        VStack(spacing: Spacing.huge) {
            Spacer()
            Image(systemName: "arc.continuous")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(Color.sage)
            VStack(spacing: Spacing.ml) {
                Text("Linger.")
                    .font(.system(size: 46, design: .serif).weight(.medium))
                    .foregroundStyle(Color.ink)
                Text("A quiet place for the people who matter.")
                    .font(LingerFont.serifBody)
                    .foregroundStyle(Color.muted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.huge)
            }
            Spacer()
            Button("Begin") { withAnimation(.lingerSpring) { step = .rhythm } }
                .buttonStyle(LingerPrimaryButtonStyle())
                .padding(.horizontal, Spacing.huge)
            Text("No account, no cloud.\nEverything stays on your phone.")
                .font(LingerFont.caption)
                .foregroundStyle(Color.whisper)
                .multilineTextAlignment(.center)
                .padding(.bottom, Spacing.xl)
        }
    }

    private var rhythmPicker: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            Text("Step 3 of 3")
                .font(LingerFont.caption)
                .foregroundStyle(Color.muted)
            Text("How often would you like to think of them?")
                .font(.system(size: 28, design: .serif).weight(.medium))
                .foregroundStyle(Color.ink)
            HStack(spacing: 8) {
                ForEach(Rhythm.allCases) { rhythm in
                    Button(rhythm.label) {
                        defaultRhythm = rhythm
                        Haptic.selection.play()
                    }
                    .buttonStyle(ChipStyle(isSelected: defaultRhythm == rhythm))
                }
            }
            Spacer()
            HStack {
                Button("Skip") { onboardingComplete = true }
                    .buttonStyle(LingerGhostButtonStyle())
                Button("Continue") { onboardingComplete = true }
                    .buttonStyle(LingerPrimaryButtonStyle())
            }
        }
        .padding(Spacing.xl)
    }
}

struct ChipStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LingerFont.caption)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.ink : Color.surface2, in: Capsule())
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

#Preview {
    OnboardingView()
}
