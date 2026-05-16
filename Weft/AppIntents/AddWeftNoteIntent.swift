import AppIntents
import Foundation
import SwiftData

/// "Add a Weft note about Sarah saying she's loving the new book."
///
/// The intent surface is free for all users — Premium gating happens at the
/// UI level (the AddNote photo row), not on the data-write layer. Anyone with
/// the app should be able to capture a sentence; that's the brand promise.
struct AddWeftNoteIntent: AppIntent {
    static let title: LocalizedStringResource = "Add a note"
    static let description = IntentDescription(
        "Capture a sentence about someone. The note appears in their detail view and contributes to the Today rhythm.",
        categoryName: "Notes"
    )
    static let openAppWhenRun: Bool = false

    @Parameter(title: "Person", description: "The person this note is about.")
    var person: PersonEntity

    @Parameter(
        title: "Note",
        description: "What you want to remember.",
        inputOptions: .init(multiline: true)
    )
    var body: String

    static var parameterSummary: some ParameterSummary {
        Summary("Add note about \(\.$person): \(\.$body)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw $body.needsValueError("What would you like the note to say?")
        }

        try await MainActor.run {
            let container = try ModelContainer.weft()
            let context = ModelContext(container)
            var descriptor = FetchDescriptor<Person>()
            let targetID = person.id
            descriptor.predicate = #Predicate { $0.id == targetID }
            guard let target = try context.fetch(descriptor).first else {
                throw $person.needsValueError("Couldn't find \(person.name) in Weft.")
            }
            let note = Note(body: trimmed, person: target)
            context.insert(note)
            context.insert(Touchpoint(kind: .note, person: target))
            try context.save()
        }

        return .result(dialog: "Saved a note about \(person.name).")
    }
}
