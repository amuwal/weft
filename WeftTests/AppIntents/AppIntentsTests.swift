import Foundation
import SwiftData
import Testing
@testable import Weft

/// End-to-end tests for the App Intents.
///
/// We can't run the actual `perform()` methods here — they call
/// `ModelContainer.weft()` internally, which opens the real on-disk store,
/// and tests shouldn't touch that. Instead we test the building blocks:
///   • `PersonEntity` reflects model state correctly
///   • The ScoringService glue inside `WhosOnYourMindTodayIntent` returns the
///     same shape as the Today view (re-uses ScoringService directly)
///   • `OpenPersonIntent` writes the rendezvous key the app reads
///
/// The simulator smoke test covers the live perform() path.
@MainActor
struct AppIntentsTests {
    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        return try ModelContainer(
            for: Person.self,
            Note.self,
            Thread.self,
            Touchpoint.self,
            configurations: config
        )
    }

    @Test
    func personEntityCarriesIDAndName() {
        let person = Person(name: "Sarah", relationship: .inner, rhythm: .weekly)
        let entity = PersonEntity(person: person)
        #expect(entity.id == person.id)
        #expect(entity.name == "Sarah")
    }

    @Test
    func openPersonIntentWritesPendingDeepLinkKey() async throws {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: PendingDeepLink.openPersonKey)
        let id = UUID()
        let entity = PersonEntity(id: id, name: "Test")
        let intent = OpenPersonIntent()
        intent.person = entity

        _ = try await intent.perform()

        let written = defaults.string(forKey: PendingDeepLink.openPersonKey)
        #expect(written == id.uuidString)
        defaults.removeObject(forKey: PendingDeepLink.openPersonKey)
    }

    /// Sanity-check that the Today intent's underlying scoring uses the same
    /// signal as the on-screen view. If TodayView and the intent ever drift,
    /// this catches it because both call `ScoringService.ranked`.
    @Test
    func todayScoringRanksTheRightPerson() throws {
        // `recent` contacted 3 days ago (within weekly rhythm → filtered).
        // `overdue` created 30 days ago, never touched (well past weekly → surfaces).
        let now = Date.now
        let inputs: [ScoreInput] = [
            ScoreInput(
                id: UUID(),
                lastTouchedAt: now.addingTimeInterval(-3 * 86400),
                createdAt: now.addingTimeInterval(-90 * 86400),
                rhythm: .weekly,
                weight: 0.55,
                birthday: nil,
                earliestOpenThreadDue: nil
            ),
            ScoreInput(
                id: UUID(),
                lastTouchedAt: nil,
                createdAt: now.addingTimeInterval(-30 * 86400),
                rhythm: .weekly,
                weight: 1.0,
                birthday: nil,
                earliestOpenThreadDue: nil
            )
        ]
        let overdueID = inputs[1].id

        let ranked = ScoringService.ranked(people: inputs, now: now)
        let top = try #require(ranked.first)
        #expect(top.personID == overdueID, "Overdue inner-circle should outrank recent close-friend")
    }
}
