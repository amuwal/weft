import SwiftData
import SwiftUI

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Person.createdAt) private var people: [Person]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                header
                if surfaced.isEmpty {
                    EmptyCalmState()
                        .padding(.top, Spacing.huge)
                } else {
                    ForEach(surfaced, id: \.person.id) { item in
                        PersonCard(
                            person: item.person,
                            reason: item.reason,
                            state: item.state,
                            weeksLabel: item.weeksLabel,
                            isToday: item.isToday
                        )
                    }
                    Text("Swipe right to mark caught up · left to snooze")
                        .font(LingerFont.caption)
                        .foregroundStyle(Color.whisper)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, Spacing.s)
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, 140)
        }
        .background(Color.bg)
        .navigationTitle("Linger")
        .navigationBarTitleDisplayMode(.inline)
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

    private var surfaced: [TodayItem] {
        TodayItem.sample()
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
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.xxl)
    }
}

struct TodayItem {
    let person: Person
    let reason: String
    let state: RhythmState
    let weeksLabel: String
    let isToday: Bool

    @MainActor
    static func sample() -> [Self] {
        let sarah = Person(name: "Sarah", relationship: .inner, rhythm: .weekly, avatarPalette: .rose)
        let david = Person(name: "David", relationship: .inner, rhythm: .biweekly, avatarPalette: .slate)
        return [
            Self(
                person: sarah,
                reason: "It's been three weeks. Her mom's surgery was on the 14th — ask how recovery is going.",
                state: .lingering,
                weeksLabel: "3w",
                isToday: true
            ),
            Self(
                person: david,
                reason: "He starts the new job Monday — wish him luck.",
                state: .recent,
                weeksLabel: "soon",
                isToday: false
            )
        ]
    }
}

#Preview {
    NavigationStack {
        TodayView()
    }
    .modelContainer(.preview)
}
