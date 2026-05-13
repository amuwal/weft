import SwiftUI

struct SettingsView: View {
    @AppStorage("nudgeHour") private var nudgeHour: Int = 9
    @AppStorage("iCloudSyncEnabled") private var syncEnabled: Bool = true

    var body: some View {
        Form {
            Section("Sync") {
                Toggle("iCloud sync", isOn: $syncEnabled)
                LabeledContent("Status", value: syncEnabled ? "On" : "Off")
            }

            Section("Reminders") {
                Stepper("Daily nudge: \(nudgeHour):00", value: $nudgeHour, in: 6 ... 20)
            }

            Section("Appearance") {
                NavigationLink("Theme") { Text("Auto / Light / Dark") }
                NavigationLink("Accent") { Text("Sage / Slate / Warm / Rose") }
            }

            Section("Data") {
                Button("Export to PDF / Markdown", action: {})
                Button("Delete all data", role: .destructive, action: {})
            }

            Section("About") {
                LabeledContent("Linger Premium", value: "Trial")
                Button("Send feedback", action: {})
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
