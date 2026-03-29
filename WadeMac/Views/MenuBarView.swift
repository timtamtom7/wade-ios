import SwiftUI

struct MenuBarView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState

    private var nextTrip: Trip? {
        appState.upcomingTrips
            .filter { $0.startDate > Date() }
            .sorted { $0.startDate < $1.startDate }
            .first
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                welcomeHeader

                if let trip = nextTrip {
                    upcomingTripSection(trip: trip)
                } else {
                    noTripsCard
                }

                quickStatsSection

                quickPackingSection

                recentActivitySection
            }
            .padding(16)
        }
        .background(Theme.surfaceLight)
    }

    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "airplane.departure")
                    .font(.title2)
                    .foregroundColor(Theme.oceanBlue)
                Text("Wade")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimaryLight)
                Spacer()
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(Theme.textPrimaryLight.opacity(0.4))
            }

            Text("Your AI Travel Companion")
                .font(.caption)
                .foregroundColor(Theme.textPrimaryLight.opacity(0.5))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Theme.oceanBlue.opacity(0.15), Theme.skyBlue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
    }

    private func upcomingTripSection(trip: Trip) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Upcoming Trip")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.textPrimaryLight.opacity(0.6))
                Spacer()
                Image(systemName: trip.style.icon)
                    .foregroundColor(Theme.sunsetOrange)
                    .font(.caption)
            }

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.destination)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimaryLight)

                    Text(trip.startDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(Theme.textPrimaryLight.opacity(0.5))
                }

                Spacer()

                CountdownBadge(days: trip.daysUntilTrip)
            }

            HStack(spacing: 8) {
                QuickActionButton(title: "View Itinerary", icon: "map.fill", color: Theme.oceanBlue) {
                    appState.selectedTab = .planner
                }
                QuickActionButton(title: "Packing List", icon: "bag.fill", color: Theme.palmGreen) {
                    appState.selectedTab = .packing
                }
                QuickActionButton(title: "Currency", icon: "dollarsign.circle.fill", color: Theme.sunsetOrange) {
                    appState.selectedTab = .currency
                }
            }
        }
        .padding(16)
        .background(Theme.cardBgLight)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private var noTripsCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "airplane")
                .font(.system(size: 36))
                .foregroundColor(Theme.textPrimaryLight.opacity(0.2))

            Text("No upcoming trips")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Theme.textPrimaryLight.opacity(0.5))

            Text("Plan your next adventure in Trip Planner")
                .font(.caption)
                .foregroundColor(Theme.textPrimaryLight.opacity(0.3))

            Button(action: { appState.selectedTab = .planner }) {
                Text("Plan a Trip")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.oceanBlue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Theme.cardBgLight)
        .cornerRadius(12)
    }

    private var quickStatsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Trips",
                value: "\(appState.upcomingTrips.count)",
                icon: "airplane",
                color: Theme.oceanBlue
            )
            StatCard(
                title: "Destinations",
                value: "\(appState.upcomingTrips.map { $0.destination }.removingDuplicates().count)",
                icon: "globe",
                color: Theme.palmGreen
            )
            StatCard(
                title: "Packing",
                value: packingProgressText,
                icon: "bag",
                color: Theme.sunsetOrange
            )
        }
    }

    private var packingProgressText: String {
        guard let list = appState.packingLists.first else { return "—" }
        let packed = list.items.filter { $0.isPacked }.count
        let total = list.items.count
        return total > 0 ? "\(packed)/\(total)" : "—"
    }

    private var quickPackingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bag.fill")
                    .foregroundColor(Theme.sunsetOrange)
                Text("Quick Packing")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimaryLight)
            }

            if let list = appState.packingLists.first {
                let unpacked = list.items.filter { !$0.isPacked }.prefix(4)

                if unpacked.isEmpty {
                    Text("All packed! 🎉")
                        .font(.caption)
                        .foregroundColor(Theme.palmGreen)
                } else {
                    ForEach(Array(unpacked)) { item in
                        HStack {
                            Image(systemName: "circle")
                                .font(.caption2)
                                .foregroundColor(Theme.textPrimaryLight.opacity(0.3))
                            Text(item.name)
                                .font(.caption)
                                .foregroundColor(Theme.textPrimaryLight)
                            Spacer()
                            Text(item.category.rawValue)
                                .font(.caption2)
                                .foregroundColor(Theme.textPrimaryLight.opacity(0.3))
                        }
                    }
                }
            } else {
                Text("No packing list available")
                    .font(.caption)
                    .foregroundColor(Theme.textPrimaryLight.opacity(0.3))
            }
        }
        .padding(16)
        .background(Theme.cardBgLight)
        .cornerRadius(12)
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(Theme.oceanBlue)
                Text("Quick Access")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimaryLight)
            }

            VStack(spacing: 6) {
                QuickAccessRow(icon: "map.fill", title: "Trip Planner", subtitle: "Plan your next adventure", color: Theme.oceanBlue) {
                    appState.selectedTab = .planner
                }
                QuickAccessRow(icon: "globe", title: "Destinations", subtitle: "Browse travel ideas", color: Theme.palmGreen) {
                    appState.selectedTab = .destinations
                }
                QuickAccessRow(icon: "dollarsign.circle.fill", title: "Currency Converter", subtitle: "Convert & calculate tips", color: Theme.sunsetOrange) {
                    appState.selectedTab = .currency
                }
            }
        }
        .padding(16)
        .background(Theme.cardBgLight)
        .cornerRadius(12)
    }
}

struct CountdownBadge: View {
    let days: Int

    var body: some View {
        VStack(spacing: 2) {
            Text("\(max(0, days))")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Theme.oceanBlue)
            Text(days == 1 ? "day" : "days")
                .font(.caption2)
                .foregroundColor(Theme.textPrimaryLight.opacity(0.5))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Theme.oceanBlue.opacity(0.1))
        .cornerRadius(10)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(Theme.textPrimaryLight)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Theme.surfaceLight)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimaryLight)
            Text(title)
                .font(.caption2)
                .foregroundColor(Theme.textPrimaryLight.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Theme.cardBgLight)
        .cornerRadius(10)
    }
}

struct QuickAccessRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                    .background(color.opacity(0.1))
                    .cornerRadius(6)

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.textPrimaryLight)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(Theme.textPrimaryLight.opacity(0.4))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(Theme.textPrimaryLight.opacity(0.2))
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
