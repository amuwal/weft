import Foundation

struct ScoreInput {
    let id: UUID
    let lastTouchedAt: Date?
    let rhythm: Rhythm
    let weight: Double
}

struct ScoreCandidate {
    let personID: UUID
    let overdueRatio: Double
    let relationshipWeight: Double
    var score: Double {
        overdueRatio * relationshipWeight
    }
}

enum ScoringService {
    /// Returns up to `cap` person IDs to surface on Today, highest score first.
    static func ranked(
        people: [ScoreInput],
        now: Date = .now,
        cap: Int = 3
    ) -> [UUID] {
        let candidates: [ScoreCandidate] = people.compactMap { input in
            guard let days = input.rhythm.days else { return nil }
            let last = input.lastTouchedAt ?? .distantPast
            let elapsed = now.timeIntervalSince(last) / 86400
            let ratio = elapsed / Double(days)
            guard ratio > 1.0 else { return nil }
            return ScoreCandidate(personID: input.id, overdueRatio: ratio, relationshipWeight: input.weight)
        }

        return candidates
            .sorted { $0.score > $1.score }
            .prefix(cap)
            .map(\.personID)
    }
}
