import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            TabBar(selectedTab: $appState.selectedTab)

            Divider()

            TabView(selection: $appState.selectedTab) {
                TripPlannerView()
                    .tag(AppState.Tab.planner)

                DestinationView()
                    .tag(AppState.Tab.destinations)

                PackingListView()
                    .tag(AppState.Tab.packing)

                CurrencyView()
                    .tag(AppState.Tab.currency)

                MenuBarView()
                    .tag(AppState.Tab.menubar)
            }
            .tabViewStyle(.automatic)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Theme.surface)
    }
}

struct TabBar: View {
    @Binding var selectedTab: AppState.Tab

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppState.Tab.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Theme.surface)
    }
}

struct TabBarButton: View {
    let tab: AppState.Tab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? Theme.oceanBlue : Theme.textPrimary.opacity(0.5))

                Text(tab.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? Theme.oceanBlue : Theme.textPrimary.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Theme.oceanBlue.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}
