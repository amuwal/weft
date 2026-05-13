import SwiftData
import SwiftUI

@main
struct LingerApp: App {
    let modelContainer: ModelContainer
    @AppStorage("themeRaw") private var themeRaw: String = ThemeChoice.auto.rawValue

    init() {
        let container: ModelContainer
        do {
            container = try ModelContainer.linger()
        } catch {
            assertionFailure("SwiftData container failed to initialize: \(error)")
            fatalError("Linger could not start its data store. Reinstall the app.")
        }
        self.modelContainer = container
        #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--seed") {
                Task { @MainActor in
                    let context = container.mainContext
                    let existing = (try? context.fetch(FetchDescriptor<Person>()).count) ?? 0
                    if existing == 0 { SampleData.populate(context) }
                }
            }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(modelContainer)
                .tint(.sage)
                .preferredColorScheme(ThemeChoice(rawValue: themeRaw)?.colorScheme)
                .background(Color.bg.ignoresSafeArea())
        }
    }
}
