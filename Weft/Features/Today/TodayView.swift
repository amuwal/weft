import SwiftData
import SwiftUI

struct TodayView: View {
    @Binding var path: [Person]
    @Environment(\.modelContext) private var context
    @Query(sort: \Person.name) private var people: [Person]
    @Namespace private var cardNamespace

    init(path: Binding<[Person]> = .constant([])) {
        self._path = path
    }

    /// Three days, expressed in seconds. Snooze interval per spec/features-v1.md.
    private static let snoozeInterval: TimeInterval = 3 * 24 * 60 * 60

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                if surfaced.isEmpty {
                    emptyHeader
                    EmptyCalmState()
                        .padding(.top, Spacing.l)
                } else {
                    header
                    ForEach(surfaced) { item in
                        PersonCard(
                            person: item.person,
                            reason: item.reason,
                            state: item.state,
                            weeksLabel: item.weeksLabel,
                            isToday: item.isToday,
                            recentPhotoData: recentPhotoData(for: item.person)
                        )
                        .matchedTransitionSource(id: item.person.id, in: cardNamespace)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Haptic.soft.play()
                            path.append(item.person)
                        }
                        .swipeGestures(
                            onCaughtUp: { caughtUp(item) },
                            onSnooze: { snooze(item) }
                        )
                    }
                    .animation(.weftSpring, value: surfaced.map(\.id))

                    Text("Swipe right to mark caught up · left to snooze")
                        .font(WeftFont.caption)
                        .foregroundStyle(Color.whisper)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, Spacing.s)
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, 110)
        }
        .background(Color.bg)
        .navigationTitle("Weft")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Person.self) { person in
            PersonDetailView(person: person)
                .navigationTransition(.zoom(sourceID: person.id, in: cardNamespace))
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date.now, format: .dateTime.weekday(.wide).month().day())
                .font(WeftFont.caption)
                .foregroundStyle(Color.muted)
            Text("Who's on your\nmind today?")
                .font(WeftFont.display)
                .foregroundStyle(Color.ink)
        }
        .padding(.top, Spacing.s)
    }

    private var emptyHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date.now, format: .dateTime.weekday(.wide).month().day())
                .font(WeftFont.caption)
                .foregroundStyle(Color.muted)
        }
        .padding(.top, Spacing.s)
    }

    private var surfaced: [TodayItem] {
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
        let byID = Dictionary(uniqueKeysWithValues: people.map { ($0.id, $0) })
        return ranked.compactMap { candidate in
            guard let person = byID[candidate.personID] else { return nil }
            return TodayItem.make(
                for: person,
                last: latestTouch(for: person),
                reason: candidate.reason
            )
        }
    }

    private func latestTouch(for person: Person) -> Date? {
        let lastNote = person.notesOrEmpty.map(\.createdAt).max()
        let lastTP = person.touchpointsOrEmpty.map(\.createdAt).max()
        return [lastNote, lastTP].compactMap(\.self).max()
    }

    /// Returns the photo from this person's most recent note that has one.
    /// Surfaced on the Today card to give the entry a flicker of memory.
    private func recentPhotoData(for person: Person) -> Data? {
        person.notesOrEmpty
            .sorted { $0.createdAt > $1.createdAt }
            .first(where: { $0.photoData != nil })?
            .photoData
    }

    private func caughtUp(_ item: TodayItem) {
        let person = item.person
        if let threadID = item.sourceThreadID,
           let thread = person.threadsOrEmpty.first(where: { $0.id == threadID })
        {
            thread.resolvedAt = .now
        }
        context.insert(Touchpoint(kind: .markedCaughtUp, person: person))
        person.snoozedUntil = nil
        try? context.save()
        Haptic.success.play()
    }

    private func snooze(_ item: TodayItem) {
        let person = item.person
        person.snoozedUntil = Date.now.addingTimeInterval(Self.snoozeInterval)
        context.insert(Touchpoint(kind: .snoozed, person: person))
        try? context.save()
        Haptic.soft.play()
    }
}

private struct EmptyCalmState: View {
    var body: some View {
        VStack(spacing: Spacing.ml) {
            Text("Nothing pressing.")
                .font(.system(size: 32, design: .serif).weight(.medium))
                .foregroundStyle(Color.ink)
            Text("Enjoy your day.")
                .font(.system(size: 24, design: .serif).weight(.regular).italic())
                .foregroundStyle(Color.muted)
            SoftArc()
                .frame(width: 120, height: 60)
                .padding(.top, Spacing.xxl)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.xxl)
    }
}

private struct SoftArc: View {
    var body: some View {
        Canvas { ctx, size in
            var path = Path()
            path.move(to: CGPoint(x: 8, y: size.height - 8))
            path.addQuadCurve(
                to: CGPoint(x: size.width - 8, y: size.height - 8),
                control: CGPoint(x: size.width / 2, y: 4)
            )
            ctx.stroke(path, with: .color(.sage.opacity(0.85)), style: .init(lineWidth: 3, lineCap: .round))
            ctx.fill(
                Path(ellipseIn: CGRect(x: 2, y: size.height - 14, width: 12, height: 12)),
                with: .color(.sage)
            )
            ctx.fill(
                Path(ellipseIn: CGRect(x: size.width - 14, y: size.height - 14, width: 12, height: 12)),
                with: .color(.sage)
            )
        }
    }
}

struct TodayItem: Identifiable {
    let id: UUID
    let person: Person
    let reason: String
    let state: RhythmState
    let weeksLabel: String
    let isToday: Bool
    /// The open thread that produced `reason`, if any. Lets the caught-up
    /// swipe resolve the exact thread the user saw on the card.
    let sourceThreadID: UUID?

    static func make(for person: Person, last: Date?, reason surfaceReason: SurfaceReason) -> Self {
        let weeks = weeksSince(last)
        let earliestOpenThread = person.threadsOrEmpty
            .filter(\.isOpen)
            .min(by: { $0.dueDate < $1.dueDate })

        let displayReason: String
        let sourceThreadID: UUID?
        let isToday: Bool
        let state: RhythmState

        switch surfaceReason {
        case .threadDue:
            displayReason = earliestOpenThread?.body ?? loc("Follow-up due.")
            sourceThreadID = earliestOpenThread?.id
            isToday = true
            state = .lingering
        case .birthday:
            displayReason = loc("It's their birthday.")
            sourceThreadID = nil
            isToday = true
            state = .onRhythm
        case .onRhythm:
            displayReason = rhythmCopy(weeks: weeks)
            sourceThreadID = nil
            isToday = weeks >= 3
            state = Self.state(weeks: weeks, rhythm: person.rhythm)
        }

        return Self(
            id: person.id,
            person: person,
            reason: displayReason,
            state: state,
            weeksLabel: Self.weeksLabel(weeks: weeks),
            isToday: isToday,
            sourceThreadID: sourceThreadID
        )
    }

    private static func weeksSince(_ date: Date?) -> Int {
        guard let date else { return 99 }
        let days = Int(Date.now.timeIntervalSince(date) / 86400)
        return days / 7
    }

    private static func weeksLabel(weeks: Int) -> String {
        if weeks <= 0 { return loc("now") }
        if weeks >= 99 { return "—" }
        return loc("%lldw", weeks)
    }

    private static func state(weeks: Int, rhythm: Rhythm) -> RhythmState {
        guard let days = rhythm.days else { return .recent }
        let weeksThreshold = days / 7
        if weeks * 7 < days { return .recent }
        if weeks <= weeksThreshold { return .onRhythm }
        return .lingering
    }

    private static func rhythmCopy(weeks: Int) -> String {
        if weeks <= 0 { return loc("It's been a few days.") }
        if weeks == 1 { return loc("It's been a week.") }
        if weeks >= 12 { return loc("It's been a while.") }
        return loc("It's been %lld weeks.", weeks)
    }
}

#Preview {
    NavigationStack {
        TodayView()
    }
    .modelContainer(.preview)
}
