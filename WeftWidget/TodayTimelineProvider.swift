import Foundation
import SwiftData
import WidgetKit

/// Builds widget timelines by opening the App-Group-shared SwiftData store,
/// scoring everyone the same way `TodayView` does, and snapshotting the top
/// few names. Re-runs every 30 minutes — the cadence the brand surfaces work
/// at (hours/days, not seconds), so a tighter refresh would just burn battery.
struct TodayTimelineProvider: TimelineProvider {
    /// Returns the placeholder Apple shows in the widget picker before any
    /// real timeline is available — bundled fake data keeps the gallery
    /// tile readable instead of empty.
    func placeholder(in _: Context) -> TodayEntry {
        .placeholder
    }

    /// SwiftData + ScoringService have to run on the main actor, but the
    /// TimelineProvider protocol's callbacks are nonisolated. Hop with a
    /// `Task { @MainActor in … }` and invoke the completion when done.
    nonisolated func getSnapshot(in _: Context, completion: @escaping @Sendable (TodayEntry) -> Void) {
        Task { @MainActor in
            completion(currentEntry())
        }
    }

    nonisolated func getTimeline(
        in _: Context,
        completion: @escaping @Sendable (Timeline<TodayEntry>) -> Void
    ) {
        Task { @MainActor in
            let entry = currentEntry()
            let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
            completion(Timeline(entries: [entry], policy: .after(next)))
        }
    }

    // MARK: - Data

    @MainActor
    private func currentEntry() -> TodayEntry {
        let isPremium = UserDefaults.standard.bool(forKey: Entitlements.cachedIsPremiumKey)
            || Entitlements.debugPremiumOverride
        let snapshot = loadTopPeople()
        return TodayEntry(date: .now, people: snapshot, isPremium: isPremium)
    }

    @MainActor
    private func loadTopPeople() -> [WidgetPerson] {
        guard let container = try? ModelContainer.weft() else { return [] }
        let context = ModelContext(container)
        guard let people = try? context.fetch(FetchDescriptor<Person>()) else { return [] }
        let active = people.filter { !$0.isSnoozed }
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
            guard let person = byID[candidate.personID] else { return nil }
            let weeks = weeksSince(latestTouch(for: person))
            return WidgetPerson(
                id: person.id,
                name: person.name,
                reason: reasonText(for: candidate.reason, fallbackWeeks: weeks),
                weeks: weeks,
                paletteKey: person.avatarPalette.rawValue
            )
        }
    }

    private func latestTouch(for person: Person) -> Date? {
        let lastNote = person.notesOrEmpty.map(\.createdAt).max()
        let lastTouchpoint = person.touchpointsOrEmpty.map(\.createdAt).max()
        return [lastNote, lastTouchpoint].compactMap(\.self).max()
    }

    private func weeksSince(_ date: Date?) -> Int {
        guard let date else { return 0 }
        return max(0, Int(Date.now.timeIntervalSince(date) / (7 * 86400)))
    }

    /// Mirrors `TodayItem.make` reasoning so widget copy matches in-app copy.
    /// We render in the user's app language via `loc()`.
    private func reasonText(for reason: SurfaceReason, fallbackWeeks weeks: Int) -> String {
        switch reason {
        case .threadDue: loc("Follow-up due.")
        case .birthday: loc("It's their birthday.")
        case .onRhythm:
            if weeks <= 0 {
                loc("It's been a few days.")
            } else if weeks == 1 {
                loc("It's been a week.")
            } else if weeks >= 12 {
                loc("It's been a while.")
            } else {
                loc("It's been %lld weeks.", weeks)
            }
        }
    }
}
