import SwiftData
import SwiftUI

struct EditPersonSheet: View {
    let person: Person
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var name: String
    @State private var relationship: RelationshipType
    @State private var rhythm: Rhythm
    @State private var palette: AvatarPalette
    @State private var confirmingDelete = false

    init(person: Person) {
        self.person = person
        _name = State(initialValue: person.name)
        _relationship = State(initialValue: person.relationship)
        _rhythm = State(initialValue: person.rhythm)
        _palette = State(initialValue: person.avatarPalette)
    }

    var body: some View {
        Form {
            Section("Name") {
                TextField("Name", text: $name)
            }

            Section("Avatar") {
                HStack(spacing: 14) {
                    ForEach(AvatarPalette.allCases, id: \.self) { option in
                        Button { palette = option } label: {
                            PersonAvatar(
                                initial: String(name.prefix(1)).uppercased(),
                                palette: option,
                                size: 36
                            )
                            .overlay {
                                Circle()
                                    .strokeBorder(Color.ink, lineWidth: palette == option ? 2 : 0)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Relationship") {
                Picker("Relationship", selection: $relationship) {
                    ForEach(RelationshipType.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.menu)
            }

            Section("Rhythm") {
                Picker("Rhythm", selection: $rhythm) {
                    ForEach(Rhythm.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.menu)
            }

            Section {
                Button(role: .destructive) {
                    confirmingDelete = true
                } label: {
                    Label("Delete person", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Edit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: dismiss.callAsFunction)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .confirmationDialog(
            "Delete \(person.name) and all their notes?",
            isPresented: $confirmingDelete,
            titleVisibility: .visible
        ) {
            Button("Delete \(person.name)", role: .destructive) {
                context.delete(person)
                try? context.save()
                Haptic.warning.play()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func save() {
        person.name = name.trimmingCharacters(in: .whitespaces)
        person.relationship = relationship
        person.rhythm = rhythm
        person.avatarPalette = palette
        try? context.save()
        Haptic.success.play()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        EditPersonSheet(
            person: Person(name: "Sarah", relationship: .inner, rhythm: .weekly, avatarPalette: .rose)
        )
    }
    .modelContainer(.preview)
}
