import Foundation

enum MessageRole {
    case user
    case wade
}

struct Message: Identifiable {
    let id: UUID
    let role: MessageRole
    let text: String
    let timestamp: Date
    let transaction: Transaction?
    let weeklyTotal: Double?
    let weeklyIncome: Double?
    let weeklyNet: Double?

    init(id: UUID = UUID(), role: MessageRole, text: String, timestamp: Date = Date(), transaction: Transaction? = nil, weeklyTotal: Double? = nil, weeklyIncome: Double? = nil, weeklyNet: Double? = nil) {
        self.id = id
        self.role = role
        self.text = text
        self.timestamp = timestamp
        self.transaction = transaction
        self.weeklyTotal = weeklyTotal
        self.weeklyIncome = weeklyIncome
        self.weeklyNet = weeklyNet
    }

    static func userMessage(_ text: String) -> Message {
        Message(role: .user, text: text)
    }

    static func wadeConfirmation(transaction: Transaction, weeklyTotal: Double, weeklyIncome: Double, weeklyNet: Double) -> Message {
        Message(
            role: .wade,
            text: wadeConfirmationText(transaction: transaction, weeklyTotal: weeklyTotal, weeklyIncome: weeklyIncome, weeklyNet: weeklyNet),
            transaction: transaction,
            weeklyTotal: weeklyTotal,
            weeklyIncome: weeklyIncome,
            weeklyNet: weeklyNet
        )
    }

    private static func wadeConfirmationText(transaction: Transaction, weeklyTotal: Double, weeklyIncome: Double, weeklyNet: Double) -> String {
        if transaction.type == .income {
            return "✓ Income logged: \(formatCurrency(transaction.amount))\n\(transaction.category.isEmpty ? "" : "\(transaction.category) · ")\(formatDate(transaction.date))"
        } else {
            return "✓ Logged: \(formatCurrency(transaction.amount))\n\(transaction.category.isEmpty ? "" : "\(transaction.category) · ")\(formatDate(transaction.date))\nThis week: \(formatCurrency(weeklyTotal))"
        }
    }

    static func weeklySummary(expenses: Double, income: Double, net: Double) -> Message {
        let sign = net >= 0 ? "+" : ""
        let netStr = formatCurrency(abs(net))
        let emoji = net >= 0 ? "📈" : "📉"
        return Message(
            role: .wade,
            text: "📊 Weekly Summary\n\nSpent: \(formatCurrency(expenses))\nIncome: \(formatCurrency(income))\nNet: \(sign)\(netStr) \(emoji)"
        )
    }

    private static func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
