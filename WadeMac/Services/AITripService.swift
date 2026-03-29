import Foundation
import NaturalLanguage

final class AITripService: @unchecked Sendable {
    static let shared = AITripService()

    // MARK: - Public API

    /// Optimize a trip's day-by-day itinerary based on travel style and location proximity
    func optimizeItinerary(trip: Trip, preferences: TravelStyle) -> [AITripService.OptimizedDay] {
        let days = trip.itinerary
        return days.map { day in
            optimizeDay(day: day, style: preferences, destination: trip.destination)
        }
    }

    /// Score an activity's relevance to travel style
    func scoreActivity(_ activity: Activity, style: TravelStyle) -> Double {
        let title = activity.title.lowercased()
        let location = activity.location.lowercased()

        var score = 50.0 // Base score

        switch style {
        case .luxury:
            if containsAny(title, ["spa", "fine dining", "rooftop", "boutique", "villa", "yacht", "golf"]) { score += 30 }
            if containsAny(location, ["5-star", "luxury", "resort", "premium"]) { score += 20 }
            if containsAny(title, ["hostel", "budget", "backpack", "street food"]) { score -= 20 }

        case .budget:
            if containsAny(title, ["free", "walking", "hostel", "street food", "market", "park", "beach"]) { score += 30 }
            if containsAny(location, ["market", "local", "budget"]) { score += 20 }
            if containsAny(title, ["luxury", "spa", "private", "vip"]) { score -= 25 }

        case .adventure:
            if containsAny(title, ["hike", "trek", "dive", "surf", "climb", "raft", "zip", "atv", "kayak", "extreme"]) { score += 35 }
            if containsAny(location, ["mountain", "jungle", "ocean", "canyon", "volcano"]) { score += 20 }
            if containsAny(title, ["spa", "museum", "shopping", "lounge"]) { score -= 15 }

        case .family:
            if containsAny(title, ["zoo", "aquarium", "park", "playground", "theme park", "farm", "museum", "beach"]) { score += 35 }
            if containsAny(title, ["nightlife", "club", "bar", "adults only"]) { score -= 30 }
            if activity.reserved { score += 10 }
        }

        return min(100, max(0, score))
    }

    /// Group activities by geographic proximity
    func groupNearbyActivities(_ activities: [Activity], clusterRadiusKm: Double = 2.0) -> [[Activity]] {
        var clusters: [[Activity]] = []
        var processed = Set<UUID>()

        for activity in activities {
            guard !processed.contains(activity.id) else { continue }

            var cluster = [activity]
            processed.insert(activity.id)

            for other in activities {
                guard !processed.contains(other.id) else { continue }
                // Simple heuristic: activities within 2 occurrences apart in the day are "nearby"
                if abs(activities.firstIndex(where: { $0.id == activity.id })! -
                       activities.firstIndex(where: { $0.id == other.id })!) <= 2 {
                    cluster.append(other)
                    processed.insert(other.id)
                }
            }
            clusters.append(cluster)
        }

        return clusters
    }

    /// Calculate estimated travel time between two locations (heuristic)
    func estimateTravelTime(from: String, to: String) -> TimeInterval {
        // In production, call Google Maps Distance Matrix API
        // For now, return a plausible estimate based on time-of-day heuristics
        let hour = Calendar.current.component(.hour, from: Date())
        let isRushHour = (hour >= 7 && hour <= 9) || (hour >= 17 && hour <= 19)
        let baseMinutes = Double.random(in: 10...45)
        return isRushHour ? baseMinutes * 1.5 * 60 : baseMinutes * 60
    }

    /// Reorder activities within a day for optimal flow
    func reorderForOptimalFlow(activities: [Activity], style: TravelStyle) -> [Activity] {
        guard activities.count > 2 else { return activities }

        var result = activities

        // Move reserved activities to their stated time slots
        let reserved = result.filter { $0.reserved }
        let flexible = result.filter { !$0.reserved }

        // Group flexible activities by type
        var morning: [Activity] = []
        var afternoon: [Activity] = []
        var evening: [Activity] = []

        for activity in flexible {
            let hour = extractHour(from: activity.time)
            if hour < 12 {
                morning.append(activity)
            } else if hour < 17 {
                afternoon.append(activity)
            } else {
                evening.append(activity)
            }
        }

        // Sort by style priority within each time block
        morning = sortByStyle(morning, style: style)
        afternoon = sortByStyle(afternoon, style: style)
        evening = sortByStyle(evening, style: style)

        result = reserved + morning + afternoon + evening
        return consolidateTimes(result)
    }

    // MARK: - Itinerary Generation (delegated from old struct)

    static func generateItinerary(destination: String, startDate: Date, endDate: Date, style: TravelStyle) -> [ItineraryDay] {
        let dayCount = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 7

        let sampleActivities: [(String, String, String, Bool)] = [
            ("Morning", "Arrive & Check In", "Airport / Hotel", true),
            ("10:00 AM", "City Walking Tour", "Historic District", false),
            ("1:00 PM", "Local Lunch", "Recommended Restaurant", false),
            ("3:00 PM", "Top Attraction Visit", "Main Landmark", false),
            ("7:00 PM", "Dinner & Evening Walk", "Waterfront / Downtown", false),
        ]

        return (1...max(dayCount, 1)).map { dayNum in
            let date = Calendar.current.date(byAdding: .day, value: dayNum - 1, to: startDate) ?? startDate
            let activities = sampleActivities.map { (time, title, location, reserved) in
                Activity(
                    id: UUID(),
                    time: time,
                    title: "\(title) - Day \(dayNum)",
                    location: location,
                    notes: "AI suggested based on \(style.rawValue.lowercased()) travel style",
                    reserved: reserved
                )
            }
            return ItineraryDay(id: UUID(), day: dayNum, date: date, activities: activities)
        }
    }

    // MARK: - Private Helpers

    private func optimizeDay(day: ItineraryDay, style: TravelStyle, destination: String) -> AITripService.OptimizedDay {
        let reordered = reorderForOptimalFlow(activities: day.activities, style: style)
        let totalTravelTime = calculateTotalTravelTime(activities: reordered)
        let highlights = generateHighlights(activities: reordered, style: style, day: day.day)

        return OptimizedDay(
            day: day.day,
            activities: reordered,
            totalTravelTime: totalTravelTime,
            highlights: highlights
        )
    }

    private func calculateTotalTravelTime(activities: [Activity]) -> TimeInterval {
        guard activities.count > 1 else { return 0 }
        var total: TimeInterval = 0
        for i in 0..<(activities.count - 1) {
            total += estimateTravelTime(from: activities[i].location, to: activities[i + 1].location)
        }
        return total
    }

    private func generateHighlights(activities: [Activity], style: TravelStyle, day: Int) -> [String] {
        var highlights: [String] = []
        let topScored = activities
            .map { ($0, scoreActivity($0, style: style)) }
            .sorted { $0.1 > $1.1 }
            .prefix(2)

        for (activity, score) in topScored {
            if score > 70 {
                highlights.append("⭐ \(activity.title) - highly rated for \(style.rawValue.lowercased()) travel")
            }
        }

        if activities.contains(where: { $0.reserved }) {
            highlights.append("✓ Reserved activity included")
        }

        let totalTime = calculateTotalTravelTime(activities: activities)
        if totalTime > 3600 {
            highlights.append("⏱ \(Int(totalTime / 60)) min travel time - consider consolidating locations")
        }

        return highlights
    }

    private func containsAny(_ text: String, _ keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }

    private func extractHour(from timeString: String) -> Int {
        let digits = timeString.filter { $0.isNumber }
        if let num = Int(digits.prefix(2)) {
            return timeString.lowercased().contains("pm") && num != 12 ? num + 12 : num
        }
        return 12
    }

    private func sortByStyle(_ activities: [Activity], style: TravelStyle) -> [Activity] {
        activities.sorted { a, b in
            scoreActivity(a, style: style) > scoreActivity(b, style: style)
        }
    }

    private func consolidateTimes(_ activities: [Activity]) -> [Activity] {
        // Rebuild with consistent time spacing
        let timeSlots = ["8:00 AM", "9:30 AM", "11:00 AM", "1:00 PM", "2:30 PM", "4:00 PM", "6:00 PM", "7:30 PM"]
        return activities.enumerated().map { index, activity in
            var updated = activity
            if !activity.reserved, index < timeSlots.count {
                updated.time = timeSlots[index]
            }
            return updated
        }
    }
}

// MARK: - Supporting Types

extension AITripService {
    struct OptimizedDay: Identifiable {
        let id = UUID()
        let day: Int
        let activities: [Activity]
        let totalTravelTime: TimeInterval
        let highlights: [String]

        var formattedTravelTime: String {
            let minutes = Int(totalTravelTime / 60)
            if minutes >= 60 {
                return "\(minutes / 60)h \(minutes % 60)m"
            }
            return "\(minutes) min"
        }
    }
}
