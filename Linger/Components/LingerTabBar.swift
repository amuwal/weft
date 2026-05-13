import SwiftUI

struct LingerTabBar: View {
    @Binding var selected: AppTab
    let onAdd: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var pill

    var body: some View {
        HStack(spacing: 12) {
            tabsCapsule
            addCapsule
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var tabsCapsule: some View {
        HStack(spacing: 4) {
            tabButton(.today, label: "Today")
            tabButton(.people, label: "People")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
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
        .simultaneousGesture(
            DragGesture(minimumDistance: 18)
                .onEnded { value in
                    let dx = value.translation.width
                    guard abs(dx) > 28, abs(dx) > abs(value.translation.height) else { return }
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
                .frame(width: 54, height: 64)
                .background {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(plusBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
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
    private func tabButton(_ value: AppTab, label: String) -> some View {
        let isSelected = selected == value
        Button {
            guard selected != value else { return }
            Haptic.selection.play()
            withAnimation(.lingerSpring) { selected = value }
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(dotColor(isSelected: isSelected))
                    .frame(width: 5, height: 5)
                Text(label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.ink : Color.muted)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 14)
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

    private func dotColor(isSelected: Bool) -> Color {
        isSelected ? Color.muted : Color.muted.opacity(0.55)
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
