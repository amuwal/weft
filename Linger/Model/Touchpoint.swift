import Foundation
import SwiftData

@Model
final class Touchpoint {
    var id: UUID
    var createdAt: Date
    var kindRaw: String
    var person: Person?

    init(kind: Kind, person: Person, createdAt: Date = .now) {
        self.id = UUID()
        self.kindRaw = kind.rawValue
        self.person = person
        self.createdAt = createdAt
    }

    var kind: Kind {
        get { Kind(rawValue: kindRaw) ?? .note }
        set { kindRaw = newValue.rawValue }
    }

    enum Kind: String, Codable {
        case note
        case markedCaughtUp
        case imported
        case snoozed
    }
}
