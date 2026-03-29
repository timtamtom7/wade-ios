import SwiftUI

struct PackingListView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var appState: AppState
    @State private var selectedTripId: UUID?
    @State private var newItemText: String = ""
    @State private var selectedCategory: PackingCategory = .clothing

    private var selectedList: PackingList? {
        guard let id = selectedTripId else {
            return appState.packingLists.first
        }
        return appState.packingLists.first { $0.tripId == id }
    }

    private var currentTrip: Trip? {
        guard let list = selectedList else { return nil }
        return appState.upcomingTrips.first { $0.id == list.tripId }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            if let list = selectedList {
                ScrollView {
                    VStack(spacing: 12) {
                        tripSelector

                        progressSection(for: list)

                        addItemSection

                        ForEach(PackingCategory.allCases, id: \.self) { category in
                            let items = list.items.filter { $0.category == category }
                            if !items.isEmpty {
                                PackingCategorySection(
                                    category: category,
                                    items: items,
                                    onToggle: { itemId in
                                        toggleItem(itemId: itemId)
                                    }
                                )
                            }
                        }
                    }
                    .padding(16)
                }
            } else {
                emptyState
            }
        }
        .background(Theme.surfaceLight)
    }

    private var headerSection: some View {
        HStack {
            Image(systemName: "bag.fill")
                .font(.title3)
                .foregroundColor(Theme.oceanBlue)
            Text("Packing List")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimaryLight)
            Spacer()
        }
        .padding(16)
        .background(Theme.cardBgLight)
    }

    private var tripSelector: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Trip")
                .font(.caption)
                .foregroundColor(Theme.textPrimaryLight.opacity(0.6))

            if appState.upcomingTrips.isEmpty {
                Text("No trips yet — create one in Trip Planner")
                    .font(.caption)
                    .foregroundColor(Theme.textPrimaryLight.opacity(0.4))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(appState.upcomingTrips) { trip in
                            TripChip(
                                trip: trip,
                                isSelected: selectedTripId == trip.id || (selectedTripId == nil && appState.upcomingTrips.first?.id == trip.id)
                            ) {
                                selectedTripId = trip.id
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Theme.cardBgLight)
        .cornerRadius(10)
    }

    private func progressSection(for list: PackingList) -> some View {
        let packed = list.items.filter { $0.isPacked }.count
        let total = list.items.count
        let progress = total > 0 ? Double(packed) / Double(total) : 0

        return VStack(spacing: 8) {
            HStack {
                Text("\(packed) of \(total) items packed")
                    .font(.subheadline)
                    .foregroundColor(Theme.textPrimaryLight)
                Spacer()
                Button("Share") {
                    shareList(list)
                }
                .font(.caption)
                .foregroundColor(Theme.oceanBlue)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.surfaceLight)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.palmGreen)
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(12)
        .background(Theme.cardBgLight)
        .cornerRadius(10)
    }

    private var addItemSection: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("Add item...", text: $newItemText)
                    .textFieldStyle(.plain)

                Picker("", selection: $selectedCategory) {
                    ForEach(PackingCategory.allCases, id: \.self) { cat in
                        Image(systemName: cat.icon).tag(cat)
                    }
                }
                .labelsHidden()
                .frame(width: 40)

                Button(action: addItem) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Theme.oceanBlue)
                }
                .disabled(newItemText.isEmpty)
            }
            .padding(10)
            .background(Theme.surfaceLight)
            .cornerRadius(8)
        }
        .padding(12)
        .background(Theme.cardBgLight)
        .cornerRadius(10)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bag")
                .font(.system(size: 48))
                .foregroundColor(Theme.textPrimaryLight.opacity(0.2))
            Text("No packing list yet")
                .font(.headline)
                .foregroundColor(Theme.textPrimaryLight.opacity(0.5))
            Text("Create a trip to generate your packing list")
                .font(.caption)
                .foregroundColor(Theme.textPrimaryLight.opacity(0.3))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func addItem() {
        guard !newItemText.isEmpty, let list = selectedList else { return }
        let item = PackingItem(
            id: UUID(),
            name: newItemText,
            category: selectedCategory,
            isPacked: false
        )

        if let index = appState.packingLists.firstIndex(where: { $0.tripId == list.tripId }) {
            appState.packingLists[index].items.append(item)
        }
        newItemText = ""
    }

    private func toggleItem(itemId: UUID) {
        guard let list = selectedList else { return }
        if let listIndex = appState.packingLists.firstIndex(where: { $0.tripId == list.tripId }),
           let itemIndex = appState.packingLists[listIndex].items.firstIndex(where: { $0.id == itemId }) {
            appState.packingLists[listIndex].items[itemIndex].isPacked.toggle()
        }
    }

    private func shareList(_ list: PackingList) {
        var text = "Packing List for \(currentTrip?.destination ?? "Trip")\n"
        text += "-----------------------------\n\n"

        for category in PackingCategory.allCases {
            let items = list.items.filter { $0.category == category }
            if !items.isEmpty {
                text += "[\(category.rawValue)]\n"
                for item in items {
                    let check = item.isPacked ? "✓" : "☐"
                    text += "\(check) \(item.name)\n"
                }
                text += "\n"
            }
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

struct TripChip: View {
    let trip: Trip
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "airplane.departure")
                    .font(.caption2)
                Text(trip.destination)
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

struct PackingCategorySection: View {
    let category: PackingCategory
    let items: [PackingItem]
    let onToggle: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(Theme.oceanBlue)
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimaryLight)
                Spacer()
                Text("\(items.filter { $0.isPacked }.count)/\(items.count)")
                    .font(.caption)
                    .foregroundColor(Theme.textPrimaryLight.opacity(0.4))
            }

            ForEach(items) { item in
                PackingItemRow(item: item) {
                    onToggle(item.id)
                }
            }
        }
        .padding(12)
        .background(Theme.cardBgLight)
        .cornerRadius(10)
    }
}

struct PackingItemRow: View {
    let item: PackingItem
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isPacked ? Theme.palmGreen : Theme.textPrimaryLight.opacity(0.3))
            }
            .buttonStyle(.plain)

            Text(item.name)
                .font(.subheadline)
                .foregroundColor(item.isPacked ? Theme.textPrimaryLight.opacity(0.5) : Theme.textPrimaryLight)
                .strikethrough(item.isPacked)

            Spacer()
        }
    }
}
