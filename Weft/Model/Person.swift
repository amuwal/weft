import Foundation
import SwiftData

@Model
final class Person {
    // Defaults are required by CloudKit: every non-optional attribute the
    // schema mirrors must be optional or carry a default. `init` overwrites
    // all of these — the defaults only satisfy CloudKit's schema check.
    var id = UUID()
    var name: String = ""
    var relationship = RelationshipType.other
    var rhythm = Rhythm.none
    var birthday: Date?
    var avatarPaletteRaw: String = AvatarPalette.sage.rawValue
    var createdAt = Date.now
    var pinned: Bool = false
    var snoozedUntil: Date?

    /// Optional collections are required by CloudKit's schema mirror.
    /// Treat `nil` as empty via the computed `*` accessors below.
    @Relationship(deleteRule: .cascade, inverse: \Note.person)
    var notes: [Note]?

    @Relationship(deleteRule: .cascade, inverse: \Thread.person)
    var threads: [Thread]?

    @Relationship(deleteRule: .cascade, inverse: \Touchpoint.person)
    var touchpoints: [Touchpoint]?

    init(
        name: String,
        relationship: RelationshipType,
        rhythm: Rhythm,
        birthday: Date? = nil,
        avatarPalette: AvatarPalette = .sage,
        pinned: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.relationship = relationship
        self.rhythm = rhythm
        self.birthday = birthday
        self.avatarPaletteRaw = avatarPalette.rawValue
        self.createdAt = .now
        self.pinned = pinned
    }

    var avatarPalette: AvatarPalette {
        get { AvatarPalette(rawValue: avatarPaletteRaw) ?? .sage }
        set { avatarPaletteRaw = newValue.rawValue }
    }

    var initial: String {
        String(name.prefix(1)).uppercased()
    }

    var notesOrEmpty: [Note] {
        notes ?? []
    }

    var threadsOrEmpty: [Thread] {
        threads ?? []
    }

    var touchpointsOrEmpty: [Touchpoint] {
        touchpoints ?? []
    }

    var isSnoozed: Bool {
        guard let snoozedUntil else { return false }
        return snoozedUntil > .now
    }
}

enum RelationshipType: String, Codable, CaseIterable, Identifiable {
    case inner
    case close
    case family
    case work
    case other

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .inner: "Inner circle"
        case .close: "Close friends"
        case .family: "Family"
        case .work: "Work"
        case .other: "Other"
        }
    }

    /// Higher numbers surface earlier on Today when overdue ratio ties.
    var weight: Double {
        switch self {
        case .inner: 1.0
        case .family: 0.7
        case .close: 0.55
        case .work: 0.25
        case .other: 0.15
        }
    }
}

enum Rhythm: Int, Codable, CaseIterable, Identifiable {
    case weekly = 7
    case biweekly = 14
    case monthly = 30
    case quarterly = 90
    case none = 0

    var id: Int {
        rawValue
    }

    var label: String {
        switch self {
        case .weekly: "weekly"
        case .biweekly: "biweekly"
        case .monthly: "monthly"
        case .quarterly: "quarterly"
        case .none: "no schedule"
        }
    }

    /// Returns the days threshold, or `nil` when the person has no schedule.
    var days: Int? {
        self == .none ? nil : rawValue
    }
}

enum AvatarPalette: String, Codable, CaseIterable {
    case sage, warm, slate, rose, clay, lilac, blue
}
