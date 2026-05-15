import SwiftUI
import UIKit

struct WeftTabBar: View {
    @Binding var selected: AppTab
    let onAdd: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    private let capsuleHeight: CGFloat = 56
    private let fabSize: CGFloat = 56

    var body: some View {
        HStack(spacing: 10) {
            tabSwitcher
            fab
        }
        .fixedSize(horizontal: true, vertical: true)
        .frame(maxWidth: .infinity, alignment: .center)
        .onChange(of: selected) { _, _ in
            Haptic.selection.play()
        }
    }

    private var tabSwitcher: some View {
        SegmentedTabPicker(selected: $selected, height: capsuleHeight)
            .frame(width: 220, height: capsuleHeight)
    }

    private var fab: some View {
        Button {
            Haptic.soft.play()
            onAdd()
        } label: {
            ZStack {
                Circle()
                    .fill(fabBackground)
                ThinPlus(color: fabGlyphColor, size: 18, lineWidth: 1.6)
            }
            .frame(width: fabSize, height: fabSize)
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.45 : 0.22), radius: 12, x: 0, y: 6)
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.10), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add")
    }

    private var fabGlyphColor: Color {
        colorScheme == .dark ? .black : Color.bg
    }

    private var fabBackground: Color {
        colorScheme == .dark ? Color(white: 0.95) : Color.ink
    }
}

/// UIKit wrapper so we can control intrinsic height of the segmented control
/// while keeping iOS 26's native drag-to-switch liquid-glass lens.
private struct SegmentedTabPicker: UIViewRepresentable {
    @Binding var selected: AppTab
    let height: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(selected: $selected)
    }

    func makeUIView(context: Context) -> SizedSegmentedControl {
        let control = SizedSegmentedControl(items: [
            String(localized: "Today"),
            String(localized: "People")
        ])
        control.targetHeight = height
        control.selectedSegmentIndex = AppTab.today == selected ? 0 : 1
        control.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
        control.setTitleTextAttributes(
            [
                .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                .foregroundColor: UIColor.label
            ],
            for: .selected
        )
        control.setTitleTextAttributes(
            [
                .font: UIFont.systemFont(ofSize: 15, weight: .medium),
                .foregroundColor: UIColor.secondaryLabel
            ],
            for: .normal
        )
        return control
    }

    func updateUIView(_ control: SizedSegmentedControl, context: Context) {
        let index = selected == .today ? 0 : 1
        if control.selectedSegmentIndex != index {
            control.selectedSegmentIndex = index
        }
        control.targetHeight = height
        context.coordinator.selected = $selected
    }

    final class Coordinator: NSObject {
        var selected: Binding<AppTab>
        init(selected: Binding<AppTab>) {
            self.selected = selected
        }

        @MainActor @objc
        func changed(_ sender: UISegmentedControl) {
            let newValue: AppTab = sender.selectedSegmentIndex == 0 ? .today : .people
            withAnimation(.weftSpring) { selected.wrappedValue = newValue }
        }
    }
}

/// Subclass that overrides intrinsicContentSize so we can grow the
/// native segmented control taller than its default 32pt while keeping
/// all of iOS 26's gesture + glass behavior.
private final class SizedSegmentedControl: UISegmentedControl {
    var targetHeight: CGFloat = 56 {
        didSet { invalidateIntrinsicContentSize() }
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = targetHeight
        return size
    }
}

private struct ThinPlus: View {
    let color: Color
    let size: CGFloat
    let lineWidth: CGFloat

    var body: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(color)
                .frame(width: lineWidth, height: size)
            Capsule(style: .continuous)
                .fill(color)
                .frame(width: size, height: lineWidth)
        }
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color.bg.ignoresSafeArea()
        WeftTabBar(selected: .constant(.today), onAdd: {})
            .padding(.horizontal, Spacing.l)
            .padding(.bottom, 12)
    }
}
