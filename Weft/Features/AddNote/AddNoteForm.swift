import PhotosUI
import SwiftData
import SwiftUI

struct AddNoteForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(Entitlements.self) private var entitlements
    @Query(sort: \Person.name) private var people: [Person]

    @State private var selectedPersonID: UUID?
    @State private var noteText: String = ""
    @State private var followUp = false
    @State private var followUpDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showPaywall = false
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
                photoRow
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
        .onChange(of: photoPickerItem) { _, newItem in
            loadPhoto(from: newItem)
        }
        .sheet(isPresented: $showPaywall) {
            NavigationStack { PaywallView() }
                .presentationDetents([.large])
                .presentationCornerRadius(28)
                .presentationBackground(.regularMaterial)
        }
    }

    @ViewBuilder
    private var photoRow: some View {
        if let data = photoData, let image = UIImage(data: data) {
            HStack(spacing: 12) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                Text("Photo attached")
                    .font(WeftFont.caption)
                    .foregroundStyle(Color.muted)
                Spacer()
                Button {
                    Haptic.soft.play()
                    photoData = nil
                    photoPickerItem = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.muted)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)
        } else if entitlements.isPremium {
            PhotosPicker(selection: $photoPickerItem, matching: .images, photoLibrary: .shared()) {
                Label("Add photo", systemImage: "photo.badge.plus")
                    .foregroundStyle(Color.sage)
            }
        } else {
            Button {
                Haptic.soft.play()
                showPaywall = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "photo.badge.plus")
                        .foregroundStyle(Color.muted)
                    Text("Add photo")
                        .foregroundStyle(Color.muted)
                    Spacer()
                    Text("Premium")
                        .font(WeftFont.mini)
                        .foregroundStyle(Color.sage)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.sageWash, in: Capsule())
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var canSave: Bool {
        selectedPersonID != nil && !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func loadPhoto(from item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            guard let raw = try? await item.loadTransferable(type: Data.self) else { return }
            let compressed = await Task.detached { PhotoCompressor.compress(raw) }.value
            await MainActor.run { photoData = compressed }
        }
    }

    private func save() {
        guard let pid = selectedPersonID,
              let person = people.first(where: { $0.id == pid })
        else { return }
        let trimmed = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        // Photos attached during an active Premium session are kept regardless
        // of the user's current tier. If they downgrade later, the picker
        // surface gates *future* additions — but existing photos stay theirs
        // (mirrors how the people limit treats people added during Premium).
        let note = Note(body: trimmed, person: person, photoData: photoData)
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
    .environment(Entitlements())
}
