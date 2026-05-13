import Foundation
import SwiftData

enum SampleData {
    @MainActor
    static func populate(_ context: ModelContext) {
        let now = Date.now
        let cal = Calendar.current
        let day: (Int) -> Date = { cal.date(byAdding: .day, value: -$0, to: now) ?? now }

        let sarah = Person(name: "Sarah", relationship: .inner, rhythm: .weekly, avatarPalette: .rose)
        let david = Person(name: "David", relationship: .inner, rhythm: .biweekly, avatarPalette: .slate)
        let priya = Person(name: "Priya", relationship: .close, rhythm: .monthly, avatarPalette: .warm)
        let mom = Person(name: "Mom", relationship: .family, rhythm: .weekly, avatarPalette: .warm)
        let alex = Person(name: "Alex", relationship: .close, rhythm: .monthly, avatarPalette: .clay)
        let dad = Person(name: "Dad", relationship: .family, rhythm: .biweekly, avatarPalette: .clay)

        for person in [sarah, david, priya, mom, alex, dad] {
            context.insert(person)
        }

        let sarahNote = Note(
            body: "Coffee at Verve. She's been worried about her mom's upcoming surgery on the 14th. "
                + "Started a new book on grief — Joan Didion. She lit up describing the prose.",
            person: sarah,
            createdAt: day(21)
        )
        context.insert(sarahNote)
        context.insert(Touchpoint(kind: .note, person: sarah, createdAt: day(21)))
        context.insert(Thread(
            body: "Follow up on her mom's surgery",
            dueDate: day(-3),
            person: sarah,
            sourceNoteId: sarahNote.id
        ))

        context.insert(Note(
            body: "Quick check-in by text. He's loving the new job. Wants to grab dinner soon.",
            person: david,
            createdAt: day(5)
        ))
        context.insert(Touchpoint(kind: .note, person: david, createdAt: day(5)))

        context.insert(Note(
            body: "She recommended The Bee Sting. Said it changed how she thinks about families.",
            person: priya,
            createdAt: day(35)
        ))
        context.insert(Touchpoint(kind: .note, person: priya, createdAt: day(35)))

        context.insert(Touchpoint(kind: .markedCaughtUp, person: mom, createdAt: day(8)))

        context.insert(Note(
            body: "Trip to Lisbon — he sent photos from Belém.",
            person: alex,
            createdAt: day(60)
        ))
        context.insert(Touchpoint(kind: .note, person: alex, createdAt: day(60)))

        context.insert(Touchpoint(kind: .markedCaughtUp, person: dad, createdAt: day(20)))
    }
}
