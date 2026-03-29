import SwiftUI

struct DestinationView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var searchText: String = ""
    @State private var selectedDestination: Destination?

    private var destinations: [Destination] = Destination.samples

    private var filteredDestinations: [Destination] {
        if searchText.isEmpty {
            return destinations
        }
        return destinations.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.country.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            if let selected = selectedDestination {
                DestinationDetailView(destination: selected, onDismiss: {
                    selectedDestination = nil
                })
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        ForEach(filteredDestinations) { dest in
                            DestinationCard(destination: dest) {
                                selectedDestination = dest
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Theme.surfaceLight)
    }

    private var headerSection: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "globe")
                    .font(.title3)
                    .foregroundColor(Theme.oceanBlue)
                Text("Destinations")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimaryLight)
                Spacer()
            }

            SearchField(text: $searchText, placeholder: "Search destinations...")
        }
        .padding(16)
        .background(Theme.cardBgLight)
    }
}

struct SearchField: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Theme.textPrimaryLight.opacity(0.4))
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Theme.textPrimaryLight.opacity(0.3))
                }
            }
        }
        .padding(8)
        .background(Theme.surfaceLight)
        .cornerRadius(8)
    }
}

struct DestinationCard: View {
    let destination: Destination
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Theme.oceanBlue.opacity(0.15))
                        .frame(height: 80)

                    Image(systemName: destination.imageSystemName)
                        .font(.system(size: 28))
                        .foregroundColor(Theme.oceanBlue)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(destination.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimaryLight)

                    Text(destination.country)
                        .font(.caption)
                        .foregroundColor(Theme.textPrimaryLight.opacity(0.5))
                }

                Text(destination.description)
                    .font(.caption2)
                    .foregroundColor(Theme.textPrimaryLight.opacity(0.6))
                    .lineLimit(2)
            }
            .padding(12)
            .background(Theme.cardBgLight)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct DestinationDetailView: View {
    let destination: Destination
    let onDismiss: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Theme.oceanBlue)
                    }
                    Spacer()
                    Text(destination.name)
                        .font(.headline)
                        .foregroundColor(Theme.textPrimaryLight)
                    Spacer()
                    Spacer().frame(width: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: destination.imageSystemName)
                            .font(.system(size: 32))
                            .foregroundColor(Theme.oceanBlue)
                        VStack(alignment: .leading) {
                            Text(destination.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.textPrimaryLight)
                            Text(destination.country)
                                .font(.caption)
                                .foregroundColor(Theme.textPrimaryLight.opacity(0.5))
                        }
                    }

                    Text(destination.description)
                        .font(.subheadline)
                        .foregroundColor(Theme.textPrimaryLight.opacity(0.8))
                        .padding(.top, 4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.cardBgLight)
                .cornerRadius(12)
                .padding(.horizontal, 16)

                AttractionsSection(attractions: destination.topAttractions)
                RestaurantsSection(restaurants: destination.restaurants)
                TipsSection(tips: destination.tips)

                Button(action: onDismiss) {
                    Text("Add to Trip Planner")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.oceanBlue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }
}

struct AttractionsSection: View {
    let attractions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Top Attractions", icon: "mappin.and.ellipse")

            ForEach(attractions, id: \.self) { attraction in
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(Theme.sunsetOrange)
                    Text(attraction)
                        .font(.subheadline)
                        .foregroundColor(Theme.textPrimaryLight)
                }
            }
        }
        .padding(16)
        .background(Theme.cardBgLight)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}

struct RestaurantsSection: View {
    let restaurants: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Recommended Restaurants", icon: "fork.knife")

            ForEach(restaurants, id: \.self) { restaurant in
                HStack {
                    Image(systemName: "fork.knife.circle.fill")
                        .foregroundColor(Theme.palmGreen)
                    Text(restaurant)
                        .font(.subheadline)
                        .foregroundColor(Theme.textPrimaryLight)
                }
            }
        }
        .padding(16)
        .background(Theme.cardBgLight)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}

struct TipsSection: View {
    let tips: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Travel Tips", icon: "lightbulb.fill")

            ForEach(tips, id: \.self) { tip in
                HStack(alignment: .top) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.oceanBlue)
                    Text(tip)
                        .font(.caption)
                        .foregroundColor(Theme.textPrimaryLight.opacity(0.8))
                }
            }
        }
        .padding(16)
        .background(Theme.cardBgLight)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(Theme.oceanBlue)
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimaryLight)
        }
    }
}
