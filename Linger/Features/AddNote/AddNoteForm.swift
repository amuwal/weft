import SwiftData
import SwiftUI

struct AddNoteForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \Person.name) private var people: [Person]

    @State private var selectedPersonID: UUID?
    @State private var noteText: String = ""
    @State private var followUp = false
    @State private var followUpDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now

    var body: some View {
        Form {
            Section("Person") {
                Picker("Person", selection: $selectedPersonID) {
                    ForEach(people) { person in
                        Text(person.name).tag(Optional(person.id))
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Note") {
                TextEditor(text: $noteText)
                    .frame(minHeight: 140)
                    .font(LingerFont.serifBody)
            }

            Section {
                Toggle("Follow up on this", isOn: $followUp.animation(.lingerSpring))
                if followUp {
                    DatePicker("Remind on", selection: $followUpDate, displayedComponents: .date)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty || selectedPersonID == nil)
            }
        }
        .onAppear {
            if selectedPersonID == nil { selectedPersonID = people.first?.id }
        }
    }

    private func save() {
        guard let pid = selectedPersonID,
              let person = people.first(where: { $0.id == pid }) else { return }
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        let note = Note(body: trimmed, person: person)
        context.insert(note)
        context.insert(Touchpoint(kind: .note, person: person))
        if followUp {
            context.insert(Thread(
                body: "Follow up",
                dueDate: followUpDate,
                person: person,
                sourceNoteId: note.id
            ))
        }
        Haptic.success.play()
        dismiss()
    }
}

#Preview {
    AddNoteForm()
        .modelContainer(.preview)
}
