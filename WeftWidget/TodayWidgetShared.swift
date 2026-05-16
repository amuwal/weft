import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Brand palette

/// Brand colors mirrored as hex literals so the widget extension renders
/// correctly without depending on the main app's asset catalog (extensions
/// can't access the host app's `Assets.xcassets` namespace at runtime).
///
/// Source of truth lives in `Weft/Resources/Assets.xcassets`. Keep these in
/// sync with the `bg / ink / sage / muted` color definitions there.
enum WidgetColor {
    static let bg = Color(red: 248 / 255, green: 245 / 255, blue: 239 / 255)
    static let ink = Color(red: 22 / 255, green: 20 / 255, blue: 16 / 255)
    static let sage = Color(red: 92 / 255, green: 122 / 255, blue: 102 / 255)
    static let muted = Color(red: 0.42, green: 0.38, blue: 0.32)
    static let sageWash = Color(red: 92 / 255, green: 122 / 255, blue: 102 / 255).opacity(0.12)
}

// MARK: - Entry

/// Snapshot the widget consumes. Designed to be cheap to encode and small
/// enough that re-rendering across timeline updates is fast.
struct TodayEntry: TimelineEntry {
    let date: Date
    let people: [WidgetPerson]
    let isPremium: Bool

    /// Empty placeholder used in previews + the OS-side widget gallery so
    /// the gallery thumbnail isn't blank while we load real data.
    static let placeholder = Self(
        date: .now,
        people: [
            WidgetPerson(id: UUID(), name: "Sarah", reason: "Follow-up due.", weeks: 3, paletteKey: "rose"),
            WidgetPerson(
                id: UUID(),
                name: "Alex",
                reason: "It's been 8 weeks.",
                weeks: 8,
                paletteKey: "clay"
            ),
            WidgetPerson(id: UUID(), name: "Dad", reason: "It's been 2 weeks.", weeks: 2, paletteKey: "clay"),
            WidgetPerson(
                id: UUID(),
                name: "Priya",
                reason: "It's been 5 weeks.",
                weeks: 5,
                paletteKey: "warm"
            ),
            WidgetPerson(
                id: UUID(),
                name: "Mom",
                reason: "It's been a few days.",
                weeks: 0,
                paletteKey: "warm"
            )
        ],
        isPremium: true
    )

    static let placeholderFree = Self(
        date: placeholder.date,
        people: placeholder.people,
        isPremium: false
    )
}

struct WidgetPerson: Identifiable, Hashable {
    let id: UUID
    let name: String
    let reason: String
    let weeks: Int
    /// Palette key matching the in-app `Person.avatarPalette`. Threaded
    /// through so the widget renders the same colored circle the user sees
    /// next to that person inside the app.
    var paletteKey: String = "sage"

    var avatarColor: Color {
        switch paletteKey {
        case "sage": Color(red: 132 / 255, green: 159 / 255, blue: 140 / 255)
        case "warm": Color(red: 213 / 255, green: 170 / 255, blue: 116 / 255)
        case "slate": Color(red: 124 / 255, green: 139 / 255, blue: 158 / 255)
        case "rose": Color(red: 209 / 255, green: 152 / 255, blue: 167 / 255)
        case "clay": Color(red: 197 / 255, green: 152 / 255, blue: 128 / 255)
        case "lilac": Color(red: 175 / 255, green: 158 / 255, blue: 197 / 255)
        case "blue": Color(red: 132 / 255, green: 165 / 255, blue: 192 / 255)
        default: Color(red: 132 / 255, green: 159 / 255, blue: 140 / 255)
        }
    }

    var initial: String {
        String(name.prefix(1)).uppercased()
    }
}

// MARK: - View

struct TodayWidgetView: View {
    @Environment(\.widgetFamily) private var envFamily
    let entry: TodayEntry
    /// When set, overrides the environment-derived widget family. Used by
    /// the in-app DEBUG `WidgetPreviewScreen` to render multiple sizes side
    /// by side; the real widget extension passes `nil` and lets the system
    /// drive the family via `environment(\.widgetFamily, …)`.
    var familyOverride: WidgetFamily?

    private var family: WidgetFamily {
        familyOverride ?? envFamily
    }

    var body: some View {
        switch family {
        case .systemSmall: smallView
        case .systemMedium: mediumView
        case .systemLarge: largeView
        default: smallView
        }
    }

    // MARK: small

    /// One person, photo-card-ish: full-bleed warm gradient, avatar circle,
    /// big serif name, reason snippet, week badge bottom-right.
    private var smallView: some View {
        ZStack(alignment: .topLeading) {
            todayGradient
            if let top = entry.people.first {
                personLink(top) {
                    VStack(alignment: .leading, spacing: 10) {
                        compactHeader
                        Spacer(minLength: 0)
                        avatarChip(top, large: true)
                        Text(top.name)
                            .font(.system(size: 22, design: .serif).weight(.medium))
                            .foregroundStyle(WidgetColor.ink)
                            .lineLimit(1)
                        Text(top.reason)
                            .font(.system(size: 11.5, design: .serif).italic())
                            .foregroundStyle(WidgetColor.muted)
                            .lineLimit(2)
                        weekBadge(top.weeks, prominent: true)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(14)
                }
            } else {
                VStack(alignment: .leading) {
                    compactHeader
                    Spacer()
                    emptyMessage("Quiet day.")
                }
                .padding(14)
            }
        }
    }

    // MARK: medium

    /// Header, then 3 rows. Top row gets the warm "today" treatment;
    /// rest are calm. Hairline dividers between rows for rhythm.
    /// Rows expand evenly so the bottom row has the same breathing room
    /// from the widget edge as the top row has from the header.
    private var mediumView: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 8)
            if entry.people.isEmpty {
                emptyMessage("Quiet day.")
                    .padding(.horizontal, 16)
                Spacer()
            } else {
                ForEach(Array(entry.people.prefix(3).enumerated()), id: \.element.id) { idx, person in
                    personLink(person) {
                        personRow(person, isTop: idx == 0, compact: true)
                            .padding(.horizontal, 14)
                            .frame(maxHeight: .infinity)
                            .background(idx == 0 ? AnyShapeStyle(todayGradient) : AnyShapeStyle(Color.clear))
                    }
                    if idx < min(2, entry.people.count - 1) {
                        divider.padding(.horizontal, 14)
                    }
                }
            }
        }
        .padding(.bottom, 8)
    }

    // MARK: large

    @ViewBuilder
    private var largeView: some View {
        if entry.isPremium {
            largePremium
        } else {
            largeFreeUpgrade
        }
    }

    private var largePremium: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 10)
            if entry.people.isEmpty {
                emptyMessage("Nothing pressing. Enjoy your day.")
                    .padding(.horizontal, 16)
                Spacer()
            } else {
                ForEach(Array(entry.people.prefix(5).enumerated()), id: \.element.id) { idx, person in
                    personLink(person) {
                        largeRow(person, isTop: idx == 0)
                            .padding(.horizontal, 14)
                            .frame(maxHeight: .infinity)
                            .background(idx == 0 ? AnyShapeStyle(todayGradient) : AnyShapeStyle(Color.clear))
                    }
                    if idx < min(4, entry.people.count - 1) {
                        divider.padding(.horizontal, 14)
                    }
                }
            }
        }
        .padding(.bottom, 10)
    }

    private func largeRow(_ person: WidgetPerson, isTop: Bool, showCaughtUp: Bool = true) -> some View {
        HStack(alignment: .center, spacing: 12) {
            avatarChip(person, large: false)
            VStack(alignment: .leading, spacing: 2) {
                Text(person.name)
                    .font(.system(size: 17, design: .serif).weight(.medium))
                    .foregroundStyle(WidgetColor.ink)
                    .lineLimit(1)
                Text(person.reason)
                    .font(.system(size: 12, design: .serif).italic())
                    .foregroundStyle(WidgetColor.muted)
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            VStack(spacing: 6) {
                weekBadge(person.weeks, prominent: isTop)
                if showCaughtUp, #available(iOS 17.0, *) {
                    caughtUpButton(for: person)
                }
            }
        }
    }

    @available(iOS 17.0, *)
    private func caughtUpButton(for person: WidgetPerson) -> some View {
        Button(intent: MarkCaughtUpIntent(personID: person.id.uuidString)) {
            Image(systemName: "checkmark")
                .font(.system(size: 10.5, weight: .bold))
                .foregroundStyle(WidgetColor.bg)
                .frame(width: 22, height: 22)
                .background(WidgetColor.sage, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Mark \(person.name) caught up")
    }

    /// Free-tier large widget: top entry rendered fully (warm "today"
    /// treatment), the next four rendered as faded teaser strips so users
    /// can see *who else* is on their mind without seeing reasons/badges.
    /// Footer upgrade pill links to the paywall.
    private var largeFreeUpgrade: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 10)
            if let top = entry.people.first {
                personLink(top) {
                    largeRow(top, isTop: true, showCaughtUp: false)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(todayGradient)
                }
                divider.padding(.horizontal, 14)
            }
            ForEach(Array(entry.people.dropFirst().prefix(4))) { person in
                teaserRow(person)
                    .padding(.horizontal, 14)
                    .frame(maxHeight: .infinity)
            }
            Spacer(minLength: 0)
            Link(destination: URL(string: "weft://paywall") ?? URL(filePath: "/")) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Unlock the full list + caught-up button")
                        .font(.system(size: 11.5, design: .serif).weight(.medium))
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(WidgetColor.sage)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(WidgetColor.sageWash, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
        }
    }

    /// Teaser row for the free-tier large widget — name + dot only, faded.
    /// Communicates "there are more people Weft is thinking about for you"
    /// without spoiling the reason copy that's gated to Premium.
    private func teaserRow(_ person: WidgetPerson) -> some View {
        HStack(alignment: .center, spacing: 12) {
            avatarChip(person, large: false)
                .opacity(0.55)
            Text(person.name)
                .font(.system(size: 15, design: .serif).weight(.medium))
                .foregroundStyle(WidgetColor.ink.opacity(0.4))
                .lineLimit(1)
            Spacer(minLength: 4)
        }
    }

    // MARK: shared row

    /// Reusable row for medium widget. `compact = true` shrinks vertical
    /// padding so 3 rows fit comfortably in the systemMedium frame.
    private func personRow(_ person: WidgetPerson, isTop: Bool, compact _: Bool) -> some View {
        HStack(alignment: .center, spacing: 10) {
            avatarChip(person, large: false)
            VStack(alignment: .leading, spacing: 1) {
                Text(person.name)
                    .font(.system(size: 15, design: .serif).weight(.medium))
                    .foregroundStyle(WidgetColor.ink)
                    .lineLimit(1)
                Text(person.reason)
                    .font(.system(size: 11.5, design: .serif).italic())
                    .foregroundStyle(WidgetColor.muted)
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            weekBadge(person.weeks, prominent: isTop)
        }
    }

    // MARK: shared chrome

    /// Full header used by medium + large. Arc + brand wordmark + day-of-week
    /// + month/day. Plenty of horizontal room at those widths.
    private var header: some View {
        HStack(spacing: 6) {
            brandMark
            Text("Weft.")
                .font(.system(size: 12.5, design: .serif).weight(.medium))
                .foregroundStyle(WidgetColor.ink)
                .tracking(0.3)
            Spacer()
            Text(entry.date, format: .dateTime.weekday(.abbreviated))
                .font(.system(size: 10.5, weight: .medium))
                .foregroundStyle(WidgetColor.muted)
                .tracking(0.4)
            Text("·")
                .font(.system(size: 10.5))
                .foregroundStyle(WidgetColor.muted)
            Text(entry.date, format: .dateTime.month(.abbreviated).day())
                .font(.system(size: 10.5, weight: .medium))
                .foregroundStyle(WidgetColor.muted)
                .monospacedDigit()
        }
    }

    /// Tighter header for the small widget — the full header truncates
    /// "Weft." to "We…" and the date to "Sat · May…" at small width. We
    /// drop the brand wordmark (the arc is enough) and keep only month/day.
    private var compactHeader: some View {
        HStack(spacing: 6) {
            brandMark
            Spacer()
            Text(entry.date, format: .dateTime.month(.abbreviated).day())
                .font(.system(size: 10.5, weight: .medium))
                .foregroundStyle(WidgetColor.muted)
                .monospacedDigit()
        }
    }
}

// MARK: - Chrome

/// Brand glyph, gradient, divider, avatar, week badge, empty state, and
/// deep-link wrapper — moved into a private extension so the main view
/// struct stays under the type-body-length lint cap.
private extension TodayWidgetView {
    /// The notebook-arc glyph from the app icon, scaled to header line height.
    var brandMark: some View {
        Canvas { ctx, size in
            let arc = Path { path in
                let s = min(size.width, size.height)
                path.move(to: CGPoint(x: s * 0.18, y: s * 0.78))
                path.addQuadCurve(
                    to: CGPoint(x: s * 0.82, y: s * 0.78),
                    control: CGPoint(x: s * 0.5, y: s * 0.18)
                )
            }
            ctx.stroke(arc, with: .color(WidgetColor.sage), lineWidth: 1.2)
        }
        .frame(width: 12, height: 12)
    }

    /// Hairline between rows. Uses ink @ 6% so it reads as separation
    /// without competing with the names.
    var divider: some View {
        Rectangle()
            .fill(WidgetColor.ink.opacity(0.06))
            .frame(height: 0.5)
    }

    /// Warm cream gradient — mirrors the in-app `PersonCard.isToday` background
    /// so the top-most entry feels visually distinct.
    var todayGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.988, blue: 0.957),
                Color(red: 0.980, green: 0.965, blue: 0.918)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Colored avatar disk with the person's first initial. Mirrors the
    /// in-app `PersonAvatar`. `large=true` is for the small widget hero;
    /// the row-sized version is 22pt.
    func avatarChip(_ person: WidgetPerson, large: Bool) -> some View {
        let size: CGFloat = large ? 30 : 22
        let fontSize: CGFloat = large ? 13 : 10
        return Text(person.initial)
            .font(.system(size: fontSize, weight: .semibold))
            .foregroundStyle(WidgetColor.ink.opacity(0.75))
            .frame(width: size, height: size)
            .background(person.avatarColor.opacity(0.45), in: Circle())
            .overlay(
                Circle().strokeBorder(person.avatarColor.opacity(0.55), lineWidth: 0.5)
            )
    }

    /// Week badge. `prominent=true` uses the warm color (matches in-app
    /// "today" treatment); rest are sage.
    func weekBadge(_ weeks: Int, prominent: Bool) -> some View {
        let text = weeks <= 0 ? "now" : "\(weeks)w"
        return Text(text)
            .font(.system(size: 10.5, weight: .semibold).monospacedDigit())
            .tracking(0.4)
            .foregroundStyle(prominent
                ? Color(red: 0.66, green: 0.49, blue: 0.20)
                : WidgetColor.sage)
    }

    func emptyMessage(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, design: .serif))
            .foregroundStyle(WidgetColor.muted)
    }

    func personLink(_ person: WidgetPerson, @ViewBuilder content: () -> some View) -> some View {
        Link(destination: URL(string: "weft://person/\(person.id.uuidString)") ?? URL(filePath: "/")) {
            content().contentShape(Rectangle())
        }
    }
}
