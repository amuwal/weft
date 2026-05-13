import SwiftData
import SwiftUI

struct RootView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @State private var tab: AppTab = Self.initialTab
    @State private var showAddSheet = Self.initialFlag("--add")
    @State private var showSettings = Self.initialFlag("--settings")
    @State private var showPaywall = Self.initialFlag("--paywall")
    @State private var peoplePath: [Person] = []
    @State private var didAppear = false

    @Environment(\.modelContext) private var context
    @Query(sort: \Person.createdAt) private var people: [Person]

    private static let freeLimit = 7

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
        .animation(.lingerCalm, value: onboardingComplete)
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

            LingerTabBar(
                selected: $tab,
                onAdd: openAdd
            )
            .padding(.horizontal, Spacing.l)
            .padding(.bottom, 12)
            .opacity(isOnDrillDown ? 0 : 1)
            .offset(y: isOnDrillDown ? 120 : 0)
            .animation(.lingerSpring, value: isOnDrillDown)
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
        .onOpenURL(perform: handleURL)
        .task { await pushInitialPersonIfRequested() }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch tab {
        case .today:
            NavigationStack {
                TodayView()
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
            Text(tab == .today ? "Linger." : "People")
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
        if tab == .people, people.count >= Self.freeLimit {
            showPaywall = true
        } else {
            showAddSheet = true
        }
    }

    private var isOnDrillDown: Bool {
        tab == .people && !peoplePath.isEmpty
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
}

enum AppTab: Hashable {
    case today
    case people
}

#Preview {
    RootView()
        .modelContainer(.preview)
}
