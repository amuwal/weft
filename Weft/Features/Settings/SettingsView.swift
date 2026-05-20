import SwiftData
import SwiftUI
import UIKit

/// The two premium-related sheets, driven by a single `.sheet(item:)`. Two
/// adjacent `.sheet(isPresented:)` modifiers on one view don't both present
/// reliably, so they're unified here.
enum PremiumSheet: Identifiable {
    case paywall
    case status

    var id: Self {
        self
    }
}

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
    @State private var premiumSheet: PremiumSheet?
    /// True when the user changed a value (sync toggle or premium state)
    /// that the SwiftData container only reads at app launch.
    @State private var syncRestartHint = false
    /// Snapshot of `entitlements.isPremium` taken when this view first appears,
    /// so we can detect a same-session upgrade/downgrade and surface the same
    /// "restart required" hint we show for the sync toggle.
    @State private var premiumAtAppear: Bool?
    @State private var restoreEmpty = false
    /// Live CloudKit account availability, seeded from the cached value and
    /// refreshed on appear via `CKContainer.accountStatus()`.
    @State private var iCloudAccountAvailable = ModelContainer.hasICloudAccount

    var body: some View {
        Form {
            Section {
                LabeledContent("People", value: "\(people.count) / 7")
                LabeledContent("Notes", value: "\(notes.count)")
            } header: { Text("Library") }

            SyncSection(
                syncEnabled: $syncEnabled,
                syncRestartHint: $syncRestartHint,
                onUpgrade: { premiumSheet = .paywall },
                isPremium: entitlements.isPremium,
                syncActive: syncActive,
                needsRelaunchForData: syncNeedsRelaunch,
                hasICloudAccount: iCloudAccountAvailable
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

            SubscriptionSection(
                peopleCount: people.count,
                setSheet: { premiumSheet = $0 },
                restoreEmpty: $restoreEmpty
            )

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
                LabeledContent("Version", value: Self.bundleVersion)
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
        .sheet(item: $premiumSheet) { sheet in
            NavigationStack {
                switch sheet {
                case .paywall: PaywallView()
                case .status: PremiumStatusView()
                }
            }
            .presentationDetents([.large])
            .presentationCornerRadius(28)
            .presentationBackground(.regularMaterial)
        }
        .onAppear {
            if premiumAtAppear == nil { premiumAtAppear = entitlements.isPremium }
        }
        .task {
            iCloudAccountAvailable = await ModelContainer.refreshICloudAccountStatus()
        }
        .onChange(of: entitlements.isPremium) { _, newValue in
            // If premium state flips while Settings is open, the SwiftData
            // container's sync config is now stale until the user relaunches.
            if let snapshot = premiumAtAppear, snapshot != newValue {
                syncRestartHint = true
            }
        }
        .alert("Nothing to restore", isPresented: $restoreEmpty) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("No active Weft Premium purchase found on this Apple ID.")
        }
    }

    /// True only when sync is genuinely flowing: Premium + toggle on (the
    /// container's gate) *and* an iCloud account is available. Without the
    /// account, the container still attaches CloudKit but no data moves, so the
    /// status row reports `needsAccount` rather than a misleading "On".
    private var syncActive: Bool {
        ModelContainer.syncShouldBeActive && iCloudAccountAvailable
    }

    /// Sync is configured and possible (Premium + toggle + account), but the
    /// container opened local-only at launch — so existing CloudKit data won't
    /// appear until the next launch. Drives the "Relaunch to sync" hint.
    private var syncNeedsRelaunch: Bool {
        syncActive && !ModelContainer.cloudKitAttachedAtLaunch
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
                premiumSheet = .paywall
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

    private func formattedHour(_ hour: Int) -> String {
        var components = DateComponents()
        components.hour = hour
        let date = Calendar.current.date(from: components) ?? .now
        return date.formatted(.dateTime.hour())
    }

    private static let bundleVersion: String = {
        let info = Bundle.main.infoDictionary
        let v = info?["CFBundleShortVersionString"] as? String ?? "?"
        let b = info?["CFBundleVersion"] as? String ?? "?"
        return "\(v) · build \(b)"
    }()
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
