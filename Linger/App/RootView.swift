import SwiftData
import SwiftUI

struct RootView: View {
    @State private var tab: AppTab = .today
    @State private var showAddSheet = false

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack {
                TodayView()
            }
            .tabItem { Label("Today", systemImage: "sun.horizon") }
            .tag(AppTab.today)

            NavigationStack {
                PeopleListView()
            }
            .tabItem { Label("People", systemImage: "person.2") }
            .tag(AppTab.people)
        }
        .sheet(isPresented: $showAddSheet) {
            AddSheet()
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(28)
        }
        .overlay(alignment: .bottom) {
            AddButton { showAddSheet = true }
                .padding(.bottom, 96)
                .padding(.trailing, 24)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .allowsHitTesting(true)
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
