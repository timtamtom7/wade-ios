import Foundation

enum MessageRole {
    case user
    case wade
}

// MARK: - Supporting Types

struct BudgetProgress {
    let spent: Double
    let limit: Double
    let currencyCode: String

    var percentage: Double {
        guard limit > 0 else { return 0 }
        return min(spent / limit, 1.5)
    }

    var percentageInt: Int {
        Int((spent / limit) * 100)
    }

    var remaining: Double {
        max(0, limit - spent)
    }

    var isOverBudget: Bool {
        spent > limit
    }

    var progressColor: String {
        let pct = percentage
        if pct >= 1.0 { return "ff453a" }
        if pct >= 0.8 { return "ff9f0a" }
        return "34c759"
    }
}

struct BudgetAlert {
    let type: AlertType
    let spent: Double
    let limit: Double
    let percentage: Int

    enum AlertType {
        case approaching80
        case at80
        case approaching100
        case at100
        case overBudget

        var emoji: String {
            switch self {
            case .approaching80, .at80: return "⚠️"
            case .approaching100, .at100: return "🔴"
            case .overBudget: return "🚨"
            }
        }
    }

    var headline: String {
        switch type {
        case .approaching80: return "Heads up"
        case .at80: return "80% of budget used"
        case .approaching100: return "Almost at limit"
        case .at100: return "Budget reached"
        case .overBudget: return "Over budget!"
        }
    }
}

struct RecurringDetection {
    let category: String
    let estimatedAmount: Double
    let frequency: String
    let sampleCount: Int
    let lastDate: Date

    var detectionText: String {
        "I notice you spend about \(Message.formatCurrency(estimatedAmount)) on \(category) \(frequency) — that's roughly \(Message.formatCurrency(estimatedAmount * 4)) a month. Want me to mark this as recurring?"
    }
}

// MARK: - Message

enum MessageType: String {
    case text
    case transactionConfirmation
    case weeklySummary
    case monthlyReport
    case budgetAlert
    case recurringDetection
    case parseFailure
    case error
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
    let monthlyReport: MonthlyReport?
    let budgetProgress: BudgetProgress?
    let budgetAlert: BudgetAlert?
    let recurringDetection: RecurringDetection?
    let messageType: MessageType

    init(
        id: UUID = UUID(),
        role: MessageRole,
        text: String,
        timestamp: Date = Date(),
        transaction: Transaction? = nil,
        weeklyTotal: Double? = nil,
        weeklyIncome: Double? = nil,
        weeklyNet: Double? = nil,
        monthlyReport: MonthlyReport? = nil,
        budgetProgress: BudgetProgress? = nil,
        budgetAlert: BudgetAlert? = nil,
        recurringDetection: RecurringDetection? = nil,
        messageType: MessageType = .text
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.timestamp = timestamp
        self.transaction = transaction
        self.weeklyTotal = weeklyTotal
        self.weeklyIncome = weeklyIncome
        self.weeklyNet = weeklyNet
        self.monthlyReport = monthlyReport
        self.budgetProgress = budgetProgress
        self.budgetAlert = budgetAlert
        self.recurringDetection = recurringDetection
        self.messageType = messageType
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
            weeklyNet: weeklyNet,
            messageType: .transactionConfirmation
        )
    }

    static func weeklySummary(expenses: Double, income: Double, net: Double) -> Message {
        let sign = net >= 0 ? "+" : ""
        let netStr = formatCurrency(abs(net))
        let emoji = net >= 0 ? "📈" : "📉"
        return Message(
            role: .wade,
            text: "📊 Weekly Summary\n\nSpent: \(formatCurrency(expenses))\nIncome: \(formatCurrency(income))\nNet: \(sign)\(netStr) \(emoji)",
            weeklyTotal: expenses,
            weeklyIncome: income,
            weeklyNet: net,
            messageType: .weeklySummary
        )
    }

    static func monthlyReportMessage(_ report: MonthlyReport) -> Message {
        Message(
            role: .wade,
            text: monthlyReportText(report),
            monthlyReport: report,
            messageType: .monthlyReport
        )
    }

    static func budgetAlertMessage(_ alert: BudgetAlert) -> Message {
        Message(
            role: .wade,
            text: budgetAlertText(alert),
            budgetAlert: alert,
            messageType: .budgetAlert
        )
    }

    static func recurringDetectionMessage(_ detection: RecurringDetection) -> Message {
        Message(
            role: .wade,
            text: recurringDetectionText(detection),
            recurringDetection: detection,
            messageType: .recurringDetection
        )
    }

    // MARK: - Private Helpers

    private static func wadeConfirmationText(transaction: Transaction, weeklyTotal: Double, weeklyIncome: Double, weeklyNet: Double) -> String {
        if transaction.type == .income {
            return "✓ Income logged: \(formatCurrency(transaction.amount))\n\(transaction.category.isEmpty ? "" : "\(transaction.category) · ")\(formatDate(transaction.date))"
        } else {
            let recurringNote = transaction.isRecurring ? "\n🔁 Recurring" : ""
            return "✓ Logged: \(formatCurrency(transaction.amount))\n\(transaction.category.isEmpty ? "" : "\(transaction.category) · ")\(formatDate(transaction.date))\nThis week: \(formatCurrency(weeklyTotal))\(recurringNote)"
        }
    }

    private static func monthlyReportText(_ report: MonthlyReport) -> String {
        """
        📊 \(report.formattedMonth)

        Spent: \(formatCurrency(report.totalSpent))
        Income: \(formatCurrency(report.totalIncome))
        Net: \(report.net >= 0 ? "+" : "")\(formatCurrency(report.net))

        \(report.vsLastMonthDescription)
        """
    }

    private static func budgetAlertText(_ alert: BudgetAlert) -> String {
        "\(alert.type.emoji) \(alert.headline): \(formatCurrency(alert.spent)) of \(formatCurrency(alert.limit)) (\(alert.percentage)%)"
    }

    private static func recurringDetectionText(_ detection: RecurringDetection) -> String {
        detection.detectionText
    }

    static func formatCurrency(_ amount: Double) -> String {
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
