import AppIntents
import Foundation
import UIKit

/// "Open Sarah in Weft." Opens the app and pushes that person's detail view.
///
/// We can't directly drive SwiftUI navigation from inside an App Intent process,
/// so the intent writes the target id to a known UserDefaults key and opens
/// the app. RootView reads the pending id on appear and pushes the matching
/// person onto the People stack.
struct OpenPersonIntent: AppIntent {
    static let title: LocalizedStringResource = "Open person in Weft"
    static let description = IntentDescription(
        "Jumps straight into a person's detail view.",
        categoryName: "Navigation"
    )
    static let openAppWhenRun: Bool = true

    @Parameter(title: "Person", description: "Who to open.")
    var person: PersonEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$person) in Weft")
    }

    func perform() async throws -> some IntentResult {
        // Persist the target id so the app can route to it on cold launch.
        // RootView reads + clears this key.
        UserDefaults.standard.set(person.id.uuidString, forKey: PendingDeepLink.openPersonKey)
        return .result()
    }
}

/// Shared key constants so the app side and intent side agree on a
/// rendezvous. Kept in one place rather than scattered string literals.
enum PendingDeepLink {
    static let openPersonKey = "weft.pendingOpenPersonID"
}
