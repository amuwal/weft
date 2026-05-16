import Foundation
import SwiftData
import UIKit

enum SampleData {
    @MainActor
    static func populate(_ context: ModelContext) {
        let now = Date.now
        let cal = Calendar.current
        let day: (Int) -> Date = { cal.date(byAdding: .day, value: -$0, to: now) ?? now }
        // Optional debug seed: launch with --seed-photo to attach a placeholder
        // image to Sarah's note so end-to-end rendering paths (PersonDetail,
        // Today badge, PDF embed) can be exercised without a Premium purchase.
        let seedPhoto = ProcessInfo.processInfo.arguments.contains("--seed-photo")

        let sarah = Person(name: "Sarah", relationship: .inner, rhythm: .weekly, avatarPalette: .rose)
        let david = Person(name: "David", relationship: .inner, rhythm: .biweekly, avatarPalette: .slate)
        let priya = Person(name: "Priya", relationship: .close, rhythm: .monthly, avatarPalette: .warm)
        let mom = Person(name: "Mom", relationship: .family, rhythm: .weekly, avatarPalette: .warm)
        let alex = Person(name: "Alex", relationship: .close, rhythm: .monthly, avatarPalette: .clay)
        let dad = Person(name: "Dad", relationship: .family, rhythm: .biweekly, avatarPalette: .clay)

        for person in [sarah, david, priya, mom, alex, dad] {
            context.insert(person)
        }

        let sarahNote = Note(
            body: "Coffee at Verve. She's been worried about her mom's upcoming surgery on the 14th. "
                + "Started a new book on grief — Joan Didion. She lit up describing the prose.",
            person: sarah,
            createdAt: day(21),
            photoData: seedPhoto ? Self.placeholderPhoto() : nil
        )
        context.insert(sarahNote)
        context.insert(Touchpoint(kind: .note, person: sarah, createdAt: day(21)))
        context.insert(Thread(
            body: "Follow up on her mom's surgery",
            dueDate: day(2),
            person: sarah,
            sourceNoteId: sarahNote.id
        ))

        context.insert(Note(
            body: "Quick check-in by text. He's loving the new job. Wants to grab dinner soon.",
            person: david,
            createdAt: day(5)
        ))
        context.insert(Touchpoint(kind: .note, person: david, createdAt: day(5)))

        context.insert(Note(
            body: "She recommended The Bee Sting. Said it changed how she thinks about families.",
            person: priya,
            createdAt: day(35)
        ))
        context.insert(Touchpoint(kind: .note, person: priya, createdAt: day(35)))

        context.insert(Touchpoint(kind: .markedCaughtUp, person: mom, createdAt: day(8)))

        context.insert(Note(
            body: "Trip to Lisbon — he sent photos from Belém.",
            person: alex,
            createdAt: day(60)
        ))
        context.insert(Touchpoint(kind: .note, person: alex, createdAt: day(60)))

        context.insert(Touchpoint(kind: .markedCaughtUp, person: dad, createdAt: day(20)))
    }

    /// Renders a small gradient placeholder so debug seeded photos look like
    /// something the user might have actually captured (not just a solid block).
    /// Runs through `PhotoCompressor` so the bytes mirror production storage.
    @MainActor
    private static func placeholderPhoto() -> Data? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1200, height: 800), format: format)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            let colors = [
                UIColor(red: 0.74, green: 0.66, blue: 0.52, alpha: 1).cgColor,
                UIColor(red: 0.46, green: 0.55, blue: 0.43, alpha: 1).cgColor
            ]
            let space = CGColorSpaceCreateDeviceRGB()
            if let gradient = CGGradient(colorsSpace: space, colors: colors as CFArray, locations: [0, 1]) {
                cg.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: 1200, y: 800),
                    options: []
                )
            }
        }
        guard let raw = image.jpegData(compressionQuality: 0.9) else { return nil }
        return PhotoCompressor.compress(raw)
    }
}
