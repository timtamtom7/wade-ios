import Foundation

@MainActor
final class MonthlyReportService {
    static let shared = MonthlyReportService()

    private let db = DatabaseService.shared

    private let categoryIcons: [String: String] = [
        "Food": "fork.knife",
        "Groceries": "cart.fill",
        "Transport": "car.fill",
        "Shopping": "bag.fill",
        "Entertainment": "gamecontroller.fill",
        "Health": "heart.fill",
        "Bills": "doc.text.fill",
        "Travel": "airplane",
        "Education": "book.fill",
        "Salary": "banknote.fill",
        "Other": "circle.fill"
    ]

    func generateReport(for date: Date = Date()) -> MonthlyReport? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let monthStart = calendar.date(from: components),
              let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
            return nil
        }

        let allTransactions = db.fetchAll()
        let monthTransactions = allTransactions.filter { $0.date >= monthStart && $0.date < nextMonth }

        if monthTransactions.isEmpty { return nil }

        let expenses = monthTransactions.filter { $0.type == .expense }
        let income = monthTransactions.filter { $0.type == .income }

        let totalSpent = expenses.reduce(0) { $0 + $1.amount }
        let totalIncome = income.reduce(0) { $0 + $1.amount }
        let net = totalIncome - totalSpent

        // Category breakdown
        var categoryTotals: [String: Double] = [:]
        for tx in expenses {
            categoryTotals[tx.category, default: 0] += tx.amount
        }

        let categoryBreakdown: [MonthlyReport.CategorySpending] = categoryTotals
            .sorted { $0.value > $1.value }
            .map { category, amount in
                MonthlyReport.CategorySpending(
                    category: category,
                    amount: amount,
                    percentage: totalSpent > 0 ? (amount / totalSpent) * 100 : 0,
                    icon: categoryIcons[category] ?? "circle.fill"
                )
            }

        let topCategory = categoryBreakdown.first?.category ?? "None"

        // Last month comparison
        let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: monthStart)!
        let lastMonthEnd = monthStart
        let lastMonthTransactions = allTransactions.filter { $0.date >= lastMonthStart && $0.date < lastMonthEnd }
        let lastMonthExpenses = lastMonthTransactions.filter { $0.type == .expense }
        let lastMonthTotal = lastMonthExpenses.reduce(0) { $0 + $1.amount }

        var vsLastMonthPct: Double?
        var vsLastMonthAmount: Double?
        if lastMonthTotal > 0 {
            vsLastMonthPct = ((totalSpent - lastMonthTotal) / lastMonthTotal) * 100
            vsLastMonthAmount = totalSpent - lastMonthTotal
        }

        // Recurring total
        let recurringTotal = expenses.filter { $0.isRecurring }.reduce(0) { $0 + $1.amount }

        return MonthlyReport(
            id: UUID(),
            year: components.year!,
            month: components.month!,
            totalSpent: totalSpent,
            totalIncome: totalIncome,
            net: net,
            categoryBreakdown: categoryBreakdown,
            topCategory: topCategory,
            vsLastMonthPercent: vsLastMonthPct,
            vsLastMonthAmount: vsLastMonthAmount,
            recurringTotal: recurringTotal,
            currencyCode: "USD"
        )
    }

    func generateReportForMonth(year: Int, month: Int) -> MonthlyReport? {
        let calendar = Calendar.current
        guard let date = calendar.date(from: DateComponents(year: year, month: month)) else { return nil }
        return generateReport(for: date)
    }

    func matchesMonthlyQuery(_ text: String) -> (year: Int, month: Int)? {
        let lowercased = text.lowercased()
        let months = [
            "january": 1, "jan": 1,
            "february": 2, "feb": 2,
            "march": 3, "mar": 3,
            "april": 4, "apr": 4,
            "may": 5, "may": 5,
            "june": 6, "jun": 6,
            "july": 7, "jul": 7,
            "august": 8, "aug": 8,
            "september": 9, "sep": 9,
            "october": 10, "oct": 10,
            "november": 11, "nov": 11,
            "december": 12, "dec": 12
        ]

        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)

        // Pattern: "how was March" or "march report" or "last month"
        if lowercased.contains("last month") {
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: now)!
            let comps = calendar.dateComponents([.year, .month], from: lastMonth)
            return (comps.year!, comps.month!)
        }

        if lowercased.contains("this month") {
            let comps = calendar.dateComponents([.year, .month], from: now)
            return (comps.year!, comps.month!)
        }

        for (monthName, monthNum) in months {
            if lowercased.contains(monthName) {
                // Try to extract year
                let yearPattern = "(20[0-9]{2})"
                if let regex = try? NSRegularExpression(pattern: yearPattern),
                   let match = regex.firstMatch(in: lowercased, range: NSRange(lowercased.startIndex..., in: lowercased)),
                   let range = Range(match.range(at: 1), in: lowercased),
                   let year = Int(String(lowercased[range])) {
                    return (year, monthNum)
                }
                // Default to current year
                return (currentYear, monthNum)
            }
        }

        return nil
    }
}
