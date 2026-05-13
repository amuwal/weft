import SwiftData
import SwiftUI

struct RootView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @State private var tab: AppTab = Self.initialTab
    @State private var showAddSheet = Self.initialFlag("--add")
    @State private var showSettings = Self.initialFlag("--settings")
    @State private var showPaywall = Self.initialFlag("--paywall")
    @State private var peoplePath: [Person] = []

    private static var initialTab: AppTab {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("--people") { return .people }
        return .today
    }

    private static func initialFlag(_ name: String) -> Bool {
        ProcessInfo.processInfo.arguments.contains(name)
    }

    private static var initialPersonName: String? {
        let args = ProcessInfo.processInfo.arguments
        guard let idx = args.firstIndex(of: "--person"), idx + 1 < args.count else { return nil }
        return args[idx + 1]
    }

    @Environment(\.modelContext) private var context
    @Query(sort: \Person.createdAt) private var people: [Person]

    private static let freeLimit = 7

    var body: some View {
        Group {
            if onboardingComplete {
                mainTabs
            } else {
                OnboardingView()
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.lingerCalm, value: onboardingComplete)
    }

    private var mainTabs: some View {
        TabView(selection: $tab) {
            NavigationStack {
                TodayView()
                    .toolbar { settingsToolbar }
            }
            .tabItem { Label("Today", systemImage: "sun.horizon") }
            .tag(AppTab.today)

            NavigationStack(path: $peoplePath) {
                PeopleListView()
                    .toolbar { settingsToolbar }
            }
            .tabItem { Label("People", systemImage: "person.2") }
            .tag(AppTab.people)
        }
        .tint(.sage)
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
        .overlay(alignment: .bottomTrailing) {
            AddButton(action: openAdd)
                .padding(.bottom, 96)
                .padding(.trailing, Spacing.xl)
        }
        .onOpenURL(perform: handleURL)
        .task { await pushInitialPersonIfRequested() }
    }

    private func pushInitialPersonIfRequested() async {
        guard let name = Self.initialPersonName else { return }
        let descriptor = FetchDescriptor<Person>()
        let people = (try? context.fetch(descriptor)) ?? []
        guard let target = people.first(where: { $0.name.lowercased() == name.lowercased() }) else { return }
        tab = .people
        peoplePath = [target]
    }

    private func handleURL(_ url: URL) {
        guard url.scheme == "linger" else { return }
        switch url.host {
        case "today": tab = .today
        case "people": tab = .people
        case "add": showAddSheet = true
        case "settings": showSettings = true
        case "paywall": showPaywall = true
        case "add-person":
            tab = .people
            showAddSheet = true
        default: break
        }
    }

    @ToolbarContentBuilder
    private var settingsToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showSettings = true
                Haptic.selection.play()
            } label: {
                Image(systemName: "gearshape")
                    .foregroundStyle(Color.muted)
            }
        }
    }

    private func openAdd() {
        if tab == .people, people.count >= Self.freeLimit {
            showPaywall = true
        } else {
            showAddSheet = true
        }
    }
}

enum AppTab: Hashable {
    case today
    case people
}

#Preview {
    RootView()
        .modelContainer(.preview)
}
