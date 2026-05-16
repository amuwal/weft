import Foundation
import PDFKit
import SwiftData
import Testing
import UIKit
@testable import Weft

/// End-to-end tests for the PDF export pipeline. We build a real SwiftData
/// in-memory container (per project convention — don't mock the data layer),
/// seed it with deterministic content, run `PDFExporter.render()`, and then
/// open the produced bytes with PDFKit to verify the text actually round-trips.
@MainActor
struct PDFExporterTests {
    // MARK: - Container

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

    private func seed(_ context: ModelContext) {
        let sarah = Person(name: "Sarah", relationship: .close, rhythm: .weekly)
        sarah.notes = [
            Note(
                body: "Asked about her mom's surgery — Tuesday went well.",
                person: sarah,
                createdAt: Date(timeIntervalSince1970: 1_715_000_000)
            ),
            Note(
                body: "Recommended the new Murakami translation.",
                person: sarah,
                createdAt: Date(timeIntervalSince1970: 1_714_500_000)
            )
        ]
        sarah.threads = [
            Thread(
                body: "Check in on the job interview next week",
                dueDate: Date(timeIntervalSince1970: 1_715_500_000),
                person: sarah
            )
        ]

        let dad = Person(name: "Dad", relationship: .family, rhythm: .biweekly)
        dad.notes = [
            Note(
                body: "Helped him set up Apple TV. He laughed at the remote.",
                person: dad,
                createdAt: Date(timeIntervalSince1970: 1_714_000_000)
            )
        ]

        // Person with no notes / no threads — empty-state path.
        let alex = Person(name: "Alex", relationship: .work, rhythm: .monthly)

        context.insert(sarah)
        context.insert(dad)
        context.insert(alex)
    }

    // MARK: - Helpers

    /// Concatenate every PDF page's text. PDFKit decodes the same text Apple's
    /// system viewers will, so what comes back here is exactly what a reader sees.
    private func extractText(from data: Data) throws -> String {
        let document = try #require(PDFDocument(data: data))
        var combined = ""
        for index in 0 ..< document.pageCount {
            if let page = document.page(at: index), let text = page.string {
                combined += text + "\n"
            }
        }
        return combined
    }

    // MARK: - Tests

    @Test
    func exportProducesNonEmptyPDF() throws {
        let container = try makeContainer()
        let context = container.mainContext
        seed(context)

        let people = try context.fetch(FetchDescriptor<Person>()).sorted { $0.name < $1.name }
        let data = PDFExporter.render(people: people, generatedAt: Date(timeIntervalSince1970: 1_715_600_000))

        #expect(data.count > 1000, "PDF should have meaningful content, got \(data.count) bytes")
        #expect(data.starts(with: Data("%PDF".utf8)), "Output should be a valid PDF header")
    }

    @Test
    func pdfContainsAllPersonNames() throws {
        let container = try makeContainer()
        let context = container.mainContext
        seed(context)

        let people = try context.fetch(FetchDescriptor<Person>()).sorted { $0.name < $1.name }
        let data = PDFExporter.render(people: people, generatedAt: Date(timeIntervalSince1970: 1_715_600_000))
        let text = try extractText(from: data)

        #expect(text.contains("Sarah"))
        #expect(text.contains("Dad"))
        #expect(text.contains("Alex"))
    }

    @Test
    func pdfContainsAllNoteBodies() throws {
        let container = try makeContainer()
        let context = container.mainContext
        seed(context)

        let people = try context.fetch(FetchDescriptor<Person>()).sorted { $0.name < $1.name }
        let data = PDFExporter.render(people: people, generatedAt: Date(timeIntervalSince1970: 1_715_600_000))
        let text = try extractText(from: data)

        #expect(text.contains("mom's surgery"))
        #expect(text.contains("Murakami"))
        #expect(text.contains("Apple TV"))
    }

    @Test
    func pdfContainsOpenThreadBodies() throws {
        let container = try makeContainer()
        let context = container.mainContext
        seed(context)

        let people = try context.fetch(FetchDescriptor<Person>()).sorted { $0.name < $1.name }
        let data = PDFExporter.render(people: people, generatedAt: Date(timeIntervalSince1970: 1_715_600_000))
        let text = try extractText(from: data)

        #expect(text.contains("job interview"))
    }

    @Test
    func pdfOmitsResolvedThreads() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let person = Person(name: "Mia", relationship: .inner, rhythm: .weekly)
        let openThread = Thread(
            body: "follow up on the wedding",
            dueDate: Date(timeIntervalSince1970: 1_715_000_000),
            person: person
        )
        let resolved = Thread(
            body: "RESOLVED-PRIVATE-marker",
            dueDate: Date(timeIntervalSince1970: 1_710_000_000),
            person: person
        )
        resolved.resolvedAt = .now
        person.threads = [openThread, resolved]
        context.insert(person)

        let people = try context.fetch(FetchDescriptor<Person>())
        let data = PDFExporter.render(people: people, generatedAt: Date(timeIntervalSince1970: 1_715_600_000))
        let text = try extractText(from: data)

        #expect(text.contains("wedding"))
        #expect(!text.contains("RESOLVED-PRIVATE-marker"), "Resolved threads should be excluded from export")
    }

    @Test
    func pdfHandlesEmptyLibrary() throws {
        let data = PDFExporter.render(people: [], generatedAt: Date(timeIntervalSince1970: 1_715_600_000))

        #expect(data.starts(with: Data("%PDF".utf8)))
        let text = try extractText(from: data)
        #expect(text.contains("Weft"))
        // Locale-independent: the count subtitle must contain "0" (and the
        // localized "people"/"人" suffix, but we don't care which language ran
        // the test).
        #expect(text.contains("0 people") || text.contains("0人"))
    }

    @Test
    func pdfHandlesPersonWithNoNotesOrThreads() throws {
        let person = Person(name: "Solo", relationship: .other, rhythm: .none)
        let data = PDFExporter.render(
            people: [person],
            generatedAt: Date(timeIntervalSince1970: 1_715_600_000)
        )
        let text = try extractText(from: data)

        #expect(text.contains("Solo"))
        #expect(!text.contains("Open threads"), "Empty person should not show Open threads header")
    }

    @Test
    func pdfPaginatesWhenContentExceedsOnePage() throws {
        let person = Person(name: "Voluminous", relationship: .inner, rhythm: .weekly)
        let longBody = String(repeating: "The quick brown fox jumps over the lazy dog. ", count: 8)
        var notes: [Note] = []
        for i in 0 ..< 80 {
            notes.append(Note(
                body: "Entry \(i): \(longBody)",
                person: person,
                createdAt: Date(timeIntervalSince1970: 1_700_000_000 + Double(i) * 86400)
            ))
        }
        person.notes = notes

        let data = PDFExporter.render(
            people: [person],
            generatedAt: Date(timeIntervalSince1970: 1_715_600_000)
        )
        let document = try #require(PDFDocument(data: data))

        #expect(document.pageCount >= 2, "Expected pagination, got \(document.pageCount) page(s)")

        // And no note should be silently dropped during pagination.
        let text = try extractText(from: data)
        #expect(text.contains("Entry 0:"))
        #expect(text.contains("Entry 79:"))
    }

    @Test
    func pdfFooterHasPageNumber() throws {
        let person = Person(name: "Footer Test", relationship: .close, rhythm: .weekly)
        let data = PDFExporter.render(
            people: [person],
            generatedAt: Date(timeIntervalSince1970: 1_715_600_000)
        )
        let text = try extractText(from: data)

        #expect(text.contains("page 1") || text.contains("1ページ"))
    }

    @Test
    func pdfEmbedsAttachedPhoto() throws {
        // A note with no photo vs. the same setup with one — the PDF with the
        // photo must be substantially larger because the embedded image bytes
        // become part of the PDF stream.
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 600, height: 400))
        let image = renderer.image { ctx in
            UIColor.systemTeal.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 600, height: 400))
        }
        let photoBytes = try #require(image.jpegData(compressionQuality: 0.7))

        let withoutPhoto = Person(name: "Sam", relationship: .close, rhythm: .weekly)
        withoutPhoto.notes = [Note(
            body: "no photo here",
            person: withoutPhoto,
            createdAt: Date(timeIntervalSince1970: 1_715_000_000)
        )]
        let textOnlyData = PDFExporter.render(
            people: [withoutPhoto],
            generatedAt: Date(timeIntervalSince1970: 1_715_600_000)
        )

        let withPhoto = Person(name: "Sam", relationship: .close, rhythm: .weekly)
        withPhoto.notes = [Note(
            body: "with photo",
            person: withPhoto,
            createdAt: Date(timeIntervalSince1970: 1_715_000_000),
            photoData: photoBytes
        )]
        let withPhotoData = PDFExporter.render(
            people: [withPhoto],
            generatedAt: Date(timeIntervalSince1970: 1_715_600_000)
        )

        let delta = withPhotoData.count - textOnlyData.count
        #expect(
            delta > 5000,
            "Expected embedded image to grow PDF substantially. text-only=\(textOnlyData.count), with-photo=\(withPhotoData.count)"
        )
    }

    @Test
    func pdfMetadataIsSet() throws {
        let data = PDFExporter.render(people: [], generatedAt: Date(timeIntervalSince1970: 1_715_600_000))
        let document = try #require(PDFDocument(data: data))
        let attrs = document.documentAttributes ?? [:]

        let creator = attrs[PDFDocumentAttribute.creatorAttribute] as? String
        #expect(creator == "Weft for iOS")
    }
}
