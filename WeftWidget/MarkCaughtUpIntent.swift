import AppIntents
import Foundation
import SwiftData
import WidgetKit

/// Mark a person caught up directly from the widget. Inserts a
/// `.markedCaughtUp` touchpoint + resolves any open thread the Today
/// view used to surface them — same logic the app's swipe-right runs.
///
/// Premium-only at the widget surface: the button is omitted for free
/// users on the large widget. The intent itself stays callable so users
/// who become Premium retroactively don't see a broken Shortcuts flow.
@available(iOS 17.0, *)
struct MarkCaughtUpIntent: AppIntent {
    static let title: LocalizedStringResource = "Mark caught up"
    static let description = IntentDescription(
        "Records a 'caught up' touchpoint for this person and resolves their open follow-up.",
        categoryName: "Today"
    )

    /// We pass the UUID as a String (not `PersonEntity`) so the button can be
    /// constructed without resolving the entity — much faster widget render.
    @Parameter(title: "Person ID")
    var personID: String

    init() {}

    init(personID: String) {
        self.personID = personID
    }

    func perform() async throws -> some IntentResult {
        try await MainActor.run {
            let container = try ModelContainer.weft()
            let context = ModelContext(container)
            guard let uuid = UUID(uuidString: personID) else { return }
            var descriptor = FetchDescriptor<Person>()
            descriptor.predicate = #Predicate { $0.id == uuid }
            guard let person = try context.fetch(descriptor).first else { return }
            // Resolve the earliest open thread, same as the Today swipe.
            let openThread = person.threadsOrEmpty
                .filter(\.isOpen)
                .min(by: { $0.dueDate < $1.dueDate })
            openThread?.resolvedAt = .now
            person.snoozedUntil = nil
            context.insert(Touchpoint(kind: .markedCaughtUp, person: person))
            try context.save()
        }
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
