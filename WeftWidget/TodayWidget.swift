import SwiftUI
import WidgetKit

/// "Who's on your mind today" — home-screen widget in three sizes.
///
/// Small  → top 1 person, name + week badge
/// Medium → top 3 people, compact row
/// Large  → top 5 people with reason snippets (Premium tier only — Free
///          users see an upgrade nudge on the large size)
///
/// Tap routes via `weft://person/<id>` deep link, handled by RootView.
struct TodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TodayWidget", provider: TodayTimelineProvider()) { entry in
            TodayWidgetView(entry: entry)
                .containerBackground(WidgetColor.bg, for: .widget)
        }
        .configurationDisplayName("Who's on your mind")
        .description("The people Weft surfaces on the Today screen, on your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}
