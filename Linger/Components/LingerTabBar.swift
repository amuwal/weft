import SwiftUI

struct LingerTabBar: View {
    @Binding var selected: AppTab
    let onAdd: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var pill
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        HStack(spacing: 12) {
            tabsCapsule
            addCapsule
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var tabsCapsule: some View {
        HStack(spacing: 4) {
            tabButton(.today, label: "Today", systemImage: "house")
            tabButton(.people, label: "People", systemImage: "person.2")
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 7)
        .background {
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule(style: .continuous)
                        .fill(glassTint)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(rimGradient, lineWidth: 0.6)
                )
                .shadow(color: outerShadow, radius: 20, x: 0, y: 8)
                .shadow(color: outerShadow.opacity(0.4), radius: 2, x: 0, y: 1)
        }
        .gesture(
            DragGesture(minimumDistance: 12)
                .onEnded { value in
                    let dx = value.translation.width
                    guard abs(dx) > 24 else { return }
                    if dx < 0, selected == .today {
                        Haptic.selection.play()
                        withAnimation(.lingerSpring) { selected = .people }
                    } else if dx > 0, selected == .people {
                        Haptic.selection.play()
                        withAnimation(.lingerSpring) { selected = .today }
                    }
                }
        )
    }

    private var addCapsule: some View {
        Button {
            Haptic.soft.play()
            onAdd()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(plusColor)
                .frame(width: 62, height: 62)
                .background {
                    Circle()
                        .fill(plusBackground)
                        .overlay(
                            Circle()
                                .strokeBorder(addRim, lineWidth: 0.6)
                        )
                        .shadow(color: outerShadow, radius: 20, x: 0, y: 8)
                        .shadow(color: outerShadow.opacity(0.4), radius: 2, x: 0, y: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add")
    }

    @ViewBuilder
    private func tabButton(_ value: AppTab, label: String, systemImage: String) -> some View {
        let isSelected = selected == value
        Button {
            guard selected != value else { return }
            Haptic.selection.play()
            withAnimation(.lingerSpring) { selected = value }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .regular))
                Text(label)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(isSelected ? Color.ink : Color.muted)
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
            .frame(minHeight: 48)
            .background {
                if isSelected {
                    Capsule(style: .continuous)
                        .fill(selectedFill)
                        .overlay(
                            Capsule(style: .continuous)
                                .strokeBorder(selectedRim, lineWidth: 0.5)
                        )
                        .shadow(color: selectedShadow, radius: 10, x: 0, y: 4)
                        .shadow(color: selectedShadow.opacity(0.35), radius: 1, x: 0, y: 1)
                        .matchedGeometryEffect(id: "pill", in: pill)
                }
            }
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
        .buttonStyle(.plain)
        .contentShape(Capsule())
    }

    private var glassTint: Color {
        colorScheme == .dark ? Color.white.opacity(0.04) : Color.white.opacity(0.45)
    }

    private var rimGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color.white.opacity(0.18), Color.white.opacity(0.03)]
                : [Color.white.opacity(0.95), Color.white.opacity(0.35)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var selectedFill: Color {
        colorScheme == .dark ? Color(white: 0.22) : Color.white
    }

    private var selectedRim: Color {
        colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.04)
    }

    private var selectedShadow: Color {
        colorScheme == .dark ? Color.black.opacity(0.55) : Color.black.opacity(0.12)
    }

    private var outerShadow: Color {
        colorScheme == .dark ? Color.black.opacity(0.4) : Color.black.opacity(0.14)
    }

    private var addRim: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.18)
    }

    private var plusColor: Color {
        colorScheme == .dark ? Color.ink : Color.bg
    }

    private var plusBackground: Color {
        colorScheme == .dark ? Color(white: 0.95) : Color.ink
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color.bg.ignoresSafeArea()
        LingerTabBar(selected: .constant(.today), onAdd: {})
            .padding(.horizontal, Spacing.l)
            .padding(.bottom, 12)
    }
}
