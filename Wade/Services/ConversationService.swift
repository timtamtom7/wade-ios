import Foundation

@MainActor
final class ConversationService {
    static let shared = ConversationService()

    private let parser = ExpenseParser()
    private let db = DatabaseService.shared
    private let notifications = NotificationService.shared
    private let budgetService = BudgetService.shared
    private let monthlyReportService = MonthlyReportService.shared
    private let recurringService = RecurringExpenseService.shared
    private let currencyService = CurrencyService.shared
    private let exportService = ExportService.shared

    private var lastBudgetAlert: BudgetAlert?
    private var lastBudgetAlertMonth: Int = -1

    private init() {}

    func processUserInput(_ text: String) -> Message {
        let lowercased = text.lowercased()

        // Handle budget limit setting
        if lowercased.contains("budget") || lowercased.contains("limit") || lowercased.contains("don't spend") || lowercased.contains("max ") {
            if let limit = parser.parseBudgetLimit(text), limit > 0 {
                budgetService.setLimit(limit)
                let stats = db.monthlyStats()
                let progress = budgetService.progressForThisMonth(spent: stats.expenses)
                let budgetLine = progress.isOverBudget
                    ? "⚠️ Over budget by \(formatCurrency(progress.spent - progress.limit))"
                    : "\(progress.percentageInt)% of budget used (\(formatCurrency(progress.remaining)) left)"
                return Message(
                    role: .wade,
                    text: "✅ Budget set: \(formatCurrency(limit))\n\(budgetLine)",
                    budgetProgress: progress,
                    messageType: .text
                )
            }
        }

        // Handle clear budget
        if lowercased.contains("clear budget") || lowercased.contains("remove budget") || lowercased.contains("delete budget") {
            budgetService.clearLimit()
            return Message(
                role: .wade,
                text: "Budget cleared. Let me know if you want to set a new limit."
            )
        }

        // Handle monthly report queries
        if lowercased.contains("how was") || lowercased.contains("monthly") || lowercased.contains("month report") || lowercased.contains("this month") || lowercased.contains("last month") {
            if let (year, month) = monthlyReportService.matchesMonthlyQuery(text) {
                if let report = monthlyReportService.generateReportForMonth(year: year, month: month) {
                    return Message.monthlyReportMessage(report)
                } else {
                    return Message(
                        role: .wade,
                        text: "No data for that month yet. Try sending some expenses first!"
                    )
                }
            }
        }

        // Handle recurring mark
        if lowercased.contains("recurring") || lowercased.contains("subscription") || lowercased.contains("repeat") {
            // Check if user is marking something as recurring
            if let parsed = parser.parse(text), parsed.type == .expense {
                let frequency = parser.parseRecurringFrequency(text) ?? .monthly
                recurringService.markAsRecurring(parsed.transaction, frequency: frequency)
                return Message(
                    role: .wade,
                    text: "🔁 Marked as \(frequency.rawValue) recurring: \(formatCurrency(parsed.amount)) for \(parsed.category)\nI'll track this separately going forward."
                )
            }
        }

        // Handle upcoming bills query
        if lowercased.contains("upcoming") && (lowercased.contains("bill") || lowercased.contains("recurring")) {
            let upcoming = recurringService.upcomingBills(withinDays: 7)
            return Message.recurringBillsListMessage(upcoming)
        }

        // Handle yearly summary query
        if lowercased.contains("year") && (lowercased.contains("summary") || lowercased.contains("total") || lowercased.contains("so far") || lowercased.contains("spent")) {
            let year = extractYear(from: lowercased) ?? Calendar.current.component(.year, from: Date())
            if let summary = exportService.generateYearlySummary(year: year) {
                return Message.yearlySummaryMessage(summary)
            } else {
                return Message(role: .wade, text: "No data for \(year) yet. Try sending some expenses first!")
            }
        }

        // Handle export requests
        if lowercased.contains("export") || lowercased.contains("download") {
            if lowercased.contains("csv") || lowercased.contains("spreadsheet") {
                let csv = exportService.exportToCSV()
                if let fileURL = exportService.saveCSVToFile(csv, filename: "wade_export_\(formattedDate())") {
                    return Message(
                        role: .wade,
                        text: "📄 Your data is ready! CSV exported with \(db.fetchAll().count) transactions. Check your files or share it.",
                        exportFileURL: fileURL,
                        messageType: .exportReady
                    )
                }
            }

            if lowercased.contains("pdf") || lowercased.contains("report") {
                if let report = monthlyReportService.generateReport() {
                    if let pdfData = exportService.generateMonthlyPDF(report: report),
                       let fileURL = exportService.savePDFToFile(pdfData, filename: "wade_report_\(report.monthShort)\(report.yearShort)") {
                        return Message(
                            role: .wade,
                            text: "📊 Your \(report.formattedMonth) report is ready! \(report.categoryBreakdown.count) categories, \(report.totalSpent > 0 ? "spent \(formatCurrency(report.totalSpent))" : "no expenses").",
                            exportFileURL: fileURL,
                            messageType: .exportReady
                        )
                    }
                }
                return Message(role: .wade, text: "I need expense data first to generate a report. Try sending some expenses!")
            }

            if lowercased.contains("quickbooks") || lowercased.contains("xero") || lowercased.contains("accounting") {
                let csv = exportService.exportForAccountingSoftware()
                if let fileURL = exportService.saveCSVToFile(csv, filename: "wade_accounting_\(formattedDate())") {
                    return Message(
                        role: .wade,
                        text: "📒 Accounting export ready! Compatible with QuickBooks, Xero, and most accounting software. \(db.fetchAll().count) transactions.",
                        exportFileURL: fileURL,
                        messageType: .exportReady
                    )
                }
            }

            // Generic export request
            let csv = exportService.exportToCSV()
            if let fileURL = exportService.saveCSVToFile(csv, filename: "wade_export_\(formattedDate())") {
                return Message(
                    role: .wade,
                    text: "📄 Exported \(db.fetchAll().count) transactions to CSV. Say \"export PDF\" for a formatted monthly report.",
                    exportFileURL: fileURL,
                    messageType: .exportReady
                )
            }
        }

        // Handle biggest expense query
        if lowercased.contains("biggest") || lowercased.contains("top category") || lowercased.contains("most spent") {
            if let report = monthlyReportService.generateReport() {
                if let top = report.categoryBreakdown.first {
                    return Message(
                        role: .wade,
                        text: "🏆 Biggest category this month: \(top.category) at \(Int(top.percentage))% (\(formatCurrency(top.amount))).",
                        messageType: .text
                    )
                }
            }
        }

        // Parse expense
        guard let parsed = parser.parse(text) else {
            let suggestions = [
                "Try something like \"£12.50 lunch\" or \"$40 groceries\".",
                "Format: amount + description. Example: \"£15 coffee\" or \"€10 dinner\".",
                "I didn't catch the amount. Try \"£25 food\" or \"$10 coffee\"."
            ]
            let hint = suggestions.randomElement() ?? suggestions[0]
            return Message(
                role: .wade,
                text: "Hmm, I didn't catch that. \(hint)",
                messageType: .parseFailure
            )
        }

        // Check subscription limits
        let monthCount = db.fetchThisMonth().count
        if !SubscriptionManager.shared.canAddExpense(currentMonthCount: monthCount) {
            return Message(
                role: .wade,
                text: "You've hit the free limit of 20 expenses this month. Upgrade to Track for unlimited tracking, weekly summaries, and category insights.\n\nTap ⚙️ → Wade Pro to upgrade.",
                messageType: .error
            )
        }

        do {
            try db.insert(parsed.transaction)
        } catch {
            return Message(role: .wade, text: "Oops, couldn't save that. Try again?", messageType: .error)
        }

        let stats = db.weeklyStats()

        // Check for recurring pattern detection
        let recentTx = db.fetchThisMonth()
        let detections = recurringService.detectRecurringPatterns(from: recentTx)
        let response = Message.wadeConfirmation(
            transaction: parsed.transaction,
            weeklyTotal: stats.expenses,
            weeklyIncome: stats.income,
            weeklyNet: stats.net
        )

        // Budget alert check (once per month)
        let monthStats = db.monthlyStats()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())

        if currentMonth != lastBudgetAlertMonth {
            if let alert = budgetService.checkBudgetAlert(spent: monthStats.expenses) {
                lastBudgetAlert = alert
                lastBudgetAlertMonth = currentMonth
                // Prepend budget alert
                let alertMsg = Message.budgetAlertMessage(alert)
                return alertMsg
            }
        }

        // Detect recurring patterns (only if enough data)
        if let detection = detections.first, recentTx.count >= 5 {
            // Only show if not already marked as recurring
            if !parsed.transaction.isRecurring {
                let detectionMsg = Message.recurringDetectionMessage(detection)
                return detectionMsg
            }
        }

        return response
    }

    func getWeeklySummaryMessage() -> Message {
        let stats = db.weeklyStats()
        let monthStats = db.monthlyStats()
        var summary = Message.weeklySummary(expenses: stats.expenses, income: stats.income, net: stats.net)

        // Add budget progress if set
        if budgetService.hasLimit {
            let progress = budgetService.progressForThisMonth(spent: monthStats.expenses)
            let budgetLine = progress.isOverBudget
                ? "\n⚠️ Over budget by \(formatCurrency(progress.spent - progress.limit))"
                : "\n💰 \(progress.percentageInt)% of budget used (\(formatCurrency(progress.remaining)) left)"
            summary = Message(
                role: .wade,
                text: summary.text + budgetLine,
                weeklyTotal: stats.expenses,
                weeklyIncome: stats.income,
                weeklyNet: stats.net,
                budgetProgress: progress,
                messageType: .weeklySummary
            )
        }

        return summary
    }

    func getGreeting() -> Message {
        let stats = db.weeklyStats()
        let monthStats = db.monthlyStats()

        var greetingText: String
        if stats.expenses > 0 || stats.income > 0 {
            greetingText = "Hey! This week: \(formatCurrency(stats.expenses)) spent, \(formatCurrency(stats.income)) income. Ready when you are 💸"
        } else {
            greetingText = "Hey! I'm Wade — send me your expenses like \"£12.50 lunch\" or \"$40 groceries\" and I'll keep track. Type something to get started!"
        }

        // Add budget alert if approaching limit
        if budgetService.hasLimit {
            let progress = budgetService.progressForThisMonth(spent: monthStats.expenses)
            if progress.percentage >= 0.75 {
                let alertText = progress.isOverBudget
                    ? "\n⚠️ You've gone over your monthly budget!"
                    : "\n⚠️ \(progress.percentageInt)% of budget used — \(formatCurrency(progress.remaining)) left"
                greetingText += alertText
            }
        }

        return Message(role: .wade, text: greetingText)
    }

    private func formatCurrency(_ amount: Double) -> String {
        currencyService.formatCurrency(amount)
    }

    private func extractYear(from text: String) -> Int? {
        let pattern = "20[0-9]{2}"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range, in: text) else {
            return nil
        }
        return Int(String(text[range]))
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: Date())
    }
}
