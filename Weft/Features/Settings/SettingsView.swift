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

    var body: some View {
        Form {
            Section {
                LabeledContent("People", value: "\(people.count) / 7")
                LabeledContent("Notes", value: "\(notes.count)")
            } header: { Text("Library") }

            Section {
                Toggle("iCloud sync", isOn: $syncEnabled)
                LabeledContent("Status") {
                    HStack(spacing: 6) {
                        Image(systemName: syncEnabled ? "checkmark.icloud" : "icloud.slash")
                            .foregroundStyle(syncEnabled ? Color.sage : Color.muted)
                        Text(syncEnabled ? "On" : "Off")
                            .foregroundStyle(Color.muted)
                    }
                }
            } header: { Text("Sync") } footer: {
                Text("Your notes live on this device. iCloud sync is optional and end-to-end encrypted.")
            }

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

            Section {
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
            } header: {
                Text("Language")
            } footer: {
                Text("Some text updates after a full restart of the app.")
            }

            Section("Data") {
                Button {
                    Haptic.soft.play()
                    let url = PDFExporter.export(from: context)
                    exportItem = ExportItem(url: url)
                } label: {
                    Label("Export PDF", systemImage: "doc.richtext")
                }

                Button {
                    Haptic.soft.play()
                    let url = MarkdownExporter.export(from: context)
                    exportItem = ExportItem(url: url)
                } label: {
                    Label("Export Markdown", systemImage: "square.and.arrow.up")
                }

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
        case .auto: String(localized: "Auto")
        case .light: String(localized: "Light")
        case .dark: String(localized: "Dark")
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
