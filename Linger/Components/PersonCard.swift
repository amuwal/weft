import SwiftUI

struct PersonCard: View {
    let person: Person
    let reason: String
    let state: RhythmState
    let weeksLabel: String
    var isToday: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            PersonAvatar(initial: person.initial, palette: person.avatarPalette)
            VStack(alignment: .leading, spacing: 2) {
                Text(person.name)
                    .font(LingerFont.title)
                    .foregroundStyle(Color.ink)
                Text(reason)
                    .font(LingerFont.serifBody)
                    .foregroundStyle(isToday ? Color(red: 0.42, green: 0.32, blue: 0.20) : Color.muted)
                    .lineLimit(2)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 6) {
                DotIndicator(state: state)
                Text(weeksLabel)
                    .font(LingerFont.caption)
                    .foregroundStyle(Color.muted)
                    .monospacedDigit()
            }
        }
        .padding(18)
        .background(background, in: RoundedRectangle(cornerRadius: Radius.cardLarge, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.cardLarge, style: .continuous)
                .strokeBorder(Color.ink.opacity(0.06), lineWidth: 0.5)
        )
        .shadow(color: Color.ink.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    private var background: AnyShapeStyle {
        if isToday {
            AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.988, blue: 0.957),
                        Color(red: 0.980, green: 0.965, blue: 0.918)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        } else {
            AnyShapeStyle(Color.surface)
        }
    }
}

#Preview {
    let p = Person(name: "Sarah", relationship: .inner, rhythm: .weekly, avatarPalette: .rose)
    return VStack(spacing: 12) {
        PersonCard(
            person: p,
            reason: "It's been three weeks. Her mom's surgery was on the 14th — ask how recovery is going.",
            state: .lingering,
            weeksLabel: "3w",
            isToday: true
        )
        PersonCard(
            person: Person(name: "David", relationship: .inner, rhythm: .biweekly, avatarPalette: .slate),
            reason: "He starts the new job Monday — wish him luck.",
            state: .recent,
            weeksLabel: "soon"
        )
    }
    .padding()
    .background(Color.bg)
}
