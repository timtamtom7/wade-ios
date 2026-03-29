import SwiftUI

struct BookingIntegrationView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    @StateObject private var travelService = TravelUpdateService.shared

    @State private var selectedTrip: Trip?
    @State private var flightNumber: String = ""
    @State private var isTrackingFlight: Bool = false
    @State private var showCostTracker: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                flightTrackerSection
                bookingLinksSection
                costTrackingSection
                travelDocumentsSection
            }
            .padding(20)
        }
        .background(Theme.surfaceLight)
        .onAppear {
            travelService.fetchExchangeRates()
        }
    }

    // MARK: - Flight Tracker

    private var flightTrackerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "airplane")
                    .foregroundColor(Theme.oceanBlue)
                Text("Flight Tracker")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimaryLight)
                Spacer()
                if isTrackingFlight {
                    Button("Stop Tracking") {
                        isTrackingFlight = false
                    }
                    .font(.caption)
                    .foregroundColor(Theme.accentCoral)
                }
            }

            HStack {
                TextField("Enter flight number (e.g., AA123)", text: $flightNumber)
                    .textFieldStyle(.plain)
                    .padding(10)
                    .background(Theme.surfaceLight)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.oceanBlue.opacity(0.3), lineWidth: 1)
                    )
                    .onChange(of: flightNumber) { newValue in
                        flightNumber = newValue.uppercased()
                    }

                Button(action: trackFlight) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Track")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.oceanBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(flightNumber.isEmpty)
            }

            if let flight = flightUpdates.first {
                FlightStatusCard(flight: flight)
            }
        }
        .padding(16)
        .background(Theme.cardBgLight)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private var flightUpdates: [TravelUpdateService.FlightUpdate] {
        Array(TravelUpdateService.shared.flightUpdates.values)
    }

    private func trackFlight() {
        guard !flightNumber.isEmpty else { return }
        isTrackingFlight = true
        TravelUpdateService.shared.trackFlight(number: flightNumber)
    }

    // MARK: - Booking Links

    private var bookingLinksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "link")
                    .foregroundColor(Theme.oceanBlue)
                Text("Quick Booking")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimaryLight)
                Spacer()
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                BookingLinkCard(
                    title: "Flights",
                    subtitle: "Search Skyscanner",
                    icon: "airplane.circle.fill",
                    color: Theme.oceanBlue
                ) {
                    openSkyscanner()
                }

                BookingLinkCard(
                    title: "Hotels",
                    subtitle: "Search Booking.com",
                    icon: "bed.double.fill",
                    color: Theme.palmGreen
                ) {
                    openBooking()
                }

                BookingLinkCard(
                    title: "Restaurants",
                    subtitle: "OpenTable / Yelp",
                    icon: "fork.knife",
                    color: Theme.sunsetOrange
                ) {
                    openRestaurantSearch()
                }

                BookingLinkCard(
                    title: "Activities",
                    subtitle: "Viator / GetYourGuide",
                    icon: "ticket.fill",
                    color: Theme.skyBlue
                ) {
                    openActivities()
                }
            }

            if let trip = selectedTrip ?? appState.selectedTrip ?? appState.upcomingTrips.first {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Booking for: \(trip.destination)")
                        .font(.caption)
                        .foregroundColor(Theme.textPrimaryLight.opacity(0.6))

                    HStack(spacing: 8) {
                        Button(action: { openSkyscanner(for: trip.destination) }) {
                            HStack {
                                Image(systemName: "airplane")
                                Text("Book Flight to \(trip.destination)")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Theme.oceanBlue.opacity(0.1))
                            .foregroundColor(Theme.oceanBlue)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)

                        Button(action: { openBooking(for: trip.destination) }) {
                            HStack {
                                Image(systemName: "bed.double")
                                Text("Book Hotel")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Theme.palmGreen.opacity(0.1))
                            .foregroundColor(Theme.palmGreen)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(16)
        .background(Theme.cardBgLight)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Cost Tracking

    private var costTrackingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(Theme.sunsetOrange)
                Text("Trip Costs")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimaryLight)
                Spacer()
                Button(action: { showCostTracker.toggle() }) {
                    Image(systemName: showCostTracker ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(Theme.textPrimaryLight.opacity(0.5))
                }
            }

            if let trip = selectedTrip ?? appState.selectedTrip ?? appState.upcomingTrips.first {
                TripCostSummary(trip: trip)
            } else {
                Text("No trip selected. Select a trip to track costs.")
                    .font(.caption)
                    .foregroundColor(Theme.textPrimaryLight.opacity(0.5))
                    .padding(.vertical, 8)
            }
        }
        .padding(16)
        .background(Theme.cardBgLight)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Travel Documents

    private var travelDocumentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(Theme.midnight)
                Text("Travel Documents")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimaryLight)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Theme.oceanBlue)
                }
            }

            VStack(spacing: 8) {
                DocumentRow(type: "Passport", status: .valid, expiryDate: Date().addingTimeInterval(86400 * 365 * 3))
                DocumentRow(type: "Travel Insurance", status: .valid, expiryDate: Date().addingTimeInterval(86400 * 180))
                DocumentRow(type: "Visa", status: .checkRequired, expiryDate: nil)
            }

            Text("Store flight confirmations, hotel bookings, and travel insurance details securely.")
                .font(.caption2)
                .foregroundColor(Theme.textPrimaryLight.opacity(0.5))
        }
        .padding(16)
        .background(Theme.cardBgLight)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Deep Link Functions

    private func openSkyscanner(for destination: String? = nil) {
        let query = destination ?? selectedTrip?.destination ?? ""
        let urlString = "https://www.skyscanner.com/transport/flights-to/\(query.lowercased().replacingOccurrences(of: " ", with: "-"))/"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }

    private func openBooking(for destination: String? = nil) {
        let query = destination ?? selectedTrip?.destination ?? ""
        let urlString = "https://www.booking.com/searchresults.html?ss=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }

    private func openRestaurantSearch() {
        let destination = selectedTrip?.destination ?? ""
        let urlString = "https://www.yelp.com/search?find_desc=Restaurants&find_loc=\(destination.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? destination)"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }

    private func openActivities() {
        let destination = selectedTrip?.destination ?? ""
        let urlString = "https://www.viator.com/search/\(destination.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? destination)"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Supporting Views

struct BookingLinkCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.textPrimaryLight)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(Theme.textPrimaryLight.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.surfaceLight)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct FlightStatusCard: View {
    let flight: TravelUpdateService.FlightUpdate

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(flight.flightNumber)
                        .font(.headline)
                        .foregroundColor(Theme.textPrimaryLight)
                    Text(flight.airline)
                        .font(.caption)
                        .foregroundColor(Theme.textPrimaryLight.opacity(0.6))
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: flight.status.icon)
                    Text(flight.status.rawValue)
                }
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.1))
                .cornerRadius(6)
            }

            HStack {
                VStack {
                    Text(flight.departureAirport)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(flight.scheduledDeparture.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                }
                Spacer()
                Image(systemName: "airplane")
                    .foregroundColor(Theme.oceanBlue)
                Spacer()
                VStack {
                    Text(flight.arrivalAirport)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(flight.scheduledArrival.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                }
            }

            Text(flight.statusDescription)
                .font(.caption)
                .foregroundColor(Theme.textPrimaryLight.opacity(0.7))
        }
        .padding(12)
        .background(Theme.surfaceLight)
        .cornerRadius(8)
    }

    private var statusColor: Color {
        switch flight.status.color {
        case "palmGreen": return Theme.palmGreen
        case "sunsetOrange": return Theme.sunsetOrange
        case "accentCoral": return Theme.accentCoral
        default: return Theme.oceanBlue
        }
    }
}

struct TripCostSummary: View {
    let trip: Trip
    @State private var costs: [CostItem] = []

    var body: some View {
        VStack(spacing: 8) {
            ForEach(costs) { cost in
                CostRow(item: cost)
            }

            HStack {
                Text("Add Cost")
                    .font(.caption)
                    .foregroundColor(Theme.oceanBlue)
                Spacer()
                Button(action: addCost) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Theme.oceanBlue)
                }
            }

            Divider()

            HStack {
                Text("Estimated Total")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
                Text(formattedTotal)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.oceanBlue)
            }
        }
        .onAppear {
            costs = [
                CostItem(category: "Flights", amount: 850, currency: "USD", icon: "airplane"),
                CostItem(category: "Hotels", amount: 420, currency: "USD", icon: "bed.double"),
                CostItem(category: "Activities", amount: 200, currency: "USD", icon: "ticket"),
            ]
        }
    }

    private var formattedTotal: String {
        let total = costs.reduce(0) { $0 + $1.amount }
        return String(format: "$%.2f", total)
    }

    private func addCost() {
        costs.append(CostItem(category: "Other", amount: 0, currency: "USD", icon: "bag"))
    }
}

struct CostItem: Identifiable {
    let id = UUID()
    var category: String
    var amount: Double
    var currency: String
    var icon: String
}

struct CostRow: View {
    let item: CostItem

    var body: some View {
        HStack {
            Image(systemName: item.icon)
                .foregroundColor(Theme.oceanBlue)
                .frame(width: 20)
            Text(item.category)
                .font(.subheadline)
            Spacer()
            Text(String(format: "$%.2f", item.amount))
                .font(.subheadline)
                .foregroundColor(Theme.textPrimaryLight)
        }
        .padding(.vertical, 4)
    }
}

struct DocumentRow: View {
    let type: String
    let status: DocumentStatus
    let expiryDate: Date?

    enum DocumentStatus {
        case valid, expiringSoon, expired, checkRequired

        var color: Color {
            switch self {
            case .valid: return Theme.palmGreen
            case .expiringSoon: return Theme.sunsetOrange
            case .expired: return Theme.accentCoral
            case .checkRequired: return Theme.textPrimaryLight.opacity(0.5)
            }
        }

        var label: String {
            switch self {
            case .valid: return "Valid"
            case .expiringSoon: return "Expiring Soon"
            case .expired: return "Expired"
            case .checkRequired: return "Check Required"
            }
        }
    }

    var body: some View {
        HStack {
            Image(systemName: "doc.text")
                .foregroundColor(Theme.oceanBlue)
                .frame(width: 20)
            Text(type)
                .font(.subheadline)
            if let date = expiryDate {
                Text("• Expires \(date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(Theme.textPrimaryLight.opacity(0.5))
            }
            Spacer()
            Text(status.label)
                .font(.caption)
                .foregroundColor(status.color)
        }
        .padding(.vertical, 4)
    }
}
