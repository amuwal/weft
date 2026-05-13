import SwiftData
import SwiftUI

@main
struct LingerApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            self.modelContainer = try ModelContainer.linger()
        } catch {
            // A failure here means SwiftData could not bring up the persistent store,
            // which is unrecoverable in production. Surface it with a useful message.
            assertionFailure("SwiftData container failed to initialize: \(error)")
            fatalError("Linger could not start its data store. Reinstall the app.")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(modelContainer)
                .tint(.sage)
                .preferredColorScheme(nil)
        }
    }
}
