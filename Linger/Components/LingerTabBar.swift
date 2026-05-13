//  Linger
//  LingerTabBar.swift
//
//  iOS 26 Liquid Glass tab bar. The host capsule is a thick translucent
//  surface; the selected pill sits deeper inside with a real lift shadow
//  so it reads as a separate lifted element on the glass, not flat paint.
//  Sibling: a dark capsule for the + button.

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
            tabButton(.today, label: "Today", systemImage: "sun.horizon")
            tabButton(.people, label: "People", systemImage: "person.2")
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
                .shadow(color: outerShadow, radius: 18, x: 0, y: 6)
                .shadow(color: outerShadow.opacity(0.4), radius: 2, x: 0, y: 1)
        }
    }

    private var addCapsule: some View {
        Button {
            Haptic.soft.play()
            onAdd()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(plusColor)
                .frame(width: 60, height: 60)
                .background {
                    Circle()
                        .fill(plusBackground)
                        .overlay(
                            Circle()
                                .strokeBorder(addRim, lineWidth: 0.6)
                        )
                        .shadow(color: outerShadow, radius: 18, x: 0, y: 6)
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
                    .font(.system(size: 14, weight: .semibold))
                Text(label)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(isSelected ? Color.ink : Color.muted)
            .padding(.horizontal, 18)
            .padding(.vertical, 11)
            .frame(minHeight: 44)
            .background {
                if isSelected {
                    Capsule(style: .continuous)
                        .fill(selectedFill)
                        .overlay(
                            Capsule(style: .continuous)
                                .strokeBorder(selectedRim, lineWidth: 0.5)
                        )
                        .shadow(color: selectedShadow, radius: 8, x: 0, y: 3)
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
        colorScheme == .dark ? Color.white.opacity(0.04) : Color.white.opacity(0.4)
    }

    private var rimGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color.white.opacity(0.18), Color.white.opacity(0.03)]
                : [Color.white.opacity(0.9), Color.white.opacity(0.3)],
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
        colorScheme == .dark ? Color.black.opacity(0.55) : Color.black.opacity(0.10)
    }

    private var outerShadow: Color {
        colorScheme == .dark ? Color.black.opacity(0.4) : Color.black.opacity(0.12)
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
