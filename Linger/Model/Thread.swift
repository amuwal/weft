import Foundation
import SwiftData

@Model
final class Thread {
    var id: UUID
    var body: String
    var dueDate: Date
    var resolvedAt: Date?
    var person: Person?
    var sourceNoteId: UUID?

    init(body: String, dueDate: Date, person: Person, sourceNoteId: UUID? = nil) {
        self.id = UUID()
        self.body = body
        self.dueDate = dueDate
        self.person = person
        self.sourceNoteId = sourceNoteId
    }

    var isOpen: Bool {
        resolvedAt == nil
    }
}
