import Foundation

struct ScoreInput {
    let id: UUID
    let lastTouchedAt: Date?
    /// Used as the floor for `lastTouchedAt` when the person has no notes or
    /// touchpoints yet — prevents brand-new people from instantly hitting Today.
    let createdAt: Date
    let rhythm: Rhythm
    let weight: Double
    let birthday: Date?
    /// Earliest `dueDate` across the person's open (unresolved) threads, or
    /// `nil` if they have none.
    let earliestOpenThreadDue: Date?
}

/// Why a person surfaced on Today, in display priority.
enum SurfaceReason: Comparable {
    /// Explicit follow-up the user set, now due. Highest priority.
    case threadDue(daysOverdue: Double)
    /// Today is their birthday. One-day window.
    case birthday
    /// Rhythm elapsed since the last touchpoint.
    case onRhythm(ratio: Double, weight: Double)

    /// Lower = earlier in the list.
    private var bucket: Int {
        switch self {
        case .threadDue: 0
        case .birthday: 1
        case .onRhythm: 2
        }
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.bucket != rhs.bucket { return lhs.bucket < rhs.bucket }
        switch (lhs, rhs) {
        case (.threadDue(let a), .threadDue(let b)):
            return a > b // most overdue first
        case (.onRhythm(let ra, let wa), .onRhythm(let rb, let wb)):
            return ra * wa > rb * wb // higher score first
        default:
            return false
        }
    }
}

struct ScoreCandidate {
    let personID: UUID
    let reason: SurfaceReason
}

enum ScoringService {
    /// How many time-based ("on rhythm") people to surface in addition to the
    /// always-shown thread/birthday picks. Most days will land at 0–3.
    static let rhythmCap = 5
    /// Absolute ceiling so the screen never feels noisy.
    static let totalCap = 8

    /// Returns the people to surface on Today, in display order:
    /// overdue threads → birthdays → on-rhythm. Snoozed people are filtered
    /// upstream — this service does not see them.
    static func ranked(people: [ScoreInput], now: Date = .now) -> [ScoreCandidate] {
        let cal = Calendar.current

        let pressing: [ScoreCandidate] = people.compactMap { input in
            guard let due = input.earliestOpenThreadDue, due <= now else { return nil }
            let overdue = now.timeIntervalSince(due) / 86400
            return ScoreCandidate(personID: input.id, reason: .threadDue(daysOverdue: overdue))
        }
        let pressingIDs = Set(pressing.map(\.personID))

        let birthdays: [ScoreCandidate] = people.compactMap { input in
            guard let bday = input.birthday else { return nil }
            guard cal.isDate(bday, equalTo: now, toGranularity: .day)
                || sameMonthDay(bday, now, calendar: cal) else { return nil }
            guard !pressingIDs.contains(input.id) else { return nil }
            return ScoreCandidate(personID: input.id, reason: .birthday)
        }
        let alreadySurfaced = pressingIDs.union(birthdays.map(\.personID))

        let onRhythm: [ScoreCandidate] = people.compactMap { input in
            guard !alreadySurfaced.contains(input.id) else { return nil }
            guard let days = input.rhythm.days else { return nil }
            let last = input.lastTouchedAt ?? input.createdAt
            let elapsed = now.timeIntervalSince(last) / 86400
            let ratio = elapsed / Double(days)
            guard ratio > 1.0 else { return nil }
            return ScoreCandidate(
                personID: input.id,
                reason: .onRhythm(ratio: ratio, weight: input.weight)
            )
        }
        .sorted { $0.reason < $1.reason }
        .prefix(rhythmCap)
        .map(\.self)

        let combined = pressing.sorted { $0.reason < $1.reason }
            + birthdays
            + onRhythm
        return Array(combined.prefix(totalCap))
    }

    /// Returns true if `a` and `b` share month + day (year-agnostic, for
    /// recurring birthdays).
    private static func sameMonthDay(_ a: Date, _ b: Date, calendar: Calendar) -> Bool {
        let lhs = calendar.dateComponents([.month, .day], from: a)
        let rhs = calendar.dateComponents([.month, .day], from: b)
        return lhs.month == rhs.month && lhs.day == rhs.day
    }
}
