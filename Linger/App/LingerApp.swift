import SwiftData
import SwiftUI

@main
struct LingerApp: App {
    let modelContainer: ModelContainer
    @AppStorage("themeRaw") private var themeRaw: String = ThemeChoice.auto.rawValue
    @AppStorage("accentRaw") private var accentRaw: String = AccentChoice.sage.rawValue

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
            let args = ProcessInfo.processInfo.arguments
            if args.contains("--onboarding-done") {
                UserDefaults.standard.set(true, forKey: "onboardingComplete")
            }
            if args.contains("--seed") {
                MainActor.assumeIsolated {
                    let context = container.mainContext
                    let existing = (try? context.fetch(FetchDescriptor<Person>()).count) ?? 0
                    if existing == 0 {
                        SampleData.populate(context)
                        try? context.save()
                    }
                }
            }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(modelContainer)
                .tint(AccentChoice(rawValue: accentRaw)?.color ?? .sage)
                .preferredColorScheme(ThemeChoice(rawValue: themeRaw)?.colorScheme)
                .background(Color.bg.ignoresSafeArea())
        }
    }
}
