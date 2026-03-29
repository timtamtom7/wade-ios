import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var selectedTab: Tab = .planner
    @Published var upcomingTrips: [Trip] = []
    @Published var packingLists: [PackingList] = []
    @Published var selectedTrip: Trip?

    enum Tab: String, CaseIterable {
        case planner = "Trip Planner"
        case destinations = "Destinations"
        case packing = "Packing"
        case currency = "Currency"
        case menubar = "Overview"

        var icon: String {
            switch self {
            case .planner: return "map.fill"
            case .destinations: return "globe"
            case .packing: return "bag.fill"
            case .currency: return "dollarsign.circle.fill"
            case .menubar: return "house.fill"
            }
        }
    }

    init() {
        loadSampleData()
    }

    private func loadSampleData() {
        upcomingTrips = [
            Trip(
                id: UUID(),
                destination: "Tokyo",
                startDate: Date().addingTimeInterval(86400 * 30),
                endDate: Date().addingTimeInterval(86400 * 37),
                style: .adventure,
                itinerary: []
            ),
            Trip(
                id: UUID(),
                destination: "Lisbon",
                startDate: Date().addingTimeInterval(86400 * 90),
                endDate: Date().addingTimeInterval(86400 * 97),
                style: .luxury,
                itinerary: []
            )
        ]

        packingLists = [
            PackingList(
                id: UUID(),
                tripId: upcomingTrips[0].id,
                items: PackingItem.sampleItems,
                categories: PackingCategory.allCases
            )
        ]
    }
}

struct Trip: Identifiable, Codable {
    let id: UUID
    var destination: String
    var startDate: Date
    var endDate: Date
    var style: TravelStyle
    var itinerary: [ItineraryDay]

    var daysUntilTrip: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: startDate).day ?? 0
    }
}

enum TravelStyle: String, Codable, CaseIterable {
    case luxury = "Luxury"
    case budget = "Budget"
    case family = "Family"
    case adventure = "Adventure"

    var icon: String {
        switch self {
        case .luxury: return "star.fill"
        case .budget: return "dollarsign.circle"
        case .family: return "figure.2.and.child.holdinghands"
        case .adventure: return "flame.fill"
        }
    }
}

struct ItineraryDay: Identifiable, Codable {
    let id: UUID
    var day: Int
    var date: Date
    var activities: [Activity]
}

struct Activity: Identifiable, Codable {
    let id: UUID
    var time: String
    var title: String
    var location: String
    var notes: String
    var reserved: Bool
}

struct PackingList: Identifiable {
    let id: UUID
    let tripId: UUID
    var items: [PackingItem]
    var categories: [PackingCategory]
}

struct PackingItem: Identifiable {
    let id: UUID
    var name: String
    var category: PackingCategory
    var isPacked: Bool

    static var sampleItems: [PackingItem] {
        [
            PackingItem(id: UUID(), name: "Passport", category: .documents, isPacked: false),
            PackingItem(id: UUID(), name: "Travel Insurance", category: .documents, isPacked: false),
            PackingItem(id: UUID(), name: "T-shirts", category: .clothing, isPacked: false),
            PackingItem(id: UUID(), name: "Shorts", category: .clothing, isPacked: false),
            PackingItem(id: UUID(), name: "Sunscreen", category: .toiletries, isPacked: false),
            PackingItem(id: UUID(), name: "Phone Charger", category: .electronics, isPacked: false),
            PackingItem(id: UUID(), name: "Camera", category: .electronics, isPacked: false),
            PackingItem(id: UUID(), name: "Toothbrush", category: .toiletries, isPacked: false),
        ]
    }
}

enum PackingCategory: String, CaseIterable, Codable {
    case clothing = "Clothing"
    case toiletries = "Toiletries"
    case documents = "Documents"
    case electronics = "Electronics"
    case other = "Other"

    var icon: String {
        switch self {
        case .clothing: return "tshirt.fill"
        case .toiletries: return "drop.fill"
        case .documents: return "doc.fill"
        case .electronics: return "laptopcomputer"
        case .other: return "bag.fill"
        }
    }
}

struct Destination: Identifiable {
    let id: UUID
    let name: String
    let country: String
    let description: String
    let topAttractions: [String]
    let restaurants: [String]
    let tips: [String]
    let imageSystemName: String

    static let samples: [Destination] = [
        Destination(
            id: UUID(),
            name: "Tokyo",
            country: "Japan",
            description: "A mesmerizing blend of ultra-modern and traditional, where neon-lit skyscrapers stand beside ancient temples.",
            topAttractions: ["Senso-ji Temple", "Shibuya Crossing", "Meiji Shrine", "Tokyo Tower", "Akihabara"],
            restaurants: ["Sukiyabashi Jiro", "Ichiran Ramen", "Gonpachi", "Tsukiji Outer Market", "Robot Restaurant"],
            tips: ["Get a Suica card for transit", "Cash is still king in many places", "Learn basic Japanese phrases"],
            imageSystemName: "building.columns.fill"
        ),
        Destination(
            id: UUID(),
            name: "Lisbon",
            country: "Portugal",
            description: "A charming city of seven hills, covered in azulejo tiles, with fado music and pastéis de nata waiting around every corner.",
            topAttractions: ["Belém Tower", "Jerónimos Monastery", "Alfama District", "Time Out Market", "São Jorge Castle"],
            restaurants: ["Time Out Market", "Cervejaria Ramiro", "Pasteis de Belém", "Mercado da Ribeira", "Solar de São Lorenzo"],
            tips: ["Wear comfortable shoes for hills", "Tram 28 is a tourist attraction itself", "Book Pasteis de Belém early"],
            imageSystemName: "building.2.fill"
        ),
        Destination(
            id: UUID(),
            name: "Bali",
            country: "Indonesia",
            description: "An island paradise of terraced rice paddies, volcanic hillsides, and sacred temples meeting pristine beaches.",
            topAttractions: ["Tegallalang Rice Terraces", "Uluwatu Temple", "Mount Batur", "Sacred Monkey Forest", "Waterbom Bali"],
            restaurants: ["Locavore", "Maya Ubud", "Café Moka", "Warung Babi Guling Ibu Oka", "La Lucciola"],
            tips: ["Rent a scooter for flexibility", "Respect temple dress codes", "Bargain politely at markets"],
            imageSystemName: "leaf.fill"
        )
    ]
}
