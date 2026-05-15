import Foundation
import SwiftData

@Model
final class Note {
    // Defaults required by CloudKit's schema mirror; `init` overwrites them.
    var id = UUID()
    var body: String = ""
    var createdAt = Date.now
    var person: Person?

    init(body: String, person: Person, createdAt: Date = .now) {
        self.id = UUID()
        self.body = body
        self.person = person
        self.createdAt = createdAt
    }
}
