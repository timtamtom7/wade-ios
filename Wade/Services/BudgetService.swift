import Foundation

@MainActor
final class BudgetService {
    static let shared = BudgetService()

    private let budgetKey = "wade_budget_goal"

    var currentBudget: BudgetGoal {
        get {
            guard let data = UserDefaults.standard.data(forKey: budgetKey),
                  let budget = try? JSONDecoder().decode(BudgetGoal.self, from: data) else {
                return BudgetGoal()
            }
            return budget
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: budgetKey)
            }
        }
    }

    var hasLimit: Bool {
        currentBudget.monthlyLimit > 0
    }

    func setLimit(_ amount: Double) {
        var budget = currentBudget
        budget.monthlyLimit = amount
        currentBudget = budget
    }

    func clearLimit() {
        currentBudget = BudgetGoal()
    }

    func progressForThisMonth(spent: Double) -> BudgetProgress {
        BudgetProgress(
            spent: spent,
            limit: currentBudget.monthlyLimit,
            currencyCode: currentBudget.currencyCode
        )
    }

    func checkBudgetAlert(spent: Double) -> BudgetAlert? {
        guard hasLimit else { return nil }
        let limit = currentBudget.monthlyLimit
        let pct = spent / limit
        let pctInt = Int(pct * 100)

        if pct >= 1.0 {
            return BudgetAlert(type: .at100, spent: spent, limit: limit, percentage: pctInt)
        } else if pct >= 0.9 {
            return BudgetAlert(type: .approaching100, spent: spent, limit: limit, percentage: pctInt)
        } else if pct >= 0.8 {
            return BudgetAlert(type: .at80, spent: spent, limit: limit, percentage: pctInt)
        } else if pct >= 0.75 {
            return BudgetAlert(type: .approaching80, spent: spent, limit: limit, percentage: pctInt)
        }
        return nil
    }

    func budgetSummaryLine(spent: Double) -> String? {
        guard hasLimit else { return nil }
        let progress = progressForThisMonth(spent: spent)
        if progress.isOverBudget {
            return "⚠️ Over budget by \(Self.formatCurrency(progress.spent - progress.limit))"
        }
        return "\(progress.percentageInt)% of budget used (\(Self.formatCurrency(progress.remaining)) left)"
    }

    private static func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }
}
