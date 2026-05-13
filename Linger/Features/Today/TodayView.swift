import SwiftData
import SwiftUI

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Person.name) private var people: [Person]
    @State private var snoozedIDs: Set<UUID> = []
    @Namespace private var cardNamespace

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
                        NavigationLink(value: item.person) {
                            PersonCard(
                                person: item.person,
                                reason: item.reason,
                                state: item.state,
                                weeksLabel: item.weeksLabel,
                                isToday: item.isToday
                            )
                            .matchedTransitionSource(id: item.person.id, in: cardNamespace)
                            .pressable()
                        }
                        .buttonStyle(.plain)
                        .swipeGestures(
                            onCaughtUp: { caughtUp(item.person) },
                            onSnooze: { snooze(item.person) }
                        )
                    }
                    .animation(.lingerSpring, value: surfaced.map(\.id))

                    Text("Swipe right to mark caught up · left to snooze")
                        .font(LingerFont.caption)
                        .foregroundStyle(Color.whisper)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, Spacing.s)
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, 110)
        }
        .background(Color.bg)
        .navigationTitle("Linger")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Person.self) { person in
            PersonDetailView(person: person)
                .navigationTransition(.zoom(sourceID: person.id, in: cardNamespace))
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date.now, format: .dateTime.weekday(.wide).month().day())
                .font(LingerFont.caption)
                .foregroundStyle(Color.muted)
            Text("Who's on your\nmind today?")
                .font(LingerFont.display)
                .foregroundStyle(Color.ink)
        }
        .padding(.top, Spacing.s)
    }

    private var emptyHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Date.now, format: .dateTime.weekday(.wide).month().day())
                .font(LingerFont.caption)
                .foregroundStyle(Color.muted)
        }
        .padding(.top, Spacing.s)
    }

    private var surfaced: [TodayItem] {
        let inputs = people
            .filter { !snoozedIDs.contains($0.id) }
            .map { person in
                ScoreInput(
                    id: person.id,
                    lastTouchedAt: latestTouch(for: person),
                    rhythm: person.rhythm,
                    weight: person.relationship.weight
                )
            }
        let ranked = ScoringService.ranked(people: inputs)
        let byID = Dictionary(uniqueKeysWithValues: people.map { ($0.id, $0) })
        return ranked.compactMap { id in
            guard let person = byID[id] else { return nil }
            return TodayItem.make(for: person, last: latestTouch(for: person))
        }
    }

    private func latestTouch(for person: Person) -> Date? {
        let lastNote = person.notesOrEmpty.map(\.createdAt).max()
        let lastTP = person.touchpointsOrEmpty.map(\.createdAt).max()
        return [lastNote, lastTP].compactMap(\.self).max()
    }

    private func caughtUp(_ person: Person) {
        context.insert(Touchpoint(kind: .markedCaughtUp, person: person))
        try? context.save()
        Haptic.success.play()
    }

    private func snooze(_ person: Person) {
        snoozedIDs.insert(person.id)
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

    static func make(for person: Person, last: Date?) -> Self {
        let weeks = weeksSince(last)
        let reason = composedReason(for: person, weeks: weeks)
        return Self(
            id: person.id,
            person: person,
            reason: reason,
            state: state(weeks: weeks, rhythm: person.rhythm),
            weeksLabel: weeksLabel(weeks: weeks),
            isToday: weeks >= 3
        )
    }

    private static func weeksSince(_ date: Date?) -> Int {
        guard let date else { return 99 }
        let days = Int(Date.now.timeIntervalSince(date) / 86400)
        return days / 7
    }

    private static func weeksLabel(weeks: Int) -> String {
        weeks <= 0 ? "now" : weeks < 99 ? "\(weeks)w" : "—"
    }

    private static func state(weeks: Int, rhythm: Rhythm) -> RhythmState {
        guard let days = rhythm.days else { return .recent }
        let weeksThreshold = days / 7
        if weeks * 7 < days { return .recent }
        if weeks <= weeksThreshold { return .onRhythm }
        return .lingering
    }

    private static func composedReason(for person: Person, weeks: Int) -> String {
        if let openThread = person.threadsOrEmpty.first(where: { $0.isOpen }) {
            return openThread.body
        }
        if weeks <= 0 { return "It's been a few days." }
        if weeks >= 12 { return "It's been a while." }
        return "It's been \(spelled(weeks)) weeks."
    }

    private static func spelled(_ weeks: Int) -> String {
        switch weeks {
        case 1: "one"
        case 2: "two"
        case 3: "three"
        case 4: "four"
        case 5: "five"
        case 6: "six"
        case 7: "seven"
        case 8: "eight"
        default: "several"
        }
    }
}

#Preview {
    NavigationStack {
        TodayView()
    }
    .modelContainer(.preview)
}
