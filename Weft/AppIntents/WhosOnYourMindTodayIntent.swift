import AppIntents
import Foundation
import SwiftData

/// "Who's on my mind today?" — Siri answer that mirrors the Today screen.
///
/// Reuses `ScoringService` so the spoken / surfaced order matches what the
/// user would see if they opened the app. Returns a short readable string
/// rather than the raw list, so the Siri dialog reads naturally.
struct WhosOnYourMindTodayIntent: AppIntent {
    static let title: LocalizedStringResource = "Who's on your mind today"
    static let description = IntentDescription(
        "The same list of people Weft surfaces on the Today screen.",
        categoryName: "Today"
    )
    static let openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
        let people = try await loadRanked()

        if people.isEmpty {
            return .result(value: "", dialog: "Nobody's on your mind today. Quiet day.")
        }

        // Cap at the top 5 so a long list doesn't make Siri read for a minute.
        let top = Array(people.prefix(5))
        let names = top.map(\.name)
        let joined = formatList(names)
        let listLine = "Today: \(joined)."
        return .result(value: listLine, dialog: "\(joined).")
    }

    @MainActor
    private func loadRanked() async throws -> [PersonEntity] {
        let container = try ModelContainer.weft()
        let context = ModelContext(container)
        let allPeople = try context.fetch(FetchDescriptor<Person>())
        let active = allPeople.filter { !$0.isSnoozed }
        let inputs = active.map { person in
            ScoreInput(
                id: person.id,
                lastTouchedAt: latestTouch(for: person),
                createdAt: person.createdAt,
                rhythm: person.rhythm,
                weight: person.relationship.weight,
                birthday: person.birthday,
                earliestOpenThreadDue: person.threadsOrEmpty
                    .filter(\.isOpen)
                    .map(\.dueDate)
                    .min()
            )
        }
        let ranked = ScoringService.ranked(people: inputs)
        let byID = Dictionary(uniqueKeysWithValues: active.map { ($0.id, $0) })
        return ranked.compactMap { candidate in
            byID[candidate.personID].map(PersonEntity.init)
        }
    }

    private func latestTouch(for person: Person) -> Date? {
        let lastNote = person.notesOrEmpty.map(\.createdAt).max()
        let lastTouchpoint = person.touchpointsOrEmpty.map(\.createdAt).max()
        return [lastNote, lastTouchpoint].compactMap(\.self).max()
    }

    /// Joins names in human form: "Sarah", "Sarah and Alex", "Sarah, Alex,
    /// and Mom". Uses the Foundation list formatter so the JA locale gets
    /// "さやか、アレックス、お母さん" with the right separators.
    private func formatList(_ items: [String]) -> String {
        let formatter = ListFormatter()
        formatter.locale = Locale.current
        return formatter.string(from: items) ?? items.joined(separator: ", ")
    }
}
