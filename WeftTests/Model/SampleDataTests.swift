import Foundation
import SwiftData
import Testing
@testable import Weft

@MainActor
struct SampleDataTests {
    @Test
    func populateSeedsTheCanonicalCast() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: ModelContainer.weftSchema, configurations: [config])
        SampleData.populate(container.mainContext)

        let people = try container.mainContext.fetch(FetchDescriptor<Person>())
        #expect(people.count == 6)

        let names = Set(people.map(\.name))
        #expect(names.contains("Sarah"))
        #expect(names.contains("David"))
        #expect(names.contains("Mom"))
    }

    @Test
    func sarahHasAnOpenThread() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: ModelContainer.weftSchema, configurations: [config])
        SampleData.populate(container.mainContext)

        let people = try container.mainContext.fetch(FetchDescriptor<Person>())
        let sarah = try #require(people.first { $0.name == "Sarah" })
        #expect(sarah.threadsOrEmpty.contains { $0.isOpen })
    }
}
