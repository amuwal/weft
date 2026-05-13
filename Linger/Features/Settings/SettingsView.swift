import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var people: [Person]
    @Query private var notes: [Note]

    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @AppStorage("nudgeHour") private var nudgeHour: Int = 9
    @AppStorage("iCloudSyncEnabled") private var syncEnabled: Bool = true
    @AppStorage("dailyNudgeEnabled") private var nudgeEnabled: Bool = true
    @AppStorage("themeRaw") private var themeRaw: String = ThemeChoice.auto.rawValue
    @AppStorage("accentRaw") private var accentRaw: String = AccentChoice.sage.rawValue

    @State private var confirmingReset = false

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
                    Stepper("Time: \(nudgeHour):00", value: $nudgeHour, in: 6 ... 20)
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
                } label: {
                    Label("Export Markdown", systemImage: "square.and.arrow.up")
                }
                Button(role: .destructive) {
                    confirmingReset = true
                } label: {
                    Label("Delete all data", systemImage: "trash")
                }
            }

            Section("About") {
                LabeledContent("Version", value: "0.1.0 · build 1")
                LabeledContent("Linger Premium") {
                    Text("Trial").foregroundStyle(Color.sage)
                }
                Button {
                    Haptic.soft.play()
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
        .confirmationDialog(
            "Delete every person, every note, every thread?",
            isPresented: $confirmingReset,
            titleVisibility: .visible
        ) {
            Button("Delete everything", role: .destructive, action: wipe)
            Button("Cancel", role: .cancel) {}
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
