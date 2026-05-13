import Foundation
import Testing
@testable import Linger

struct ScoringServiceTests {
    @Test
    func skipsPeopleWithinRhythm() {
        let now = Date.now
        let recent = now.addingTimeInterval(-3 * 86400)
        let ranked = ScoringService.ranked(
            people: [ScoreInput(id: UUID(), lastTouchedAt: recent, rhythm: .weekly, weight: 1.0)],
            now: now
        )
        #expect(ranked.isEmpty)
    }

    @Test
    func capsResultsToThree() {
        let now = Date.now
        let stale = now.addingTimeInterval(-90 * 86400)
        let inputs = (0 ..< 5).map { _ in
            ScoreInput(id: UUID(), lastTouchedAt: stale, rhythm: .weekly, weight: 1.0)
        }
        let ranked = ScoringService.ranked(people: inputs, now: now)
        #expect(ranked.count == 3)
    }

    @Test
    func weightsBreakTies() {
        let now = Date.now
        let stale = now.addingTimeInterval(-90 * 86400)
        let lowID = UUID()
        let highID = UUID()
        let ranked = ScoringService.ranked(
            people: [
                ScoreInput(id: lowID, lastTouchedAt: stale, rhythm: .weekly, weight: 0.2),
                ScoreInput(id: highID, lastTouchedAt: stale, rhythm: .weekly, weight: 1.0)
            ],
            now: now
        )
        #expect(ranked.first == highID)
    }
}
