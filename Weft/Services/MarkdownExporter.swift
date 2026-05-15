import Foundation
import SwiftData

@MainActor
enum MarkdownExporter {
    static func export(from context: ModelContext) -> URL {
        let body = render(from: context)
        let url = URL.temporaryDirectory.appending(path: "Weft-export-\(timestamp()).md")
        try? body.data(using: .utf8)?.write(to: url, options: .atomic)
        return url
    }

    static func render(from context: ModelContext) -> String {
        let people = (try? context.fetch(FetchDescriptor<Person>())) ?? []
        let sorted = people.sorted { $0.name < $1.name }

        var out = "# Weft export\n\nGenerated \(humanDate(.now)) · \(sorted.count) people\n\n"
        for person in sorted {
            out += "## \(person.name)\n"
            out += "_\(person.relationship.label) · \(person.rhythm.label)_\n\n"

            let notes = person.notesOrEmpty.sorted { $0.createdAt > $1.createdAt }
            if !notes.isEmpty {
                out += "### Notes\n"
                for note in notes {
                    out += "- **\(humanDate(note.createdAt))** — \(note.body)\n"
                }
                out += "\n"
            }

            let openThreads = person.threadsOrEmpty
                .filter(\.isOpen)
                .sorted { $0.dueDate < $1.dueDate }
            if !openThreads.isEmpty {
                out += "### Open threads\n"
                for thread in openThreads {
                    out += "- **\(humanDate(thread.dueDate))** — \(thread.body)\n"
                }
                out += "\n"
            }
            out += "\n"
        }
        return out
    }

    private static func timestamp() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.string(from: .now)
    }

    private static func humanDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}
