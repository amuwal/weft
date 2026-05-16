import AppIntents
import Foundation

/// Registers Weft's three intents with the system so they appear in:
///   • the Shortcuts app (catalog under "Weft")
///   • Siri suggestions on the lock screen / search
///   • Spotlight (typing a phrase)
///   • the Action Button + back-tap, when the user wires one
///
/// `AppShortcutsProvider` is auto-discovered by the App Intents framework at
/// app launch — no registration code needed in WeftApp.
struct WeftShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddWeftNoteIntent(),
            phrases: [
                "Add a note in \(.applicationName)",
                "Add a \(.applicationName) note",
                "Save a note in \(.applicationName)"
            ],
            shortTitle: "Add note",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: OpenPersonIntent(),
            phrases: [
                "Open a person in \(.applicationName)",
                "Show me a person in \(.applicationName)"
            ],
            shortTitle: "Open person",
            systemImageName: "person.crop.circle"
        )
        AppShortcut(
            intent: WhosOnYourMindTodayIntent(),
            phrases: [
                "Who's on my mind in \(.applicationName)",
                "What's in \(.applicationName) today",
                "Show me today in \(.applicationName)"
            ],
            shortTitle: "Today",
            systemImageName: "sun.max"
        )
    }

    /// Sage tile in the Shortcuts catalog. Apple's enum doesn't expose a
    /// custom hex, so we pick the closest preset.
    static let shortcutTileColor: ShortcutTileColor = .grayGreen
}
