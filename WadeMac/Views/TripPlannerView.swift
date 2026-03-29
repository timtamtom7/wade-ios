import SwiftUI
import NaturalLanguage

struct TripPlannerView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    @State private var destination: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(86400 * 7)
    @State private var selectedStyle: TravelStyle = .adventure
    @State private var isGenerating: Bool = false
    @State private var generatedItinerary: [ItineraryDay] = []
    @State private var showItinerary: Bool = false
    @State private var parsedQuery: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                inputSection
                if showItinerary {
                    itinerarySection
                }
            }
            .padding(20)
        }
        .background(Theme.surfaceLight)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "map.fill")
                    .font(.title2)
                    .foregroundColor(Theme.oceanBlue)
                Text("AI Trip Planner")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimaryLight)
                Spacer()
            }
            Text("Plan your perfect trip with AI-powered itineraries")
                .font(.caption)
                .foregroundColor(Theme.textPrimaryLight.opacity(0.6))
        }
        .padding(16)
        .background(Theme.cardBgLight)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private var inputSection: some View {
        VStack(spacing: 16) {
            QueryInputField(
                text: $destination,
                parsedQuery: $parsedQuery,
                placeholder: "Where do you want to go? (e.g., Tokyo for 7 days)"
            )

            HStack(spacing: 12) {
                DatePickerField(title: "Start", date: $startDate)
                DatePickerField(title: "End", date: $endDate)
            }

            TravelStylePicker(selectedStyle: $selectedStyle)

            generateButton
        }
        .padding(16)
        .background(Theme.cardBgLight)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private var generateButton: some View {
        Button(action: generateItinerary) {
            HStack {
                if isGenerating {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "wand.and.stars")
                }
                Text(isGenerating ? "Generating..." : "Generate Itinerary")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                destination.isEmpty
                    ? Theme.oceanBlue.opacity(0.5)
                    : Theme.oceanBlue
            )
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(destination.isEmpty || isGenerating)
    }

    private var itinerarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Itinerary")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimaryLight)
                Spacer()
                Button("Save Trip") {
                    saveTrip()
                }
                .font(.caption)
                .foregroundColor(Theme.oceanBlue)
            }

            ForEach(generatedItinerary) { day in
                ItineraryDayCard(day: day)
            }
        }
        .padding(16)
        .background(Theme.cardBgLight)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private func generateItinerary() {
        isGenerating = true
        parsedQuery = TravelQueryParser.parse(destination)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            generatedItinerary = AITripService.generateItinerary(
                destination: destination,
                startDate: startDate,
                endDate: endDate,
                style: selectedStyle
            )
            showItinerary = true
            isGenerating = false
        }
    }

    private func saveTrip() {
        let trip = Trip(
            id: UUID(),
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            style: selectedStyle,
            itinerary: generatedItinerary
        )
        appState.upcomingTrips.insert(trip, at: 0)
        appState.selectedTab = .menubar
    }
}

struct QueryInputField: View {
    @Binding var text: String
    @Binding var parsedQuery: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Theme.surfaceLight)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Theme.oceanBlue.opacity(0.3), lineWidth: 1)
                )

            if !parsedQuery.isEmpty {
                Text("Detected: \(parsedQuery)")
                    .font(.caption2)
                    .foregroundColor(Theme.palmGreen)
            }
        }
    }
}

struct DatePickerField: View {
    let title: String
    @Binding var date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(Theme.textPrimaryLight.opacity(0.6))
            DatePicker(
                "",
                selection: $date,
                displayedComponents: .date
            )
            .labelsHidden()
            .datePickerStyle(.compact)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TravelStylePicker: View {
    @Binding var selectedStyle: TravelStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Travel Style")
                .font(.caption)
                .foregroundColor(Theme.textPrimaryLight.opacity(0.6))

            HStack(spacing: 8) {
                ForEach(TravelStyle.allCases, id: \.self) { style in
                    TravelStyleButton(
                        style: style,
                        isSelected: selectedStyle == style
                    ) {
                        selectedStyle = style
                    }
                }
            }
        }
    }
}

struct TravelStyleButton: View {
    let style: TravelStyle
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: style.icon)
                    .font(.caption)
                Text(style.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Theme.oceanBlue : Theme.surfaceLight)
            .foregroundColor(isSelected ? .white : Theme.textPrimaryLight)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.oceanBlue.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ItineraryDayCard: View {
    let day: ItineraryDay

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Day \(day.day)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.oceanBlue)
                Text(day.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(Theme.textPrimaryLight.opacity(0.5))
                Spacer()
            }

            ForEach(day.activities) { activity in
                ActivityRow(activity: activity)
            }
        }
        .padding(12)
        .background(Theme.surfaceLight)
        .cornerRadius(8)
    }
}

struct ActivityRow: View {
    let activity: Activity

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(activity.time)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Theme.sunsetOrange)
                .frame(width: 50, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(activity.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.textPrimaryLight)
                    if activity.reserved {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption2)
                            .foregroundColor(Theme.palmGreen)
                    }
                }
                Text(activity.location)
                    .font(.caption2)
                    .foregroundColor(Theme.textPrimaryLight.opacity(0.5))
            }
            Spacer()
        }
    }
}

struct TravelQueryParser {
    static func parse(_ query: String) -> String {
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = query

        var destination = ""
        var days = 7

        let range = query.startIndex..<query.endIndex
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType, options: [.omitPunctuation, .omitWhitespace]) { tag, tokenRange in
            if let tag = tag {
                switch tag {
                case .placeName:
                    if destination.isEmpty {
                        destination = String(query[tokenRange])
                    }
                default:
                    break
                }
            }
            return true
        }

        let numbers = query.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let n = Int(numbers), n > 0, n < 365 {
            days = n
        }

        if !destination.isEmpty {
            return "Destination: \(destination), \(days) days"
        }
        return ""
    }
}


