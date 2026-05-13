import SwiftUI

struct PersonAvatar: View {
    let initial: String
    let palette: AvatarPalette
    var size: CGFloat = 48

    var body: some View {
        Text(initial)
            .font(.system(size: size * 0.42, weight: .medium, design: .serif))
            .foregroundStyle(foreground)
            .frame(width: size, height: size)
            .background(background, in: Circle())
            .overlay(Circle().strokeBorder(Color.ink.opacity(0.04), lineWidth: 0.5))
    }

    private var background: Color {
        switch palette {
        case .sage: .sageWash
        case .warm: .warmWash
        case .slate: Color(red: 0.867, green: 0.890, blue: 0.910)
        case .rose: Color(red: 0.945, green: 0.863, blue: 0.847)
        case .clay: Color(red: 0.914, green: 0.851, blue: 0.784)
        case .lilac: Color(red: 0.871, green: 0.843, blue: 0.910)
        case .blue: Color(red: 0.839, green: 0.871, blue: 0.922)
        }
    }

    private var foreground: Color {
        switch palette {
        case .sage: .sageInk
        case .warm: Color(red: 0.42, green: 0.29, blue: 0.12)
        case .slate: Color(red: 0.184, green: 0.247, blue: 0.294)
        case .rose: Color(red: 0.420, green: 0.184, blue: 0.165)
        case .clay: Color(red: 0.361, green: 0.251, blue: 0.165)
        case .lilac: Color(red: 0.247, green: 0.180, blue: 0.361)
        case .blue: Color(red: 0.165, green: 0.227, blue: 0.341)
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        ForEach(AvatarPalette.allCases, id: \.self) { palette in
            PersonAvatar(initial: "L", palette: palette)
        }
    }
    .padding()
    .background(Color.bg)
}
