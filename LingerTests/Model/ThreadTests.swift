import Foundation
import SwiftData
import Testing
@testable import Linger

@MainActor
struct ThreadTests {
    @Test
    func newThreadIsOpen() {
        let person = Person(name: "Mom", relationship: .family, rhythm: .weekly)
        let thread = Thread(body: "Send recipe", dueDate: .now, person: person)
        #expect(thread.isOpen)
    }

    @Test
    func resolvedThreadIsNotOpen() {
        let person = Person(name: "Mom", relationship: .family, rhythm: .weekly)
        let thread = Thread(body: "Send recipe", dueDate: .now, person: person)
        thread.resolvedAt = .now
        #expect(!thread.isOpen)
    }

    @Test
    func threadStoresSourceNoteID() {
        let person = Person(name: "Mom", relationship: .family, rhythm: .weekly)
        let note = Note(body: "She mentioned a recipe", person: person)
        let thread = Thread(body: "Send recipe", dueDate: .now, person: person, sourceNoteId: note.id)
        #expect(thread.sourceNoteId == note.id)
    }
}
