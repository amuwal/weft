import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.openURL) private var openURL
    @Query private var people: [Person]
    @Query private var notes: [Note]

    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @AppStorage("nudgeHour") private var nudgeHour: Int = 9
    @AppStorage("iCloudSyncEnabled") private var syncEnabled: Bool = true
    @AppStorage("dailyNudgeEnabled") private var nudgeEnabled: Bool = true
    @AppStorage("themeRaw") private var themeRaw: String = ThemeChoice.auto.rawValue
    @AppStorage("accentRaw") private var accentRaw: String = AccentChoice.sage.rawValue

    @State private var exportItem: ExportItem?
    @State private var showResetInline = false

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

            Section("Data") {
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
                        onCancel: { withAnimation(.lingerSpring) { showResetInline = false } }
                    )
                } else {
                    Button(role: .destructive) {
                        withAnimation(.lingerSpring) { showResetInline = true }
                    } label: {
                        Label("Delete all data", systemImage: "trash")
                    }
                }
            }

            Section("About") {
                LabeledContent("Version", value: "0.1.0 · build 1")
                LabeledContent("Linger Premium") {
                    Text("Trial").foregroundStyle(Color.sage)
                }
                Button {
                    Haptic.soft.play()
                    openFeedbackMail()
                } label: {
                    Label("Send feedback", systemImage: "envelope")
                }
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

    private func openFeedbackMail() {
        let subject = "Linger feedback (v0.1.0)"
        let body = "What's on your mind?\n\n\n— Sent from Linger on iOS"
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "1mitccc@gmail.com"
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        guard let url = components.url else { return }
        openURL(url)
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
                .font(LingerFont.caption)
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
        case .auto: "Auto"
        case .light: "Light"
        case .dark: "Dark"
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
}
