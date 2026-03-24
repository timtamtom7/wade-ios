import Foundation

@MainActor
final class ConversationService {
    static let shared = ConversationService()

    private let parser = ExpenseParser()
    private let db = DatabaseService.shared
    private let notifications = NotificationService.shared

    private init() {}

    func processUserInput(_ text: String) -> Message {
        guard let parsed = parser.parse(text) else {
            let suggestions = [
                "Try something like \"£12.50 lunch\" or \"£40 groceries\".",
                "Format: amount + description. Example: \"£15 coffee\" or \"£50 dinner\".",
                "I didn't catch the amount. Try \"£25 food\" or \"£10 coffee\"."
            ]
            let hint = suggestions.randomElement() ?? suggestions[0]
            return Message(
                role: .wade,
                text: "Hmm, I didn't catch that. \(hint)"
            )
        }

        // Check subscription limits
        let monthCount = db.fetchThisMonth().count
        if !SubscriptionManager.shared.canAddExpense(currentMonthCount: monthCount) {
            return Message(
                role: .wade,
                text: "You've hit the free limit of 20 expenses this month. Upgrade to Track for unlimited tracking, weekly summaries, and category insights.\n\nTap ⚙️ → Wade Pro to upgrade."
            )
        }

        do {
            try db.insert(parsed.transaction)
        } catch {
            return Message(role: .wade, text: "Oops, couldn't save that. Try again?")
        }

        let stats = db.weeklyStats()
        return Message.wadeConfirmation(
            transaction: parsed.transaction,
            weeklyTotal: stats.expenses,
            weeklyIncome: stats.income,
            weeklyNet: stats.net
        )
    }

    func getWeeklySummaryMessage() -> Message {
        let stats = db.weeklyStats()
        return Message.weeklySummary(expenses: stats.expenses, income: stats.income, net: stats.net)
    }

    func getGreeting() -> Message {
        let stats = db.weeklyStats()
        if stats.expenses > 0 || stats.income > 0 {
            return Message(
                role: .wade,
                text: "Hey! This week: \(formatCurrency(stats.expenses)) spent, \(formatCurrency(stats.income)) income. Ready when you are 💸"
            )
        } else {
            return Message(
                role: .wade,
                text: "Hey! I'm Wade — send me your expenses like \"£12.50 lunch\" or \"£40 groceries\" and I'll keep track. Type something to get started!"
            )
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }
}
