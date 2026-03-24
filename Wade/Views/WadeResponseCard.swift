import SwiftUI

struct WadeResponseCard: View {
    let message: Message

    init(message: Message) {
        self.message = message
    }

    private let cardColor = Color(hex: "1c1c1e")
    private let errorCardColor = Color(hex: "2a1a0a")
    private let incomeColor = Color(hex: "34c759")
    private let expenseColor = Color(hex: "ff453a")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")
    private let warningColor = Color(hex: "ff9f0a")
    private let accentColor = Color(hex: "ffd60a")

    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    private var isErrorMessage: Bool {
        message.messageType == .error || message.messageType == .parseFailure
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                switch message.messageType {
                case .monthlyReport:
                    monthlyReportContent
                case .budgetAlert:
                    budgetAlertContent
                case .recurringDetection:
                    recurringDetectionContent
                case .weeklySummary:
                    weeklySummaryContent
                default:
                    if let tx = message.transaction {
                        transactionContent(tx)
                    } else {
                        textContent
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: 300, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(cardForMessage)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(borderForMessage, lineWidth: isErrorMessage ? 1 : 0)
            )

            Spacer(minLength: 60)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    // MARK: - Monthly Report Content

    private var monthlyReportContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let report = message.monthlyReport {
                // Header
                HStack(spacing: 6) {
                    Text("📊")
                        .font(.system(size: 16))
                    Text(report.formattedMonth)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(textColor)
                }

                Divider()
                    .background(secondaryColor.opacity(0.3))

                // Totals
                VStack(spacing: 8) {
                    HStack {
                        Text("Spent")
                            .font(.system(size: 13))
                            .foregroundColor(secondaryColor)
                        Spacer()
                        Text(formatCurrency(report.totalSpent))
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundColor(expenseColor)
                    }

                    HStack {
                        Text("Income")
                            .font(.system(size: 13))
                            .foregroundColor(secondaryColor)
                        Spacer()
                        Text(formatCurrency(report.totalIncome))
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundColor(incomeColor)
                    }

                    HStack {
                        Text("Net")
                            .font(.system(size: 13))
                            .foregroundColor(secondaryColor)
                        Spacer()
                        let sign = report.net >= 0 ? "+" : ""
                        Text("\(sign)\(formatCurrency(abs(report.net)))")
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundColor(report.net >= 0 ? incomeColor : expenseColor)
                    }
                }

                // vs last month
                if let pct = report.vsLastMonthPercent {
                    Divider()
                        .background(secondaryColor.opacity(0.3))
                    HStack {
                        Text(pct >= 0 ? "▲ Spent more" : "▼ Spent less")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: report.vsLastMonthColor))
                        Text("vs last month")
                            .font(.system(size: 12))
                            .foregroundColor(secondaryColor)
                    }
                }

                // Category breakdown
                if !report.categoryBreakdown.isEmpty {
                    Divider()
                        .background(secondaryColor.opacity(0.3))

                    Text("By category")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(secondaryColor)

                    ForEach(report.categoryBreakdown.prefix(5)) { cat in
                        categoryRow(cat)
                    }

                    if report.categoryBreakdown.count > 5 {
                        Text("+ \(report.categoryBreakdown.count - 5) more categories")
                            .font(.system(size: 11))
                            .foregroundColor(secondaryColor)
                    }
                }

                // Top category highlight
                if !report.topCategory.isEmpty && report.topCategory != "None" {
                    Divider()
                        .background(secondaryColor.opacity(0.3))
                    HStack {
                        Image(systemName: iconForCategory(report.topCategory))
                            .font(.system(size: 12))
                            .foregroundColor(secondaryColor)
                        Text("Top: \(report.topCategory)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(textColor)
                        if let top = report.categoryBreakdown.first {
                            Text("(\(formatCurrency(top.amount)))")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(secondaryColor)
                        }
                    }
                }
            }
        }
    }

    private func categoryRow(_ cat: MonthlyReport.CategorySpending) -> some View {
        HStack {
            Image(systemName: cat.icon)
                .font(.system(size: 11))
                .foregroundColor(secondaryColor)
                .frame(width: 16)

            Text(cat.category)
                .font(.system(size: 12))
                .foregroundColor(textColor)

            Spacer()

            Text(formatCurrency(cat.amount))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(secondaryColor)

            // Mini progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "2a2a2e"))
                        .frame(width: 50, height: 4)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(expenseColor)
                        .frame(width: 50 * CGFloat(cat.percentage) / 100, height: 4)
                }
            }
            .frame(width: 50, height: 4)
        }
    }

    // MARK: - Budget Alert Content

    private var budgetAlertContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let alert = message.budgetAlert {
                HStack(spacing: 6) {
                    Text(alert.type.emoji)
                        .font(.system(size: 20))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(alert.headline)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(alertColor(for: alert))
                        Text("\(formatCurrency(alert.spent)) of \(formatCurrency(alert.limit))")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(textColor)
                    }
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "2a2a2e"))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(alertColor(for: alert))
                            .frame(width: geo.size.width * CGFloat(min(alert.percentage, 100)) / 100, height: 8)
                    }
                }
                .frame(height: 8)

                Text("\(alert.percentage)% used")
                    .font(.system(size: 11))
                    .foregroundColor(secondaryColor)
            }
        }
    }

    private func alertColor(for alert: BudgetAlert) -> Color {
        switch alert.type {
        case .approaching80, .at80:
            return warningColor
        case .approaching100, .at100, .overBudget:
            return expenseColor
        }
    }

    // MARK: - Recurring Detection Content

    private var recurringDetectionContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("🔁")
                    .font(.system(size: 18))
                Text("Pattern detected")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(textColor)
            }

            if let detection = message.recurringDetection {
                Text(detection.detectionText)
                    .font(.system(size: 13))
                    .foregroundColor(textColor)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    Text("Based on \(detection.sampleCount) transactions")
                        .font(.system(size: 11))
                        .foregroundColor(secondaryColor)
                }
            }
        }
    }

    // MARK: - Weekly Summary Content

    private var weeklySummaryContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("📊")
                    .font(.system(size: 16))
                Text("Weekly Summary")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(textColor)
            }

            Divider()
                .background(secondaryColor.opacity(0.3))

            if let total = message.weeklyTotal {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Spent")
                            .font(.system(size: 11))
                            .foregroundColor(secondaryColor)
                        Text(formatCurrency(total))
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundColor(expenseColor)
                    }
                    Spacer()
                    if let income = message.weeklyIncome, income > 0 {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Income")
                                .font(.system(size: 11))
                                .foregroundColor(secondaryColor)
                            Text(formatCurrency(income))
                                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                                .foregroundColor(incomeColor)
                        }
                    }
                }
            }

            // Budget progress if present
            if let progress = message.budgetProgress {
                Divider()
                    .background(secondaryColor.opacity(0.3))

                HStack {
                    Text("Budget")
                        .font(.system(size: 11))
                        .foregroundColor(secondaryColor)
                    Spacer()
                    Text("\(progress.percentageInt)%")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: progress.progressColor))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "2a2a2e"))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: progress.progressColor))
                            .frame(width: geo.size.width * CGFloat(min(progress.percentage, 1.0)), height: 6)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("Spent: \(formatCurrency(progress.spent))")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(secondaryColor)
                    Spacer()
                    Text("Left: \(formatCurrency(progress.remaining))")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(secondaryColor)
                }
            }
        }
    }

    // MARK: - Transaction Content

    private func transactionContent(_ tx: Transaction) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: tx.type == .income ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                    .foregroundColor(tx.type == .income ? incomeColor : expenseColor)
                    .font(.system(size: 18))

                Text(formatCurrency(tx.amount))
                    .font(.system(size: 22, weight: .semibold, design: .monospaced))
                    .foregroundColor(tx.type == .income ? incomeColor : textColor)
            }

            HStack(spacing: 4) {
                if !tx.category.isEmpty {
                    Text(tx.category)
                        .font(.system(size: 14))
                        .foregroundColor(secondaryColor)
                }

                if tx.isRecurring {
                    Text("🔁")
                        .font(.system(size: 12))
                }
            }

            Text(dateFormatter.string(from: tx.date))
                .font(.system(size: 12))
                .foregroundColor(secondaryColor)

            if message.weeklyTotal != nil {
                Divider()
                    .background(secondaryColor.opacity(0.3))
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("This week")
                            .font(.system(size: 11))
                            .foregroundColor(secondaryColor)
                        if let income = message.weeklyIncome, income > 0 {
                            Text("In: \(formatCurrency(income))")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(incomeColor)
                        }
                    }
                    Spacer()
                    if let total = message.weeklyTotal, total > 0 {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Spent")
                                .font(.system(size: 11))
                                .foregroundColor(secondaryColor)
                            Text(formatCurrency(total))
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(expenseColor)
                        }
                    }
                }
            }

            // Budget progress if set
            if let progress = message.budgetProgress {
                Divider()
                    .background(secondaryColor.opacity(0.3))
                HStack {
                    Text("Budget: \(progress.percentageInt)%")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: progress.progressColor))
                    Spacer()
                    Text("\(formatCurrency(progress.remaining)) left")
                        .font(.system(size: 11))
                        .foregroundColor(secondaryColor)
                }
            }
        }
    }

    // MARK: - Text Content

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            if isErrorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(warningColor)

                    Text("Note")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(warningColor)
                }
            }

            Text(message.text)
                .font(.system(size: 14))
                .foregroundColor(textColor)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Helpers

    private var cardForMessage: Color {
        switch message.messageType {
        case .budgetAlert:
            let alertType = message.budgetAlert?.type
            if alertType == .at100 || alertType == .overBudget {
                return Color(hex: "2a1a0a")
            }
            if alertType == .at80 || alertType == .approaching80 || alertType == .approaching100 {
                return Color(hex: "2a1f0a")
            }
            return cardColor
        default:
            return isErrorMessage ? errorCardColor : cardColor
        }
    }

    private var borderForMessage: Color {
        switch message.messageType {
        case .budgetAlert:
            let alertType = message.budgetAlert?.type
            if alertType == .at100 || alertType == .overBudget {
                return expenseColor.opacity(0.4)
            }
            if alertType == .at80 || alertType == .approaching80 || alertType == .approaching100 {
                return warningColor.opacity(0.4)
            }
            return .clear
        default:
            return isErrorMessage ? warningColor.opacity(0.3) : .clear
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }

    private func iconForCategory(_ category: String) -> String {
        let icons: [String: String] = [
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
        return icons[category] ?? "circle.fill"
    }
}
