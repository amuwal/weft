import SwiftData
import SwiftUI

struct AddPersonForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var name = ""
    @State private var relationship: RelationshipType = .close
    @State private var rhythm: Rhythm = .monthly
    @State private var includeBirthday = false
    @State private var birthday: Date = .now

    var body: some View {
        Form {
            Section("Name") {
                TextField("Their name", text: $name)
                    .font(LingerFont.body)
            }

            Section("Relationship") {
                Picker("Relationship", selection: $relationship) {
                    ForEach(RelationshipType.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
            }

            Section("How often?") {
                Picker("Rhythm", selection: $rhythm) {
                    ForEach(Rhythm.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.menu)
            }

            Section {
                Toggle("Birthday", isOn: $includeBirthday.animation(.lingerSpring))
                if includeBirthday {
                    DatePicker("Date", selection: $birthday, displayedComponents: .date)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .navigationBarBackButtonHidden()
    }

    private func save() {
        let person = Person(
            name: name.trimmingCharacters(in: .whitespaces),
            relationship: relationship,
            rhythm: rhythm,
            birthday: includeBirthday ? birthday : nil
        )
        context.insert(person)
        Haptic.success.play()
        dismiss()
    }
}

#Preview {
    AddPersonForm()
        .modelContainer(.preview)
}
