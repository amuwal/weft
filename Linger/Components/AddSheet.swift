import SwiftUI

struct AddSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var mode: Mode = .note

    enum Mode: String, CaseIterable, Identifiable {
        case note
        case person

        var id: String {
            rawValue
        }

        var label: String {
            switch self {
            case .note: "Note"
            case .person: "Person"
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                switch mode {
                case .note: AddNoteForm()
                case .person: AddPersonForm()
                }
            }
            .navigationTitle("New")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("Mode", selection: $mode) {
                        ForEach(Mode.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: { dismiss() })
                }
            }
        }
    }
}

#Preview {
    AddSheet()
        .modelContainer(.preview)
}
