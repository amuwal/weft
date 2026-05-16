import SwiftUI
import WidgetKit

/// Lock-screen and StandBy companion to `TodayWidget`. Shows the single
/// most-pressing Today person — designed to glance at, not interact with.
struct LockTodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LockTodayWidget", provider: TodayTimelineProvider()) { entry in
            LockTodayWidgetView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Today on your wrist")
        .description("The one person Weft thinks is on your mind right now.")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

private struct LockTodayWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: TodayEntry

    var body: some View {
        switch family {
        case .accessoryRectangular: rectangular
        case .accessoryCircular: circular
        case .accessoryInline: inline
        default: rectangular
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 6))
                Text("Weft")
                    .font(.system(size: 11, weight: .semibold))
            }
            .widgetAccentable()
            if let top = entry.people.first,
               let url = URL(string: "weft://person/\(top.id.uuidString)")
            {
                Link(destination: url) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(top.name)
                            .font(.system(size: 16, weight: .semibold))
                            .lineLimit(1)
                        Text(top.reason)
                            .font(.system(size: 11))
                            .lineLimit(1)
                            .opacity(0.85)
                    }
                }
            } else {
                Text("Quiet day.")
                    .font(.system(size: 12))
                    .opacity(0.7)
            }
        }
    }

    private var circular: some View {
        Gauge(value: 0.0) {
            Text("W")
        } currentValueLabel: {
            if let top = entry.people.first {
                Text(top.name.prefix(1).uppercased())
                    .font(.system(size: 18, weight: .semibold))
                    .widgetAccentable()
            } else {
                Image(systemName: "moon.zzz")
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .gaugeStyle(.accessoryCircularCapacity)
    }

    private var inline: some View {
        if let top = entry.people.first {
            Text("\(top.name) · \(top.reason)")
        } else {
            Text("Weft · quiet day")
        }
    }
}
