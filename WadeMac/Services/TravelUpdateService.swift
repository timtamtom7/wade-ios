import Foundation
import Combine

@MainActor final class TravelUpdateService: ObservableObject {
    static let shared = TravelUpdateService()

    @Published var weatherUpdates: [String: WeatherUpdate] = [:]
    @Published var flightUpdates: [String: FlightUpdate] = [:]
    @Published var localEvents: [String: [LocalEvent]] = [:]
    @Published var exchangeRates: [String: Double] = [:]

    private var refreshTasks: [String: Task<Void, Never>] = [:]

    // MARK: - Weather

    struct WeatherUpdate: Identifiable {
        let id = UUID()
        let destination: String
        let date: Date
        let condition: WeatherCondition
        let temperatureHigh: Double
        let temperatureLow: Double
        let precipitationChance: Double
        let humidity: Double
        let windSpeed: Double
        let icon: String

        var temperatureRange: String {
            "\(Int(temperatureLow))° - \(Int(temperatureHigh))°C"
        }

        var alerts: [String] {
            var list: [String] = []
            if precipitationChance > 60 {
                list.append("🌧 High chance of rain (\(Int(precipitationChance))%)")
            }
            if windSpeed > 40 {
                list.append("💨 Strong winds expected (\(Int(windSpeed)) km/h)")
            }
            if temperatureHigh > 35 {
                list.append("🔥 Extreme heat warning")
            }
            if temperatureLow < 5 {
                list.append("❄️ Cold temperatures expected")
            }
            return list
        }
    }

    enum WeatherCondition: String {
        case sunny = "Sunny"
        case partlyCloudy = "Partly Cloudy"
        case cloudy = "Cloudy"
        case rainy = "Rainy"
        case stormy = "Stormy"
        case snowy = "Snowy"
        case foggy = "Foggy"

        var icon: String {
            switch self {
            case .sunny: return "sun.max.fill"
            case .partlyCloudy: return "cloud.sun.fill"
            case .cloudy: return "cloud.fill"
            case .rainy: return "cloud.rain.fill"
            case .stormy: return "cloud.bolt.rain.fill"
            case .snowy: return "cloud.snow.fill"
            case .foggy: return "cloud.fog.fill"
            }
        }
    }

    func fetchWeather(for destination: String, dates: [Date]) {
        // Simulate API call to OpenWeatherMap
        let weatherConditions: [WeatherCondition] = [.sunny, .partlyCloudy, .rainy, .cloudy]
        var updates: [WeatherUpdate] = []

        for date in dates {
            let condition = weatherConditions.randomElement()!
            let update = WeatherUpdate(
                destination: destination,
                date: date,
                condition: condition,
                temperatureHigh: Double.random(in: 18...35),
                temperatureLow: Double.random(in: 10...20),
                precipitationChance: Double.random(in: 0...80),
                humidity: Double.random(in: 30...90),
                windSpeed: Double.random(in: 5...50),
                icon: condition.icon
            )
            updates.append(update)
        }

        DispatchQueue.main.async {
            self.weatherUpdates[destination] = updates.first
        }
    }

    // MARK: - Flight Status

    struct FlightUpdate: Identifiable {
        let id = UUID()
        let flightNumber: String
        let airline: String
        let departureAirport: String
        let arrivalAirport: String
        let scheduledDeparture: Date
        let scheduledArrival: Date
        let actualDeparture: Date?
        let actualArrival: Date?
        let status: FlightStatus
        let gate: String?
        let terminal: String?
        let delay: TimeInterval

        enum FlightStatus: String {
            case onTime = "On Time"
            case delayed = "Delayed"
            case cancelled = "Cancelled"
            case boarding = "Boarding"
            case departed = "Departed"
            case arrived = "Arrived"
            case inFlight = "In Flight"

            var icon: String {
                switch self {
                case .onTime: return "checkmark.circle.fill"
                case .delayed: return "clock.fill"
                case .cancelled: return "xmark.circle.fill"
                case .boarding: return "figure.walk"
                case .departed: return "airplane.departure"
                case .arrived: return "airplane.arrival"
                case .inFlight: return "airplane"
                }
            }

            var color: String {
                switch self {
                case .onTime, .arrived: return "palmGreen"
                case .delayed: return "sunsetOrange"
                case .cancelled: return "accentCoral"
                case .boarding, .departed, .inFlight: return "oceanBlue"
                }
            }
        }

        var delayMinutes: Int {
            Int(delay / 60)
        }

        var statusDescription: String {
            switch status {
            case .onTime: return "On time"
            case .delayed: return "Delayed by \(delayMinutes) min"
            case .cancelled: return "Flight cancelled"
            case .boarding: return "Now boarding at Gate \(gate ?? "TBD")"
            case .departed: return "Departed at \(actualDeparture?.formatted(date: .omitted, time: .shortened) ?? "—")"
            case .arrived: return "Arrived at \(actualArrival?.formatted(date: .omitted, time: .shortened) ?? "—")"
            case .inFlight: return "In the air"
            }
        }
    }

    func trackFlight(number: String) {
        // Simulate API call to AviationStack/AeroDataBox
        let statuses: [FlightUpdate.FlightStatus] = [.onTime, .delayed, .inFlight, .boarding]
        let airports = ["LAX", "JFK", "ORD", "SFO", "NRT", "LHR", "CDG", "FRA"]

        let departure = airports.randomElement()!
        var arrival = airports.randomElement()!
        while arrival == departure { arrival = airports.randomElement()! }

        let scheduledDep = Date().addingTimeInterval(Double.random(in: -7200...14400))
        let delay = statuses.contains(.delayed) ? Double.random(in: 15...90) * 60 : 0

        let update = FlightUpdate(
            flightNumber: number.uppercased(),
            airline: airlineName(for: number),
            departureAirport: departure,
            arrivalAirport: arrival,
            scheduledDeparture: scheduledDep,
            scheduledArrival: scheduledDep.addingTimeInterval(Double.random(in: 7200...18000)),
            actualDeparture: delay > 0 ? scheduledDep.addingTimeInterval(delay) : nil,
            actualArrival: nil,
            status: statuses.randomElement() ?? .onTime,
            gate: "B\(Int.random(in: 1...30))",
            terminal: "\(Int.random(in: 1...5))",
            delay: delay
        )

        DispatchQueue.main.async {
            self.flightUpdates[number] = update
        }
    }

    private func airlineName(for code: String) -> String {
        let airlines: [String: String] = [
            "AA": "American Airlines", "UA": "United Airlines", "DL": "Delta Air Lines",
            "BA": "British Airways", "LH": "Lufthansa", "AF": "Air France",
            "JL": "Japan Airlines", "NH": "All Nippon Airways", "SQ": "Singapore Airlines",
            "EK": "Emirates", "QF": "Qantas", "CX": "Cathay Pacific"
        ]
        return airlines[String(code.prefix(2)).uppercased()] ?? "Airline"
    }

    // MARK: - Local Events

    struct LocalEvent: Identifiable {
        let id = UUID()
        let name: String
        let date: Date
        let location: String
        let category: EventCategory
        let description: String

        enum EventCategory: String {
            case festival = "Festival"
            case holiday = "Public Holiday"
            case concert = "Concert"
            case sports = "Sports"
            case food = "Food & Drink"
            case cultural = "Cultural"
            case market = "Market"

            var icon: String {
                switch self {
                case .festival: return "party.popper.fill"
                case .holiday: return "flag.fill"
                case .concert: return "music.note"
                case .sports: return "sportscourt.fill"
                case .food: return "fork.knife"
                case .cultural: return "building.columns.fill"
                case .market: return "storefront.fill"
                }
            }
        }
    }

    func fetchLocalEvents(for destination: String, during tripDates: (start: Date, end: Date)) {
        // Simulate API call for local events
        let eventTemplates: [(String, LocalEvent.EventCategory, String)] = [
            ("Local Food Festival", .food, "Central Square"),
            ("Music in the Park", .concert, "City Park"),
            ("Artisan Market", .market, "Old Town"),
            ("National Holiday", .holiday, "City Wide"),
            ("Cultural Parade", .cultural, "Main Street"),
            ("Sports Championship", .sports, "Stadium"),
            ("Wine & Dine Weekend", .food, "Riverside"),
            ("Street Art Festival", .festival, "Arts District"),
        ]

        var events: [LocalEvent] = []
        var currentDate = tripDates.start

        while currentDate <= tripDates.end {
            if Bool.random() {
                let template = eventTemplates.randomElement()!
                events.append(LocalEvent(
                    name: template.0,
                    date: currentDate,
                    location: template.2,
                    category: template.1,
                    description: "A wonderful \(template.1.rawValue.lowercased()) event happening during your trip."
                ))
            }
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        DispatchQueue.main.async {
            self.localEvents[destination] = events
        }
    }

    // MARK: - Exchange Rates

    func fetchExchangeRates(baseCurrency: String = "USD") {
        // Simulate API call to exchangerate-api.com
        let rates: [String: Double] = [
            "USD": 1.0,
            "EUR": 0.92,
            "GBP": 0.79,
            "JPY": 149.50,
            "CAD": 1.36,
            "AUD": 1.53,
            "CHF": 0.88,
            "CNY": 7.24,
            "INR": 83.12,
            "MXN": 17.15,
            "BRL": 4.97,
            "KRW": 1328.45,
            "SGD": 1.34,
            "HKD": 7.82,
            "THB": 35.67,
        ]

        DispatchQueue.main.async {
            self.exchangeRates = rates
        }
    }

    func convert(amount: Double, from: String, to: String) -> Double? {
        guard let fromRate = exchangeRates[from], let toRate = exchangeRates[to] else {
            return nil
        }
        return (amount / fromRate) * toRate
    }

    // MARK: - Cleanup

    func stopAllUpdates() {
        refreshTasks.values.forEach { $0.cancel() }
        refreshTasks.removeAll()
    }
}
