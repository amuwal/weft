import SwiftData
import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.openURL) private var openURL
    @Environment(Entitlements.self) private var entitlements
    @Query private var people: [Person]
    @Query private var notes: [Note]

    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @AppStorage("nudgeHour") private var nudgeHour: Int = 9
    @AppStorage("iCloudSyncEnabled") private var syncEnabled: Bool = true
    @AppStorage("dailyNudgeEnabled") private var nudgeEnabled: Bool = true
    @AppStorage("themeRaw") private var themeRaw: String = ThemeChoice.auto.rawValue
    @AppStorage("accentRaw") private var accentRaw: String = AccentChoice.sage.rawValue
    @AppStorage(AppLanguageStorage.key) private var preferredLanguage: String = AppLanguage.system.rawValue

    @State private var exportItem: ExportItem?
    @State private var showResetInline = false
    @State private var showPaywall = false
    /// True when the user changed a value (sync toggle or premium state)
    /// that the SwiftData container only reads at app launch.
    @State private var syncRestartHint = false
    /// Snapshot of `entitlements.isPremium` taken when this view first appears,
    /// so we can detect a same-session upgrade/downgrade and surface the same
    /// "restart required" hint we show for the sync toggle.
    @State private var premiumAtAppear: Bool?

    var body: some View {
        Form {
            Section {
                LabeledContent("People", value: "\(people.count) / 7")
                LabeledContent("Notes", value: "\(notes.count)")
            } header: { Text("Library") }

            SyncSection(
                syncEnabled: $syncEnabled,
                syncRestartHint: $syncRestartHint,
                showPaywall: $showPaywall,
                isPremium: entitlements.isPremium,
                syncActive: syncActive
            )

            Section {
                Toggle("Daily nudge", isOn: $nudgeEnabled)
                if nudgeEnabled {
                    Picker("Time", selection: $nudgeHour) {
                        ForEach(0 ..< 24, id: \.self) { hour in
                            Text(formattedHour(hour)).tag(hour)
                        }
                    }
                }
            } header: { Text("Reminders") } footer: {
                Text("A gentle list at this hour. No push if nobody is on your mind.")
            }
            .onChange(of: nudgeEnabled) { _, newValue in
                Task { await NudgeScheduler.sync(enabled: newValue, hour: nudgeHour) }
            }
            .onChange(of: nudgeHour) { _, newValue in
                Task { await NudgeScheduler.sync(enabled: nudgeEnabled, hour: newValue) }
            }

            Section("Appearance") {
                Picker("Theme", selection: $themeRaw) {
                    ForEach(ThemeChoice.allCases) { Text($0.label).tag($0.rawValue) }
                }
                .pickerStyle(.segmented)
                HStack(spacing: 14) {
                    Text("Accent")
                        .foregroundStyle(Color.muted)
                    Spacer()
                    ForEach(AccentChoice.allCases) { choice in
                        Button {
                            accentRaw = choice.rawValue
                            Haptic.selection.play()
                        } label: {
                            Circle()
                                .fill(choice.color)
                                .frame(width: 22, height: 22)
                                .overlay {
                                    Circle()
                                        .strokeBorder(
                                            Color.ink,
                                            lineWidth: accentRaw == choice.rawValue ? 2 : 0
                                        )
                                        .padding(-3)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Section("Language") {
                Picker("Language", selection: $preferredLanguage) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: preferredLanguage) { _, newValue in
                    if let lang = AppLanguage(rawValue: newValue) {
                        AppLanguageStorage.apply(lang)
                    }
                }
            }

            Section("Data") {
                exportRow(
                    title: "Export PDF",
                    systemImage: "doc.richtext",
                    action: { exportItem = ExportItem(url: PDFExporter.export(from: context)) }
                )
                exportRow(
                    title: "Export Markdown",
                    systemImage: "square.and.arrow.up",
                    action: { exportItem = ExportItem(url: MarkdownExporter.export(from: context)) }
                )

                if showResetInline {
                    InlineResetRow(
                        onConfirm: wipe,
                        onCancel: { withAnimation(.weftSpring) { showResetInline = false } }
                    )
                } else {
                    Button(role: .destructive) {
                        withAnimation(.weftSpring) { showResetInline = true }
                    } label: {
                        Label("Delete all data", systemImage: "trash")
                    }
                }
            }

            Section {
                Button {
                    Haptic.selection.play()
                    showPaywall = true
                } label: {
                    HStack {
                        Label("Weft Premium", systemImage: "sparkles")
                            .foregroundStyle(Color.ink)
                        Spacer()
                        Text(subscriptionStatusLabel)
                            .foregroundStyle(entitlements.isPremium ? Color.sage : Color.muted)
                            .font(WeftFont.caption)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.whisper)
                    }
                }
                .buttonStyle(.plain)

                Button {
                    Haptic.selection.play()
                    Task { await entitlements.presentRedeemSheet() }
                } label: {
                    HStack {
                        Label("Redeem a gift code", systemImage: "gift")
                            .foregroundStyle(Color.ink)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.whisper)
                    }
                }
                .buttonStyle(.plain)
            } header: { Text("Subscription") } footer: {
                Text(entitlements.isPremium
                    ? "Thanks for supporting Weft."
                    : "Unlock unlimited people, sync, widgets, and exports.")
            }

            Section("Help") {
                externalLinkRow(
                    "Send feedback",
                    systemImage: "envelope",
                    url: "https://getweft.xyz/feedback"
                )
                externalLinkRow(
                    "Request a feature",
                    systemImage: "lightbulb",
                    url: "https://getweft.xyz/feature-requests"
                )
            }

            Section("About") {
                LabeledContent("Version", value: "0.1.0 · build 1")
                externalLinkRow(
                    "Privacy",
                    systemImage: "lock",
                    url: "https://getweft.xyz/privacy"
                )
                externalLinkRow(
                    "Terms",
                    systemImage: "doc.text",
                    url: "https://getweft.xyz/terms"
                )
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: dismiss.callAsFunction)
            }
        }
        .sheet(item: $exportItem) { item in
            ActivityShareSheet(items: [item.url])
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showPaywall) {
            NavigationStack { PaywallView() }
                .presentationDetents([.large])
                .presentationCornerRadius(28)
                .presentationBackground(.regularMaterial)
        }
        .onAppear {
            if premiumAtAppear == nil { premiumAtAppear = entitlements.isPremium }
        }
        .onChange(of: entitlements.isPremium) { _, newValue in
            // If premium state flips while Settings is open, the SwiftData
            // container's sync config is now stale until the user relaunches.
            if let snapshot = premiumAtAppear, snapshot != newValue {
                syncRestartHint = true
            }
        }
    }

    /// Either a real Premium user (StoreKit) or a debug build with --premium.
    /// The container reads the same combined signal, so they stay in lockstep.
    private var syncActive: Bool {
        ModelContainer.syncShouldBeActive
    }

    private func exportRow(
        title: LocalizedStringKey,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            Haptic.soft.play()
            if entitlements.isPremium {
                action()
            } else {
                showPaywall = true
            }
        } label: {
            HStack {
                Label(title, systemImage: systemImage)
                    .foregroundStyle(entitlements.isPremium ? Color.ink : Color.muted)
                if !entitlements.isPremium {
                    Spacer()
                    Text("Premium")
                        .font(WeftFont.mini)
                        .foregroundStyle(Color.sage)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.sageWash, in: Capsule())
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func externalLinkRow(_ title: LocalizedStringKey, systemImage: String, url: String) -> some View {
        Button {
            Haptic.soft.play()
            if let target = URL(string: url) { openURL(target) }
        } label: {
            HStack {
                Label(title, systemImage: systemImage)
                    .foregroundStyle(Color.ink)
                Spacer()
                Image(systemName: "arrow.up.forward")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.whisper)
            }
        }
        .buttonStyle(.plain)
    }

    private func wipe() {
        for person in people {
            context.delete(person)
        }
        try? context.save()
        onboardingComplete = false
        Haptic.warning.play()
        dismiss()
    }

    private var subscriptionStatusLabel: String {
        if entitlements.isPremium { return "Premium · Active" }
        return "Free · \(people.count) / \(Entitlements.freePeopleLimit)"
    }

    private func formattedHour(_ hour: Int) -> String {
        var components = DateComponents()
        components.hour = hour
        let date = Calendar.current.date(from: components) ?? .now
        return date.formatted(.dateTime.hour())
    }
}

/// Sync section extracted so SettingsView's body stays under the lint cap.
/// Owns its own UI for the toggle, status badge, paywall nudge and the
/// "restart required" hint. State writes flow through the parent's bindings.
private struct SyncSection: View {
    @Binding var syncEnabled: Bool
    @Binding var syncRestartHint: Bool
    @Binding var showPaywall: Bool
    let isPremium: Bool
    let syncActive: Bool

    var body: some View {
        Section {
            Toggle("iCloud sync", isOn: $syncEnabled)
                .disabled(!isPremium)
                .onChange(of: syncEnabled) { _, _ in syncRestartHint = true }
            LabeledContent("Status") {
                HStack(spacing: 6) {
                    Image(systemName: syncActive ? "checkmark.icloud" : "icloud.slash")
                        .foregroundStyle(syncActive ? Color.sage : Color.muted)
                    Text(syncActive ? "On" : "Off")
                        .foregroundStyle(Color.muted)
                }
            }
            if !isPremium {
                upgradeRow
            }
            if syncRestartHint {
                restartHint
            }
        } header: { Text("Sync") } footer: {
            Text(
                "Your notes live on this device. iCloud sync is a Premium feature and end-to-end encrypted."
            )
        }
    }

    private var upgradeRow: some View {
        Button {
            Haptic.soft.play()
            showPaywall = true
        } label: {
            HStack {
                Label("Premium required", systemImage: "lock")
                    .foregroundStyle(Color.muted)
                Spacer()
                Text("Upgrade")
                    .font(WeftFont.mini)
                    .foregroundStyle(Color.sage)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.sageWash, in: Capsule())
            }
        }
        .buttonStyle(.plain)
    }

    private var restartHint: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.clockwise")
                .foregroundStyle(Color.muted)
            Text("Restart Weft for the change to take effect.")
                .font(WeftFont.caption)
                .foregroundStyle(Color.muted)
        }
    }
}

private struct InlineResetRow: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Delete every person, note and thread?")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.ink)
            Text("This cannot be undone.")
                .font(WeftFont.caption)
                .foregroundStyle(Color.muted)
            HStack(spacing: 8) {
                Button("Cancel", action: onCancel)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                Spacer()
                Button("Delete everything", role: .destructive, action: onConfirm)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}

private struct ExportItem: Identifiable {
    let id = UUID()
    let url: URL
}

enum ThemeChoice: String, CaseIterable, Identifiable {
    case auto, light, dark

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .auto: loc("Auto")
        case .light: loc("Light")
        case .dark: loc("Dark")
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .auto: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum AccentChoice: String, CaseIterable, Identifiable {
    case sage, slate, warm, rose

    var id: String {
        rawValue
    }

    var color: Color {
        switch self {
        case .sage: .sage
        case .slate: Color(red: 0.40, green: 0.50, blue: 0.60)
        case .warm: .warm
        case .rose: Color(red: 0.74, green: 0.40, blue: 0.45)
        }
    }
}

#Preview {
    NavigationStack { SettingsView() }
        .modelContainer(.preview)
        .environment(Entitlements())
}
