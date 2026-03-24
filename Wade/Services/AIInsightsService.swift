import Foundation

// MARK: - AI Insight Types

enum AIInsightType {
    case spendingComparison      // "You spend 40% more on food when you eat out"
    case biggestMonth             // "Your biggest spending month was December (£X)"
    case savingsSuggestion        // "If you cut £100/month, you'd save £1,200/year"
    case categoryTrend            // "Entertainment spending is up 30% this month"
    case recurringWarning         // "Your bills increased by £50 this month"
    case savingsOpportunity       // "You could save £X by reducing Y"
}

struct AIInsight: Identifiable {
    let id = UUID()
    let type: AIInsightType
    let headline: String
    let body: String
    let icon: String
    let priority: Int  // 1 = most important

    var emoji: String {
        switch type {
        case .spendingComparison: return "📊"
        case .biggestMonth: return "🏆"
        case .savingsSuggestion: return "💡"
        case .categoryTrend: return "📈"
        case .recurringWarning: return "⚠️"
        case .savingsOpportunity: return "💰"
        }
    }
}

// MARK: - AI Insights Service

@MainActor
final class AIInsightsService {
    static let shared = AIInsightsService()

    private let db = DatabaseService.shared
    private let budgetService = BudgetService.shared
    private let currencyService = CurrencyService.shared
    private let recurringService = RecurringExpenseService.shared

    private init() {}

    // MARK: - Generate All Insights

    func generateInsights() -> [AIInsight] {
        var insights: [AIInsight] = []

        if let comparison = compareEatingOutVsGroceries() {
            insights.append(comparison)
        }

        if let biggestMonth = findBiggestMonth() {
            insights.append(biggestMonth)
        }

        if let savings = savingsSuggestion() {
            insights.append(savings)
        }

        if let trend = categoryTrendInsight() {
            insights.append(trend)
        }

        if let recurring = recurringBillsInsight() {
            insights.append(recurring)
        }

        if let opportunity = savingsOpportunity() {
            insights.append(opportunity)
        }

        return insights.sorted { $0.priority < $1.priority }
    }

    // MARK: - Specific Insights

    /// "You spend 40% more on food when you eat out vs cooking at home"
    func compareEatingOutVsGroceries() -> AIInsight? {
        let all = db.fetchAll()
        let expenses = all.filter { $0.type == .expense }

        let foodExpenses = expenses.filter {
            ["Food", "Restaurant", "Dining", "Coffee", "Lunch", "Dinner", "Breakfast"].contains($0.category)
        }

        let groceryExpenses = expenses.filter {
            ["Groceries", "Supermarket", "Market"].contains($0.category)
        }

        guard foodExpenses.count >= 3, groceryExpenses.count >= 3 else { return nil }

        let foodTotal = foodExpenses.reduce(0) { $0 + $1.amount }
        let groceryTotal = groceryExpenses.reduce(0) { $0 + $1.amount }

        guard groceryTotal > 0 else { return nil }

        let ratio = (foodTotal - groceryTotal) / groceryTotal
        guard ratio > 0.15 else { return nil }  // Only show if 15%+ more

        let pct = Int(ratio * 100)
        let body = "You've spent \(formatCurrency(foodTotal)) on dining out vs \(formatCurrency(groceryTotal)) on groceries. Dining out costs you ~\(pct)% more."

        return AIInsight(
            type: .spendingComparison,
            headline: "Eating out costs \(pct)% more than groceries",
            body: body,
            icon: "fork.knife",
            priority: 1
        )
    }

    /// "Your biggest spending month was December (£X)"
    func findBiggestMonth() -> AIInsight? {
        let all = db.fetchAll()
        let expenses = all.filter { $0.type == .expense }

        guard expenses.count >= 10 else { return nil }

        let calendar = Calendar.current
        var monthlyTotals: [Int: Double] = [:]  // year*100 + month -> total

        for tx in expenses {
            let components = calendar.dateComponents([.year, .month], from: tx.date)
            if let year = components.year, let month = components.month {
                let key = year * 100 + month
                monthlyTotals[key, default: 0] += tx.amount
            }
        }

        guard let maxKey = monthlyTotals.max(by: { $0.value < $1.value }) else { return nil }

        let year = maxKey.key / 100
        let month = maxKey.key % 100

        let monthName: String
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        if let date = calendar.date(from: DateComponents(year: year, month: month)) {
            monthName = formatter.string(from: date)
        } else {
            monthName = "Unknown"
        }

        let amount = maxKey.value

        return AIInsight(
            type: .biggestMonth,
            headline: "Biggest month: \(monthName) \(year)",
            body: "You spent \(formatCurrency(amount)) in \(monthName) \(year) — your highest spending month.",
            icon: "trophy.fill",
            priority: 2
        )
    }

    /// "If you cut £100/month, you'd save £1,200/year"
    func savingsSuggestion() -> AIInsight? {
        let all = db.fetchAll()
        let expenses = all.filter { $0.type == .expense }

        guard expenses.count >= 10 else { return nil }

        let avgMonthly = calculateAverageMonthlySpend()
        guard avgMonthly > 0 else { return nil }

        // Suggest cutting 5% of monthly spending
        let suggestedCut = avgMonthly * 0.05
        let annualSavings = suggestedCut * 12

        guard annualSavings > 50 else { return nil }

        return AIInsight(
            type: .savingsSuggestion,
            headline: "Save \(formatCurrency(annualSavings))/year",
            body: "If you cut \(formatCurrency(suggestedCut))/month — just 5% of your average spend — you'd save \(formatCurrency(annualSavings)) a year.",
            icon: "lightbulb.fill",
            priority: 3
        )
    }

    /// "Your [category] spending is up X% this month vs last"
    func categoryTrendInsight() -> AIInsight? {
        let all = db.fetchAll()
        let expenses = all.filter { $0.type == .expense }

        let calendar = Calendar.current
        let now = Date()

        guard let thisMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: thisMonthStart),
              let lastMonthEnd = calendar.date(byAdding: .month, value: 1, to: lastMonthStart) else {
            return nil
        }

        let thisMonthExpenses = expenses.filter { $0.date >= thisMonthStart }
        let lastMonthExpenses = expenses.filter { $0.date >= lastMonthStart && $0.date < lastMonthEnd }

        var thisMonthByCategory: [String: Double] = [:]
        var lastMonthByCategory: [String: Double] = [:]

        for tx in thisMonthExpenses {
            thisMonthByCategory[tx.category, default: 0] += tx.amount
        }

        for tx in lastMonthExpenses {
            lastMonthByCategory[tx.category, default: 0] += tx.amount
        }

        // Find biggest change
        var biggestChange: (category: String, pct: Double, thisMonth: Double, lastMonth: Double)?

        for (cat, thisAmt) in thisMonthByCategory {
            let lastAmt = lastMonthByCategory[cat] ?? 0
            guard lastAmt > 0 else { continue }
            let change = (thisAmt - lastAmt) / lastAmt
            if abs(change) > 0.2 && (biggestChange == nil || abs(change) > abs(biggestChange!.pct)) {
                biggestChange = (cat, change, thisAmt, lastAmt)
            }
        }

        guard let change = biggestChange else { return nil }

        let pct = Int(abs(change.pct) * 100)
        let direction = change.pct > 0 ? "up" : "down"
        let sign = change.pct > 0 ? "▲" : "▼"

        return AIInsight(
            type: .categoryTrend,
            headline: "\(change.category) spending \(direction) \(pct)%",
            body: "\(sign) \(pct)% \(direction) vs last month. \(formatCurrency(change.thisMonth)) this month vs \(formatCurrency(change.lastMonth)) last month.",
            icon: "chart.line.uptrend.xyaxis",
            priority: 4
        )
    }

    /// "Your bills went up by £50 this month"
    func recurringBillsInsight() -> AIInsight? {
        let recurring = recurringService.recurringExpenses

        guard !recurring.isEmpty else { return nil }

        let calendar = Calendar.current
        let now = Date()
        guard let thisMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: thisMonthStart) else {
            return nil
        }

        let all = db.fetchAll()
        let recurringCategories = Set(recurring.map { $0.category })

        let thisMonthRecurring = all.filter {
            $0.type == .expense &&
            $0.date >= thisMonthStart &&
            recurringCategories.contains($0.category)
        }

        let lastMonthRecurring = all.filter {
            $0.type == .expense &&
            $0.date >= lastMonthStart &&
            $0.date < thisMonthStart &&
            recurringCategories.contains($0.category)
        }

        let thisTotal = thisMonthRecurring.reduce(0) { $0 + $1.amount }
        let lastTotal = lastMonthRecurring.reduce(0) { $0 + $1.amount }

        let diff = thisTotal - lastTotal
        guard abs(diff) > 20 else { return nil }  // Only flag changes > $20

        let direction = diff > 0 ? "increased" : "decreased"

        return AIInsight(
            type: .recurringWarning,
            headline: "Bills \(direction) \(formatCurrency(abs(diff)))",
            body: "Your recurring bills have \(direction) by \(formatCurrency(abs(diff))) compared to last month.",
            icon: "exclamationmark.triangle.fill",
            priority: 2
        )
    }

    /// "You could save £X by reducing [category]"
    func savingsOpportunity() -> AIInsight? {
        let all = db.fetchAll()
        let expenses = all.filter { $0.type == .expense }

        guard expenses.count >= 10 else { return nil }

        // Find category with highest spend that could reasonably be reduced
        var categoryTotals: [String: Double] = [:]
        for tx in expenses {
            categoryTotals[tx.category, default: 0] += tx.amount
        }

        // Non-essential categories that could be reduced
        let reducibleCategories = ["Entertainment", "Shopping", "Food", "Dining", "Restaurant", "Coffee", "Subscription"]

        var bestCategory: (String, Double)?
        for (cat, total) in categoryTotals {
            if reducibleCategories.contains(cat) {
                if bestCategory == nil || total > bestCategory!.1 {
                    bestCategory = (cat, total)
                }
            }
        }

        guard let (cat, total) = bestCategory, total > 100 else { return nil }

        // Suggest reducing by 20%
        let potentialSavings = total * 0.20

        return AIInsight(
            type: .savingsOpportunity,
            headline: "Save \(formatCurrency(potentialSavings))/mo on \(cat)",
            body: "You spend ~\(formatCurrency(total)) on \(cat) monthly. Cutting 20% would save you \(formatCurrency(potentialSavings))/month — \(formatCurrency(potentialSavings * 12))/year.",
            icon: "dollarsign.circle.fill",
            priority: 5
        )
    }

    // MARK: - Helpers

    private func calculateAverageMonthlySpend() -> Double {
        let all = db.fetchAll()
        let expenses = all.filter { $0.type == .expense }

        guard !expenses.isEmpty else { return 0 }

        let calendar = Calendar.current
        let sorted = expenses.sorted { $0.date < $1.date }

        guard let first = sorted.first, let last = sorted.last else { return 0 }

        let monthsDiff = calendar.dateComponents([.month], from: first.date, to: last.date).month ?? 1
        let total = expenses.reduce(0) { $0 + $1.amount }

        return total / Double(max(1, monthsDiff))
    }

    func formatCurrency(_ amount: Double) -> String {
        currencyService.formatCurrency(amount)
    }

    // MARK: - Conversation-triggered insights

    func getInsightForQuery(_ text: String) -> AIInsight? {
        let lowercased = text.lowercased()

        if lowercased.contains("spend") && (lowercased.contains("more") || lowercased.contains("increase") || lowercased.contains("eating") || lowercased.contains("food")) {
            return compareEatingOutVsGroceries()
        }

        if lowercased.contains("biggest") || lowercased.contains("highest") || lowercased.contains("most spent") {
            return findBiggestMonth()
        }

        if lowercased.contains("save") || lowercased.contains("suggestion") || lowercased.contains("tip") || lowercased.contains("reduce") {
            if let savings = savingsSuggestion() {
                return savings
            }
            return savingsOpportunity()
        }

        if lowercased.contains("insight") || lowercased.contains("tip") || lowercased.contains("tip") {
            let insights = generateInsights()
            return insights.first
        }

        return nil
    }

    func summaryOfInsights() -> String {
        let insights = generateInsights()
        guard !insights.isEmpty else { return "Not enough data for insights yet. Keep tracking your expenses!" }

        var text = "🧠 Here's what I found:\n\n"
        for (i, insight) in insights.prefix(3).enumerated() {
            text += "\(i + 1). \(insight.headline)\n"
            text += "   \(insight.body)\n\n"
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
