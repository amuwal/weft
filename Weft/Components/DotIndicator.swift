import SwiftUI

enum RhythmState {
    case recent
    case onRhythm
    case lingering
}

struct DotIndicator: View {
    let state: RhythmState
    var size: CGFloat = 7

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .overlay(Circle().strokeBorder(Color.ink.opacity(0.06), lineWidth: 0.5))
            .accessibilityLabel(label)
    }

    private var color: Color {
        switch state {
        case .recent: Color(red: 0.498, green: 0.643, blue: 0.541)
        case .onRhythm: Color(red: 0.788, green: 0.757, blue: 0.690)
        case .lingering: .warm
        }
    }

    private var label: String {
        switch state {
        case .recent: "Recent"
        case .onRhythm: "On rhythm"
        case .lingering: "It's been a while"
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        DotIndicator(state: .recent)
        DotIndicator(state: .onRhythm)
        DotIndicator(state: .lingering)
    }
    .padding()
    .background(Color.bg)
}
