import SwiftUI

struct AddSheet: View {
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

    @Environment(\.dismiss) private var dismiss
    @State private var mode: Mode

    init(initial: Mode = .note) {
        _mode = State(initialValue: initial)
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
                    Picker("Mode", selection: $mode.animation(.weftSpring)) {
                        ForEach(Mode.allCases) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
            }
        }
    }
}

#Preview {
    AddSheet()
        .modelContainer(.preview)
}
