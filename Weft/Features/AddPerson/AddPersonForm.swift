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
    @State private var birthdayYearKnown = true

    var body: some View {
        Form {
            Section("Name") {
                TextField("Their name", text: $name)
                    .font(WeftFont.body)
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
                Toggle("Birthday", isOn: $includeBirthday.animation(.weftSpring))
                if includeBirthday {
                    BirthdayField(date: $birthday, yearKnown: $birthdayYearKnown)
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
            birthday: includeBirthday ? birthday : nil,
            birthdayYearKnown: includeBirthday ? birthdayYearKnown : true
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
