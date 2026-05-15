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
    @FocusState private var editorFocused: Bool

    init(prefilledPerson: Person? = nil) {
        _selectedPersonID = State(initialValue: prefilledPerson?.id)
    }

    var body: some View {
        Form {
            Section("Person") {
                Picker("Person", selection: $selectedPersonID) {
                    Text("Choose…").tag(UUID?.none)
                    ForEach(people) { Text($0.name).tag(Optional($0.id)) }
                }
                .pickerStyle(.menu)
            }

            Section("Note") {
                TextEditor(text: $noteText)
                    .frame(minHeight: 160)
                    .font(WeftFont.serifBody)
                    .focused($editorFocused)
                    .scrollContentBackground(.hidden)
            }

            Section {
                Toggle("Follow up on this", isOn: $followUp.animation(.weftSpring))
                if followUp {
                    DatePicker("Remind on", selection: $followUpDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .disabled(canSave == false)
            }
        }
        .onAppear {
            if selectedPersonID == nil { selectedPersonID = people.first?.id }
            editorFocused = true
        }
    }

    private var canSave: Bool {
        selectedPersonID != nil && !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        guard let pid = selectedPersonID,
              let person = people.first(where: { $0.id == pid })
        else { return }
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
        try? context.save()
        Haptic.success.play()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        AddNoteForm()
    }
    .modelContainer(.preview)
}
