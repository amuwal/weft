import SwiftUI

struct LingerTabBar: View {
    @Binding var selected: AppTab
    let onAdd: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            tabPicker
            addCapsule
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var tabPicker: some View {
        Picker("Tab", selection: $selected) {
            Text("Today").tag(AppTab.today)
            Text("People").tag(AppTab.people)
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .frame(width: 220)
        .frame(height: 44)
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
        .onChange(of: selected) { _, _ in
            Haptic.selection.play()
        }
    }

    private var addCapsule: some View {
        Button {
            Haptic.soft.play()
            onAdd()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(plusGlyphColor)
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

    private var outerShadow: Color {
        colorScheme == .dark ? Color.black.opacity(0.4) : Color.black.opacity(0.14)
    }

    private var addRim: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.18)
    }

    /// In light mode the + sits on dark ink so the glyph is cream. In dark
    /// mode the button is a cream tile so the glyph must be ink-black to
    /// stay visible.
    private var plusGlyphColor: Color {
        colorScheme == .dark ? .black : Color.bg
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
