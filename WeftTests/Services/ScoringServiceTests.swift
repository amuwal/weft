import Foundation
import Testing
@testable import Weft

struct ScoringServiceTests {
    private func input(
        id: UUID = UUID(),
        last: Date? = nil,
        created: Date = .now.addingTimeInterval(-365 * 86400),
        rhythm: Rhythm = .weekly,
        weight: Double = 1.0,
        birthday: Date? = nil,
        threadDue: Date? = nil
    ) -> ScoreInput {
        ScoreInput(
            id: id,
            lastTouchedAt: last,
            createdAt: created,
            rhythm: rhythm,
            weight: weight,
            birthday: birthday,
            earliestOpenThreadDue: threadDue
        )
    }

    @Test
    func skipsPeopleWithinRhythm() {
        let now = Date.now
        let recent = now.addingTimeInterval(-3 * 86400)
        let ranked = ScoringService.ranked(
            people: [input(last: recent, rhythm: .weekly)],
            now: now
        )
        #expect(ranked.isEmpty)
    }

    @Test
    func capsRhythmPicksAtFive() {
        let now = Date.now
        let stale = now.addingTimeInterval(-90 * 86400)
        let inputs = (0 ..< 8).map { _ in input(last: stale, rhythm: .weekly) }
        let ranked = ScoringService.ranked(people: inputs, now: now)
        #expect(ranked.count == ScoringService.rhythmCap)
    }

    @Test
    func weightsBreakTies() {
        let now = Date.now
        let stale = now.addingTimeInterval(-90 * 86400)
        let lowID = UUID()
        let highID = UUID()
        let ranked = ScoringService.ranked(
            people: [
                input(id: lowID, last: stale, weight: 0.2),
                input(id: highID, last: stale, weight: 1.0)
            ],
            now: now
        )
        #expect(ranked.first?.personID == highID)
    }

    @Test
    func overdueThreadAlwaysSurfaces() {
        let now = Date.now
        let yesterday = now.addingTimeInterval(-86400)
        let touchedRecently = now.addingTimeInterval(-1 * 86400)
        let pid = UUID()
        let ranked = ScoringService.ranked(
            people: [
                input(
                    id: pid,
                    last: touchedRecently,
                    rhythm: .monthly,
                    threadDue: yesterday
                )
            ],
            now: now
        )
        #expect(ranked.first?.personID == pid)
        if case .threadDue = ranked.first?.reason {} else {
            Issue.record("expected threadDue reason")
        }
    }

    @Test
    func threadDueInFutureDoesNotSurface() {
        let now = Date.now
        let nextWeek = now.addingTimeInterval(7 * 86400)
        let ranked = ScoringService.ranked(
            people: [
                input(
                    last: now.addingTimeInterval(-1 * 86400),
                    rhythm: .monthly,
                    threadDue: nextWeek
                )
            ],
            now: now
        )
        #expect(ranked.isEmpty)
    }

    @Test
    func brandNewPersonDoesNotSurface() {
        let now = Date.now
        // Created an hour ago, no notes, rhythm weekly. Should NOT surface
        // because elapsed-since-creation < rhythm.
        let pid = UUID()
        let ranked = ScoringService.ranked(
            people: [
                input(id: pid, last: nil, created: now.addingTimeInterval(-3600), rhythm: .weekly)
            ],
            now: now
        )
        #expect(ranked.isEmpty)
    }

    @Test
    func rhythmNoneSkipsTimeBased() {
        let now = Date.now
        let stale = now.addingTimeInterval(-365 * 86400)
        let ranked = ScoringService.ranked(
            people: [input(last: stale, rhythm: .none)],
            now: now
        )
        #expect(ranked.isEmpty)
    }

    @Test
    func birthdaySurfacesOnTheDay() throws {
        let now = Date.now
        let cal = Calendar.current
        let comps = cal.dateComponents([.month, .day], from: now)
        // Birthday year-shifted to a past year, same month/day.
        var bdayComps = comps
        bdayComps.year = 1990
        let bday = try #require(cal.date(from: bdayComps))
        let pid = UUID()
        let ranked = ScoringService.ranked(
            people: [
                input(
                    id: pid,
                    last: now.addingTimeInterval(-1 * 86400),
                    rhythm: .monthly,
                    birthday: bday
                )
            ],
            now: now
        )
        #expect(ranked.first?.personID == pid)
        if case .birthday = ranked.first?.reason {} else {
            Issue.record("expected birthday reason")
        }
    }

    @Test
    func threadsOrderBeforeBirthdaysBeforeRhythm() throws {
        let now = Date.now
        let cal = Calendar.current
        let bdayComps = cal.dateComponents([.month, .day], from: now)
        var c = bdayComps
        c.year = 1990
        let bday = try #require(cal.date(from: c))

        let threadPID = UUID()
        let bdayPID = UUID()
        let rhythmPID = UUID()

        let ranked = ScoringService.ranked(
            people: [
                input(id: rhythmPID, last: now.addingTimeInterval(-90 * 86400), rhythm: .weekly),
                input(id: bdayPID, last: now.addingTimeInterval(-1 * 86400), birthday: bday),
                input(
                    id: threadPID,
                    last: now.addingTimeInterval(-1 * 86400),
                    threadDue: now.addingTimeInterval(-86400)
                )
            ],
            now: now
        )
        #expect(ranked.map(\.personID) == [threadPID, bdayPID, rhythmPID])
    }

    @Test
    func totalCapNeverExceeded() {
        let now = Date.now
        let stale = now.addingTimeInterval(-365 * 86400)
        let yesterday = now.addingTimeInterval(-86400)
        // 6 thread-overdue (always shown) + 5 rhythm = 11. Total cap is 8.
        let threadInputs = (0 ..< 6).map { _ in input(last: yesterday, threadDue: yesterday) }
        let rhythmInputs = (0 ..< 5).map { _ in input(last: stale) }
        let ranked = ScoringService.ranked(people: threadInputs + rhythmInputs, now: now)
        #expect(ranked.count == ScoringService.totalCap)
    }
}
