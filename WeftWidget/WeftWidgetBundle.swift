import SwiftUI
import WidgetKit

/// Entry point for Weft's widget extension. Declares the widgets exposed to
/// the OS — discoverable from the home-screen widget gallery, the lock-screen
/// editor, and (on supported devices) StandBy mode.
@main
struct WeftWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
        LockTodayWidget()
    }
}
