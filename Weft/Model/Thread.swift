import Foundation
import SwiftData

@Model
final class Thread {
    // Defaults required by CloudKit's schema mirror; `init` overwrites them.
    var id = UUID()
    var body: String = ""
    var dueDate = Date.now
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
