import SwiftUI

struct AddButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            Haptic.soft.play()
            action()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.bg)
                .frame(width: 56, height: 56)
                .background(Color.ink, in: Circle())
                .shadow(color: Color.ink.opacity(0.45), radius: 10, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add")
    }
}

#Preview {
    AddButton(action: {})
        .padding()
        .background(Color.bg)
}
