import SwiftData
import SwiftUI
import WidgetKit

struct RootView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @State private var tab: AppTab = Self.initialTab
    @State private var showAddSheet = Self.initialFlag("--add")
    @State private var showSettings = Self.initialFlag("--settings")
    @State private var showPaywall = Self.initialFlag("--paywall")
    /// In release builds this stays `false` and the sheet modifier is a no-op.
    /// In DEBUG builds the `--widget-preview` launch arg sets it true. Wrapped
    /// to avoid `#if DEBUG` interleaved with view-modifier chains, which
    /// confuses swiftformat + swiftlint indentation rules.
    @State private var showWidgetPreview = Self.debugWidgetPreviewFlag

    private static var debugWidgetPreviewFlag: Bool {
        #if DEBUG
            return initialFlag("--widget-preview")
        #else
            return false
        #endif
    }

    @State private var peoplePath: [Person] = []
    @State private var todayPath: [Person] = []
    @State private var didAppear = false

    @Environment(\.modelContext) private var context
    @Environment(Entitlements.self) private var entitlements
    @Query(sort: \Person.createdAt) private var people: [Person]

    private static var initialTab: AppTab {
        ProcessInfo.processInfo.arguments.contains("--people") ? .people : .today
    }

    private static func initialFlag(_ name: String) -> Bool {
        ProcessInfo.processInfo.arguments.contains(name)
    }

    private static var initialPersonName: String? {
        let args = ProcessInfo.processInfo.arguments
        guard let idx = args.firstIndex(of: "--person"), idx + 1 < args.count else { return nil }
        return args[idx + 1]
    }

    var body: some View {
        Group {
            if onboardingComplete {
                mainShell
            } else {
                OnboardingView()
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.weftCalm, value: onboardingComplete)
        .opacity(didAppear ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.45)) { didAppear = true }
        }
    }

    private var mainShell: some View {
        ZStack(alignment: .bottom) {
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.bg.ignoresSafeArea())

            WeftTabBar(
                selected: $tab,
                onAdd: openAdd
            )
            .padding(.horizontal, Spacing.l)
            .padding(.bottom, 12)
            .opacity(isOnDrillDown ? 0 : 1)
            .offset(y: isOnDrillDown ? 120 : 0)
            .animation(.weftSpring, value: isOnDrillDown)
            .allowsHitTesting(!isOnDrillDown)
        }
        .sheet(isPresented: $showAddSheet) {
            AddSheet(initial: tab == .people ? .person : .note)
                .presentationDetents([.large])
                .presentationCornerRadius(28)
                .presentationBackground(.regularMaterial)
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack { SettingsView() }
                .presentationDetents([.large])
                .presentationCornerRadius(28)
                .presentationBackground(.regularMaterial)
        }
        .sheet(isPresented: $showPaywall) {
            NavigationStack { PaywallView() }
                .presentationDetents([.large])
                .presentationCornerRadius(28)
                .presentationBackground(.regularMaterial)
        }
        .sheet(isPresented: $showWidgetPreview) {
            #if DEBUG
                NavigationStack { widgetPreviewSheet }
                    .presentationDetents([.large])
            #else
                EmptyView()
            #endif
        }
        .onOpenURL(perform: handleURL)
        .task { await pushInitialPersonIfRequested() }
        .task { await consumePendingDeepLink() }
        .onReceive(didBecomeActivePublisher) { _ in
            Task { await consumePendingDeepLink() }
        }
    }

    #if DEBUG
        /// Builds a real `TodayEntry` from the same scoring pipeline the
        /// widget uses, then renders it at the three home-screen sizes
        /// and at the rectangular lock-screen accessory size. Triggered
        /// by `--widget-preview` launch arg.
        private var widgetPreviewSheet: WidgetPreviewScreen {
            let people = Array(loadedSurfacedPeople().prefix(5))
            let isPremium = entitlements.isPremium
            let premiumEntry = TodayEntry(date: .now, people: people, isPremium: true)
            let freeEntry = TodayEntry(date: .now, people: people, isPremium: false)
            let small = TodayWidgetView(entry: premiumEntry, familyOverride: .systemSmall)
            let medium = TodayWidgetView(entry: premiumEntry, familyOverride: .systemMedium)
            let large = TodayWidgetView(entry: premiumEntry, familyOverride: .systemLarge)
            let largeFree = TodayWidgetView(entry: freeEntry, familyOverride: .systemLarge)
            // Native iOS widget frame sizes on iPhone Pro / 17 Pro (393pt wide):
            //   .systemSmall  = 158 × 158
            //   .systemMedium = 338 × 158
            //   .systemLarge  = 338 × 354
            // Using exact frames so the preview screen matches the on-device render.
            return WidgetPreviewScreen(
                entries: [
                    ("SMALL", WidgetPreviewEntry(small, width: 158, height: 158)),
                    ("MEDIUM", WidgetPreviewEntry(medium, width: 338, height: 158)),
                    ("LARGE · PREMIUM", WidgetPreviewEntry(large, width: 338, height: 354)),
                    ("LARGE · FREE TIER", WidgetPreviewEntry(largeFree, width: 338, height: 354))
                ],
                currentlyPremium: isPremium
            )
        }

        @MainActor
        private func loadedSurfacedPeople() -> [WidgetPerson] {
            let active = people.filter { !$0.isSnoozed }
            let inputs = active.map { person in
                ScoreInput(
                    id: person.id,
                    lastTouchedAt: latestTouch(for: person),
                    createdAt: person.createdAt,
                    rhythm: person.rhythm,
                    weight: person.relationship.weight,
                    birthday: person.birthday,
                    earliestOpenThreadDue: person.threadsOrEmpty
                        .filter(\.isOpen)
                        .map(\.dueDate)
                        .min()
                )
            }
            let ranked = ScoringService.ranked(people: inputs)
            let byID = Dictionary(uniqueKeysWithValues: active.map { ($0.id, $0) })
            return ranked.compactMap { candidate -> WidgetPerson? in
                guard let person = byID[candidate.personID] else { return nil }
                let weeks = weeksSince(latestTouch(for: person))
                return WidgetPerson(
                    id: person.id,
                    name: person.name,
                    reason: previewReason(for: candidate.reason, weeks: weeks),
                    weeks: weeks,
                    paletteKey: person.avatarPalette.rawValue
                )
            }
        }

        private func latestTouch(for person: Person) -> Date? {
            let lastNote = person.notesOrEmpty.map(\.createdAt).max()
            let lastTouchpoint = person.touchpointsOrEmpty.map(\.createdAt).max()
            return [lastNote, lastTouchpoint].compactMap(\.self).max()
        }

        private func weeksSince(_ date: Date?) -> Int {
            guard let date else { return 0 }
            return max(0, Int(Date.now.timeIntervalSince(date) / (7 * 86400)))
        }

        private func previewReason(for reason: SurfaceReason, weeks: Int) -> String {
            switch reason {
            case .threadDue: loc("Follow-up due.")
            case .birthday: loc("It's their birthday.")
            case .onRhythm:
                if weeks <= 0 {
                    loc("It's been a few days.")
                } else if weeks == 1 {
                    loc("It's been a week.")
                } else if weeks >= 12 {
                    loc("It's been a while.")
                } else {
                    loc("It's been %lld weeks.", weeks)
                }
            }
        }
    #endif

    private var didBecomeActivePublisher: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch tab {
        case .today:
            NavigationStack(path: $todayPath) {
                TodayView(path: $todayPath)
                    .toolbar { titleToolbar(.today)
                        settingsToolbar
                    }
            }
            .transition(.opacity)
        case .people:
            NavigationStack(path: $peoplePath) {
                PeopleListView()
                    .toolbar { titleToolbar(.people)
                        settingsToolbar
                    }
            }
            .transition(.opacity)
        }
    }

    @ToolbarContentBuilder
    private func titleToolbar(_ tab: AppTab) -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(tab == .today ? "Weft." : "People")
                .font(.system(size: 17, design: .serif).weight(.medium))
                .foregroundStyle(Color.ink)
                .tracking(0.3)
        }
    }

    @ToolbarContentBuilder
    private var settingsToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Haptic.selection.play()
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .foregroundStyle(Color.muted)
            }
            .accessibilityLabel("Settings")
        }
    }

    private func openAdd() {
        let atLimit = people.count >= Entitlements.freePeopleLimit
        if tab == .people, atLimit, !entitlements.isPremium {
            showPaywall = true
        } else {
            showAddSheet = true
        }
    }

    private var isOnDrillDown: Bool {
        switch tab {
        case .today: !todayPath.isEmpty
        case .people: !peoplePath.isEmpty
        }
    }

    private func pushInitialPersonIfRequested() async {
        guard let name = Self.initialPersonName else { return }
        let descriptor = FetchDescriptor<Person>()
        let people = (try? context.fetch(descriptor)) ?? []
        guard let target = people.first(where: { $0.name.lowercased() == name.lowercased() }) else { return }
        tab = .people
        peoplePath = [target]
    }

    /// App Intents write the target person's id to UserDefaults and then ask
    /// the system to bring Weft to the foreground. We pick that up on launch
    /// (`task`) and on every foreground transition (`didBecomeActive`), then
    /// clear the key so the navigation doesn't re-fire on the next launch.
    private func consumePendingDeepLink() async {
        let defaults = UserDefaults.standard
        guard let raw = defaults.string(forKey: PendingDeepLink.openPersonKey),
              let uuid = UUID(uuidString: raw)
        else { return }
        defaults.removeObject(forKey: PendingDeepLink.openPersonKey)

        let descriptor = FetchDescriptor<Person>()
        let allPeople = (try? context.fetch(descriptor)) ?? []
        guard let target = allPeople.first(where: { $0.id == uuid }) else { return }
        tab = .people
        peoplePath = [target]
    }

    private func handleURL(_ url: URL) {
        guard url.scheme == "weft" else { return }
        switch url.host {
        case "today": tab = .today
        case "people": tab = .people
        case "add": showAddSheet = true
        case "settings": showSettings = true
        case "paywall": showPaywall = true
        case "add-person":
            tab = .people
            showAddSheet = true
        case "person":
            routeToPerson(url: url)
        default: break
        }
    }

    /// `weft://person/<uuid>` — fired by widget taps. Looks the person up in
    /// SwiftData and pushes the matching detail view onto the People stack.
    /// Silently no-ops when the id is malformed or the person was deleted,
    /// rather than dumping the user on a broken empty screen.
    private func routeToPerson(url: URL) {
        let idString = url.pathComponents.dropFirst().first ?? ""
        guard let uuid = UUID(uuidString: idString) else { return }
        let descriptor = FetchDescriptor<Person>()
        let allPeople = (try? context.fetch(descriptor)) ?? []
        guard let target = allPeople.first(where: { $0.id == uuid }) else { return }
        tab = .people
        peoplePath = [target]
    }
}

enum AppTab: Hashable {
    case today
    case people
}

#Preview {
    RootView()
        .modelContainer(.preview)
        .environment(Entitlements())
}
