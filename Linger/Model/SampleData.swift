import Foundation
import SwiftData

enum SampleData {
    @MainActor
    static func populate(_ context: ModelContext) {
        let sarah = Person(name: "Sarah", relationship: .inner, rhythm: .weekly, avatarPalette: .rose)
        let david = Person(name: "David", relationship: .inner, rhythm: .biweekly, avatarPalette: .slate)
        let priya = Person(name: "Priya", relationship: .close, rhythm: .monthly, avatarPalette: .warm)
        let mom = Person(name: "Mom", relationship: .family, rhythm: .weekly, avatarPalette: .warm)

        context.insert(sarah)
        context.insert(david)
        context.insert(priya)
        context.insert(mom)

        let april22 = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 22)) ?? .now
        let note = Note(
            body: "Coffee at Verve. She's been worried about her mom's upcoming surgery on the 14th. Started a new book on grief — Joan Didion.",
            person: sarah,
            createdAt: april22
        )
        context.insert(note)
        context.insert(Touchpoint(kind: .note, person: sarah, createdAt: april22))

        let dueMay16 = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 16)) ?? .now
        context.insert(Thread(
            body: "Follow up on her mom's surgery",
            dueDate: dueMay16,
            person: sarah,
            sourceNoteId: note.id
        ))
    }
}
