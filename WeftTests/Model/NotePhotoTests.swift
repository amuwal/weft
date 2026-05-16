import Foundation
import SwiftData
import Testing
import UIKit
@testable import Weft

@MainActor
struct NotePhotoTests {
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

    private func sampleImageData() -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100))
        let image = renderer.image { ctx in
            UIColor.systemPink.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
        }
        return image.jpegData(compressionQuality: 0.8) ?? Data()
    }

    @Test
    func notePhotoDataPersistsThroughContainer() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let person = Person(name: "Test", relationship: .close, rhythm: .weekly)
        let originalBytes = sampleImageData()
        let note = Note(body: "with photo", person: person, photoData: originalBytes)
        context.insert(person)
        context.insert(note)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Note>())
        #expect(fetched.count == 1)
        let retrieved = try #require(fetched.first?.photoData)
        #expect(retrieved == originalBytes, "Photo bytes should survive a round-trip through the store")
    }

    @Test
    func notesWithoutPhotoHaveNilPhotoData() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let person = Person(name: "Test", relationship: .close, rhythm: .weekly)
        let note = Note(body: "no photo", person: person)
        context.insert(person)
        context.insert(note)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Note>())
        #expect(fetched.first?.photoData == nil)
    }
}
