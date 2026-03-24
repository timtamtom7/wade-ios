import Foundation

enum TransactionType: String, Codable {
    case expense
    case income
}

struct Transaction: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let type: TransactionType
    let category: String
    let note: String
    let date: Date
    var isRecurring: Bool

    init(id: UUID = UUID(), amount: Double, type: TransactionType, category: String, note: String, date: Date = Date(), isRecurring: Bool = false) {
        self.id = id
        self.amount = amount
        self.type = type
        self.category = category
        self.note = note
        self.date = date
        self.isRecurring = isRecurring
    }
}

// MARK: - Recurring Expense

struct RecurringExpense: Identifiable, Codable {
    let id: UUID
    let label: String
    let estimatedAmount: Double
    let frequency: RecurringFrequency
    let category: String
    let note: String
    let lastSeen: Date
    let lastAmount: Double

    enum RecurringFrequency: String, Codable {
        case weekly
        case biweekly
        case monthly
        case yearly
    }

    var frequencyDescription: String {
        switch frequency {
        case .weekly: return "weekly"
        case .biweekly: return "bi-weekly"
        case .monthly: return "monthly"
        case .yearly: return "yearly"
        }
    }

    var nextExpectedDate: Date {
        let calendar = Calendar.current
        switch frequency {
        case .weekly:
            return calendar.date(byAdding: .day, value: 7, to: lastSeen) ?? lastSeen
        case .biweekly:
            return calendar.date(byAdding: .day, value: 14, to: lastSeen) ?? lastSeen
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: lastSeen) ?? lastSeen
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: lastSeen) ?? lastSeen
        }
    }

    var daysUntilNext: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: nextExpectedDate)
        return max(0, components.day ?? 0)
    }
}

// MARK: - Budget Goal

struct BudgetGoal: Codable {
    var monthlyLimit: Double
    var currencyCode: String
    var alertAt80: Bool
    var alertAt100: Bool

    init(monthlyLimit: Double = 0, currencyCode: String = "USD", alertAt80: Bool = true, alertAt100: Bool = true) {
        self.monthlyLimit = monthlyLimit
        self.currencyCode = currencyCode
        self.alertAt80 = alertAt80
        self.alertAt100 = alertAt100
    }
}

// MARK: - Monthly Report

struct MonthlyReport: Identifiable {
    let id: UUID
    let year: Int
    let month: Int
    let totalSpent: Double
    let totalIncome: Double
    let net: Double
    let categoryBreakdown: [CategorySpending]
    let topCategory: String
    let vsLastMonthPercent: Double?
    let vsLastMonthAmount: Double?
    let recurringTotal: Double
    let currencyCode: String

    struct CategorySpending: Identifiable {
        let id = UUID()
        let category: String
        let amount: Double
        let percentage: Double
        let icon: String
    }

    var formattedMonth: String {
        let components = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        guard let date = calendar.date(from: components) else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    var monthShort: String {
        let components = DateComponents(year: year, month: month)
        let calendar = Calendar.current
        guard let date = calendar.date(from: components) else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }

    var yearShort: String {
        String(year).suffix(2).description
    }

    var vsLastMonthDescription: String {
        guard let pct = vsLastMonthPercent else { return "No comparison data" }
        let sign = pct >= 0 ? "▲" : "▼"
        return "\(sign) \(abs(pct).formatted(.number.precision(.fractionLength(0))))% vs last month"
    }

    var vsLastMonthColor: String {
        guard let pct = vsLastMonthPercent else { return "8a8a8a" }
        return pct > 0 ? "ff453a" : "34c759"
    }
}
