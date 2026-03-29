import SwiftUI

struct TravelBuddiesView: View {
    @StateObject private var viewModel = TravelBuddiesViewModel()
    @State private var searchText = ""
    @State private var selectedDestination = "Tokyo"
    @State private var showConnectSheet = false
    @State private var selectedBuddy: BuddyMatch?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Search & Filters
            filtersView

            Divider()

            // Buddy Matches List
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if filteredBuddies.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(filteredBuddies) { buddy in
                            BuddyCardView(buddy: buddy) {
                                selectedBuddy = buddy
                                showConnectSheet = true
                            } onConnect: {
                                viewModel.connectWithBuddy(buddy)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(Theme.surface)
        .sheet(isPresented: $showConnectSheet) {
            if let buddy = selectedBuddy {
                BuddyDetailSheet(buddy: buddy, isPresented: $showConnectSheet)
            }
        }
        .onAppear {
            viewModel.loadBuddies(for: selectedDestination)
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.2.fill")
                    .font(.title2)
                    .foregroundColor(Theme.oceanBlue)

                Text("Travel Buddies")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Text("\(viewModel.buddies.count) matches")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text("Find people traveling to the same destination")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private var filtersView: some View {
        VStack(spacing: 12) {
            // Destination Picker
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(Theme.oceanBlue)

                Picker("Destination", selection: $selectedDestination) {
                    Text("Tokyo").tag("Tokyo")
                    Text("Lisbon").tag("Lisbon")
                    Text("Bali").tag("Bali")
                    Text("Paris").tag("Paris")
                    Text("New York").tag("New York")
                }
                .pickerStyle(.menu)
                .onChange(of: selectedDestination) { _, newValue in
                    viewModel.loadBuddies(for: newValue)
                }

                Spacer()
            }

            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search by name or interest", text: $searchText)
                    .textFieldStyle(.plain)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Theme.surface)
            .cornerRadius(10)
        }
        .padding()
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No travel buddies found")
                .font(.headline)

            Text("Try a different destination or check back later")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }

    private var filteredBuddies: [BuddyMatch] {
        if searchText.isEmpty {
            return viewModel.buddies
        }
        return viewModel.buddies.filter {
            $0.userName.localizedCaseInsensitiveContains(searchText) ||
            $0.destination.localizedCaseInsensitiveContains(searchText)
        }
    }
}

// MARK: - Buddy Card

struct BuddyCardView: View {
    let buddy: BuddyMatch
    let onTap: () -> Void
    let onConnect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Avatar
                avatarView

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(buddy.userName)
                        .font(.headline)

                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .font(.caption)
                        Text("Going to \(buddy.destination)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: buddy.travelStyle.icon)
                            .font(.caption)
                        Text(buddy.travelStyle.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(Theme.oceanBlue)
                }

                Spacer()

                // Compatibility Score
                VStack {
                    Text("\(Int(buddy.compatibilityScore * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.oceanBlue)
                    Text("match")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Bottom row
            HStack {
                // Mutual contacts
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.caption)
                    Text("\(buddy.mutualContacts) contacts going")
                        .font(.caption)
                }
                .foregroundColor(.secondary)

                Spacer()

                // Connection status & button
                if buddy.connectionStatus == .connected {
                    Label("Connected", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Button("Connect") {
                        onConnect()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.oceanBlue)
                    .controlSize(.small)
                }
            }
        }
        .padding()
        .background(Theme.surface)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .onTapGesture {
            onTap()
        }
    }

    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(Theme.oceanBlue.opacity(0.15))

            Text(String(buddy.userName.prefix(1)))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Theme.oceanBlue)
        }
        .frame(width: 50, height: 50)
    }
}

// MARK: - Buddy Detail Sheet

struct BuddyDetailSheet: View {
    let buddy: BuddyMatch
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Theme.oceanBlue.opacity(0.15))
                                .frame(width: 80, height: 80)

                            Text(String(buddy.userName.prefix(1)))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.oceanBlue)
                        }

                        Text(buddy.userName)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("\(Int(buddy.compatibilityScore * 100))% travel compatibility")
                            .font(.subheadline)
                            .foregroundColor(Theme.oceanBlue)
                    }
                    .padding(.top)

                    // Travel Details
                    VStack(alignment: .leading, spacing: 16) {
                        detailRow(icon: "globe", title: "Destination", value: buddy.destination)
                        detailRow(icon: "calendar", title: "Dates", value: formatDateRange(buddy.travelDates))
                        detailRow(icon: buddy.travelStyle.icon, title: "Travel Style", value: buddy.travelStyle.rawValue)
                        detailRow(icon: "person.2", title: "Mutual Contacts", value: "\(buddy.mutualContacts) people you know")
                    }
                    .padding()
                    .background(Theme.surface)
                    .cornerRadius(12)

                    // Connect Actions
                    VStack(spacing: 12) {
                        Button {
                            // Deep link to messaging app
                        } label: {
                            Label("Message on Telegram", systemImage: "paperplane.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.oceanBlue)

                        Button {
                            // Deep link to WhatsApp
                        } label: {
                            Label("Add to WhatsApp Group", systemImage: "bubble.left.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Travel Buddy")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Theme.oceanBlue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }

            Spacer()
        }
    }

    private func formatDateRange(_ interval: DateInterval) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: interval.start)
    }
}

// MARK: - ViewModel

@MainActor
final class TravelBuddiesViewModel: ObservableObject {
    @Published var buddies: [BuddyMatch] = []
    @Published var isLoading = false

    private let socialService = TravelSocialService.shared

    func loadBuddies(for destination: String) {
        isLoading = true
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            let found = self.socialService.findTravelBuddies(
                destination: destination,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 7)
            )
            self.buddies = found
            self.isLoading = false
        }
    }

    func connectWithBuddy(_ buddy: BuddyMatch) {
        socialService.connectWithBuddy(buddyId: buddy.id)
        if let index = buddies.firstIndex(where: { $0.id == buddy.id }) {
            buddies[index].connectionStatus = .connected
        }
    }
}
