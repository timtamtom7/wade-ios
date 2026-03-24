import Foundation

enum SubscriptionTier: String, CaseIterable, Codable {
    case free = "free"
    case track = "track"
    case overview = "overview"

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .track: return "Track"
        case .overview: return "Overview"
        }
    }

    var price: String {
        switch self {
        case .free: return "Free"
        case .track: return "$3.99/mo"
        case .overview: return "$7.99/mo"
        }
    }

    var monthlyPrice: Double? {
        switch self {
        case .free: return nil
        case .track: return 3.99
        case .overview: return 7.99
        }
    }

    var tagline: String {
        switch self {
        case .free: return "Start tracking"
        case .track: return "Everything you need"
        case .overview: return "The full picture"
        }
    }

    var maxExpensesPerMonth: Int {
        switch self {
        case .free: return 20
        case .track: return Int.max
        case .overview: return Int.max
        }
    }

    var features: [String] {
        switch self {
        case .free:
            return [
                "20 expenses/month",
                "Basic parsing",
                "This week total"
            ]
        case .track:
            return [
                "Unlimited expenses",
                "Weekly summaries",
                "Category insights",
                "Smart parsing"
            ]
        case .overview:
            return [
                "Everything in Track",
                "Monthly reports",
                "Budget goals",
                "Export to CSV/PDF",
                "Multiple currencies"
            ]
        }
    }

    var featuresNotIncluded: [String] {
        switch self {
        case .free:
            return ["Weekly summaries", "Export", "Monthly reports"]
        case .track:
            return ["Monthly reports", "Export to CSV/PDF"]
        case .overview:
            return []
        }
    }

    var isFree: Bool {
        self == .free
    }

    var accentColorHex: String {
        switch self {
        case .free: return "8a8a8a"
        case .track: return "34c759"
        case .overview: return "ffd60a"
        }
    }
}

@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published var currentTier: SubscriptionTier = .free

    private let tierKey = "wade_subscription_tier"
    private let hasCompletedOnboardingKey = "wade_has_completed_onboarding"

    private init() {
        loadTier()
    }

    private func loadTier() {
        if let raw = UserDefaults.standard.string(forKey: tierKey),
           let tier = SubscriptionTier(rawValue: raw) {
            currentTier = tier
        }
    }

    func upgrade(to tier: SubscriptionTier) {
        currentTier = tier
        UserDefaults.standard.set(tier.rawValue, forKey: tierKey)
    }

    func canAddExpense(currentMonthCount: Int) -> Bool {
        currentMonthCount < currentTier.maxExpensesPerMonth
    }

    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasCompletedOnboardingKey) }
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
        UserDefaults.standard.removeObject(forKey: hasCompletedOnboardingKey)
    }
}
