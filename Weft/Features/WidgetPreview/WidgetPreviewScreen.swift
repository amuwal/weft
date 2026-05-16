#if DEBUG
    import SwiftUI

    /// Debug-only screen for visually verifying widget output without driving
    /// iOS's widget gallery (which is fragile to drive via UI tap on the
    /// simulator). Launched via `--widget-preview` arg in `WeftApp`.
    /// Renders the same view code the widget extension renders, so what
    /// shows here is a faithful proxy for what the user gets on home screen.
    struct WidgetPreviewScreen: View {
        let entries: [(label: String, entry: WidgetPreviewEntry)]
        let currentlyPremium: Bool
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Widget previews")
                            .font(.system(size: 26, design: .serif).weight(.medium))
                            .foregroundStyle(Color.ink)
                        Text(currentlyPremium ? "App entitlement: Premium" : "App entitlement: Free")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(0.4)
                            .foregroundStyle(Color.muted)
                    }
                    .padding(.top, 12)

                    ForEach(entries.indices, id: \.self) { idx in
                        let label = entries[idx].label
                        let entry = entries[idx].entry
                        VStack(alignment: .leading, spacing: 10) {
                            Text(label)
                                .font(.system(size: 12, weight: .semibold))
                                .tracking(0.5)
                                .foregroundStyle(Color.muted)
                            entry.view
                                .frame(width: entry.width, height: entry.height)
                                .background(Color(red: 248 / 255, green: 245 / 255, blue: 239 / 255))
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .strokeBorder(Color.ink.opacity(0.08), lineWidth: 0.5)
                                )
                                .shadow(color: Color.black.opacity(0.08), radius: 16, y: 8)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 60)
            }
            .background(Color.bg.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    /// Renderable container for one widget shape + a label.
    struct WidgetPreviewEntry {
        let view: AnyView
        let width: CGFloat
        let height: CGFloat

        init(_ view: some View, width: CGFloat, height: CGFloat) {
            self.view = AnyView(view)
            self.width = width
            self.height = height
        }
    }
#endif
