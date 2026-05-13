import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID
    var body: String
    var createdAt: Date
    var person: Person?

    init(body: String, person: Person, createdAt: Date = .now) {
        self.id = UUID()
        self.body = body
        self.person = person
        self.createdAt = createdAt
    }
}
