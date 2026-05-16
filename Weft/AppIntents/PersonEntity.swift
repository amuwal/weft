import AppIntents
import Foundation
import SwiftData

/// App Intents wrapper for `Person`. Lets Shortcuts UI present a person picker
/// (typed name with suggestions, voice-spoken name resolution) and lets Siri
/// disambiguate when the user says "Sarah" but has multiple Sarahs.
///
/// Intents may run outside the main app process (Shortcuts background queue,
/// Siri suggestions), so this entity opens its own SwiftData container on
/// demand rather than relying on an environment-injected one.
struct PersonEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Person")
    static let defaultQuery = PersonQuery()

    let id: UUID
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }

    init(person: Person) {
        self.id = person.id
        self.name = person.name
    }
}

struct PersonQuery: EntityQuery {
    /// Resolves entities by id — called when Shortcuts re-runs a previously-built
    /// flow, to make sure the picked person still exists.
    func entities(for identifiers: [PersonEntity.ID]) async throws -> [PersonEntity] {
        try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                do {
                    let container = try ModelContainer.weft()
                    let context = ModelContext(container)
                    var descriptor = FetchDescriptor<Person>()
                    descriptor.predicate = #Predicate { identifiers.contains($0.id) }
                    let people = try context.fetch(descriptor)
                    continuation.resume(returning: people.map(PersonEntity.init))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Powers the picker list in the Shortcuts editor.
    func suggestedEntities() async throws -> [PersonEntity] {
        try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                do {
                    let container = try ModelContainer.weft()
                    let context = ModelContext(container)
                    let people = try context.fetch(FetchDescriptor<Person>(sortBy: [SortDescriptor(\.name)]))
                    continuation.resume(returning: people.map(PersonEntity.init))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
