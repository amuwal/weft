import Foundation
import SwiftData
import Testing
@testable import Weft

@MainActor
struct PersonTests {
    @Test
    func initialIsFirstCharacterUppercased() {
        let p = Person(name: "sarah", relationship: .inner, rhythm: .weekly)
        #expect(p.initial == "S")
    }

    @Test
    func avatarPaletteRoundTrips() {
        let p = Person(name: "Mom", relationship: .family, rhythm: .biweekly, avatarPalette: .warm)
        #expect(p.avatarPalette == .warm)
        p.avatarPalette = .rose
        #expect(p.avatarPalette == .rose)
    }

    @Test
    func rhythmReportsDays() {
        #expect(Rhythm.weekly.days == 7)
        #expect(Rhythm.monthly.days == 30)
        #expect(Rhythm.none.days == nil)
    }

    @Test
    func cloudKitlessContainerPersists() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: ModelContainer.weftSchema, configurations: [config])
        let context = container.mainContext

        let alex = Person(name: "Alex", relationship: .close, rhythm: .monthly)
        context.insert(alex)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Person>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Alex")
    }
}
