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
                case .recurringBillsList:
                    recurringBillsListContent
                case .weeklySummary:
                    weeklySummaryContent
                case .yearlySummary:
                    yearlySummaryContent
                case .exportReady:
                    exportReadyContent
                case .aiInsight:
                    aiInsightContent
                case .sharedWalletSummary:
                    sharedWalletContent
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

                // Category breakdown with pie chart
                if !report.categoryBreakdown.isEmpty {
                    Divider()
                        .background(secondaryColor.opacity(0.3))

                    // Compact pie chart + legend row
                    HStack(spacing: 12) {
                        // Pie chart
                        MiniPieChart(categories: Array(report.categoryBreakdown.prefix(4)))
                            .frame(width: 60, height: 60)

                        // Legend
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(report.categoryBreakdown.prefix(4)) { cat in
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(pieColorForCategory(cat.category))
                                        .frame(width: 8, height: 8)
                                    Text(cat.category)
                                        .font(.system(size: 11))
                                        .foregroundColor(textColor)
                                        .lineLimit(1)
                                    Spacer()
                                    Text("\(Int(cat.percentage))%")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(secondaryColor)
                                }
                            }
                        }
                    }

                    // Full category list
                    Text("By category")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(secondaryColor)
                        .padding(.top, 4)

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

    // MARK: - Recurring Bills List Content

    private var recurringBillsListContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text("📅")
                    .font(.system(size: 16))
                Text("Upcoming Bills")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(textColor)
            }

            if let bills = message.recurringBills, !bills.isEmpty {
                Divider()
                    .background(secondaryColor.opacity(0.3))

                ForEach(bills.prefix(5)) { bill in
                    billRow(bill)
                }

                if bills.count > 5 {
                    Text("+ \(bills.count - 5) more")
                        .font(.system(size: 11))
                        .foregroundColor(secondaryColor)
                        .padding(.top, 2)
                }
            } else {
                Text("No bills due in the next 7 days.")
                    .font(.system(size: 13))
                    .foregroundColor(secondaryColor)
            }
        }
    }

    private func billRow(_ bill: RecurringExpense) -> some View {
        HStack(spacing: 8) {
            // Due date indicator
            ZStack {
                Circle()
                    .fill(dueColor(for: bill).opacity(0.2))
                    .frame(width: 32, height: 32)

                if bill.daysUntilNext == 0 {
                    Text("Today")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(dueColor(for: bill))
                } else if bill.daysUntilNext == 1 {
                    Text("Tmrw")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(dueColor(for: bill))
                } else {
                    Text("\(bill.daysUntilNext)d")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(dueColor(for: bill))
                }
            }
            .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(bill.label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(textColor)
                    .lineLimit(1)

                Text(bill.frequencyDescription)
                    .font(.system(size: 10))
                    .foregroundColor(secondaryColor)
            }

            Spacer()

            Text(CurrencyService.shared.formatCurrency(bill.estimatedAmount))
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(dueColor(for: bill))
        }
    }

    private func dueColor(for bill: RecurringExpense) -> Color {
        if bill.daysUntilNext == 0 {
            return expenseColor
        } else if bill.daysUntilNext <= 2 {
            return warningColor
        } else {
            return incomeGreen
        }
    }

    private var incomeGreen: Color { Color(hex: "34c759") }

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

    // MARK: - Yearly Summary Content

    private var yearlySummaryContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let summary = message.yearlySummaryData {
                HStack(spacing: 6) {
                    Text("📅")
                        .font(.system(size: 16))
                    Text("\(summary.year) Summary")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(textColor)
                }

                Divider()
                    .background(secondaryColor.opacity(0.3))

                // Totals
                VStack(spacing: 8) {
                    HStack {
                        Text("Total Spent")
                            .font(.system(size: 13))
                            .foregroundColor(secondaryColor)
                        Spacer()
                        Text(formatCurrency(summary.totalSpent))
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundColor(expenseColor)
                    }

                    HStack {
                        Text("Total Income")
                            .font(.system(size: 13))
                            .foregroundColor(secondaryColor)
                        Spacer()
                        Text(formatCurrency(summary.totalIncome))
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundColor(incomeColor)
                    }

                    HStack {
                        Text("Net")
                            .font(.system(size: 13))
                            .foregroundColor(secondaryColor)
                        Spacer()
                        let sign = summary.net >= 0 ? "+" : ""
                        Text("\(sign)\(formatCurrency(abs(summary.net)))")
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundColor(summary.net >= 0 ? incomeColor : expenseColor)
                    }
                }

                // Biggest month
                if let biggest = summary.biggestMonth {
                    Divider()
                        .background(secondaryColor.opacity(0.3))
                    HStack {
                        Text("🏆 Biggest month")
                            .font(.system(size: 12))
                            .foregroundColor(textColor)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(biggest.monthName)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(accentColor)
                            Text(formatCurrency(biggest.total))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(secondaryColor)
                        }
                    }
                }

                // Top categories
                if !summary.topCategories.isEmpty {
                    Divider()
                        .background(secondaryColor.opacity(0.3))

                    Text("Top categories")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(secondaryColor)

                    ForEach(summary.topCategories.prefix(3), id: \.category) { cat in
                        HStack {
                            Text(cat.category)
                                .font(.system(size: 12))
                                .foregroundColor(textColor)
                            Spacer()
                            Text(formatCurrency(cat.amount))
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(secondaryColor)
                        }
                    }
                }

                // Transaction count
                HStack {
                    Text("\(summary.transactionCount) transactions")
                        .font(.system(size: 11))
                        .foregroundColor(secondaryColor)
                }
            }
        }
    }

    // MARK: - Export Ready Content

    private var exportReadyContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("📄")
                    .font(.system(size: 16))
                Text("Export Ready")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(textColor)
            }

            Divider()
                .background(secondaryColor.opacity(0.3))

            Text(message.text)
                .font(.system(size: 13))
                .foregroundColor(textColor)
                .fixedSize(horizontal: false, vertical: true)

            if message.exportFileURL != nil {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 12))
                    Text("Tap to share or save")
                        .font(.system(size: 12))
                }
                .foregroundColor(Color(hex: "5ac8fa"))
                .padding(.top, 4)
            }
        }
    }

    // MARK: - AI Insight Content

    private var aiInsightContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let insight = message.aiInsight {
                HStack(spacing: 8) {
                    Text(insight.emoji)
                        .font(.system(size: 22))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("AI Insight")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(secondaryColor)
                            .textCase(.uppercase)
                        Text(insight.headline)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(textColor)
                    }
                }

                Divider()
                    .background(secondaryColor.opacity(0.3))

                Text(insight.body)
                    .font(.system(size: 13))
                    .foregroundColor(textColor)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 11))
                        .foregroundColor(accentColor)
                    Text("Powered by Wade AI")
                        .font(.system(size: 10))
                        .foregroundColor(secondaryColor)
                }
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Shared Wallet Content

    private var sharedWalletContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text("👥")
                    .font(.system(size: 18))
                Text("Shared Wallet")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(textColor)
            }

            Divider()
                .background(secondaryColor.opacity(0.3))

            if let summary = message.sharedWalletData {
                // Total spent
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("This month")
                            .font(.system(size: 11))
                            .foregroundColor(secondaryColor)
                        Text(formatCurrency(summary.totalSpent))
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(textColor)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(summary.memberCount) members")
                            .font(.system(size: 11))
                            .foregroundColor(secondaryColor)
                        if let budget = summary.sharedBudget {
                            let pct = summary.totalSpent / budget.limit
                            Text("\(Int(pct * 100))% of budget")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(pct >= 1.0 ? expenseColor : (pct >= 0.8 ? warningColor : incomeColor))
                        }
                    }
                }

                // Shared budget progress
                if let budget = summary.sharedBudget {
                    Divider()
                        .background(secondaryColor.opacity(0.3))

                    let pct = min(summary.totalSpent / budget.limit, 1.5)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "2a2a2e"))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(pct >= 1.0 ? expenseColor : (pct >= 0.8 ? warningColor : incomeColor))
                                .frame(width: geo.size.width * CGFloat(min(pct, 1.0)), height: 6)
                        }
                    }
                    .frame(height: 6)

                    HStack {
                        Text("Spent: \(formatCurrency(summary.totalSpent))")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(secondaryColor)
                        Spacer()
                        Text("Budget: \(formatCurrency(budget.limit))")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(secondaryColor)
                    }
                }

                // Top spender
                if let (name, amount) = summary.topSpender {
                    Divider()
                        .background(secondaryColor.opacity(0.3))
                    HStack {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 11))
                            .foregroundColor(accentColor)
                        Text("Top spender: \(name)")
                            .font(.system(size: 12))
                            .foregroundColor(textColor)
                        Spacer()
                        Text(formatCurrency(amount))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(secondaryColor)
                    }
                }

                // Category breakdown
                if !summary.categoryBreakdown.isEmpty {
                    Divider()
                        .background(secondaryColor.opacity(0.3))

                    Text("By category")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(secondaryColor)

                    ForEach(Array(summary.categoryBreakdown.sorted { $0.value > $1.value }.prefix(4)), id: \.key) { cat, amount in
                        HStack {
                            Text(cat)
                                .font(.system(size: 12))
                                .foregroundColor(textColor)
                            Spacer()
                            Text(formatCurrency(amount))
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(secondaryColor)
                        }
                    }
                }

                // Who owes whom
                if !summary.owesList.isEmpty {
                    Divider()
                        .background(secondaryColor.opacity(0.3))

                    Text("Settling up")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(secondaryColor)

                    ForEach(Array(summary.owesList.prefix(3).enumerated()), id: \.offset) { _, owe in
                        HStack {
                            Text("\(owe.from) owes \(owe.to)")
                                .font(.system(size: 12))
                                .foregroundColor(textColor)
                            Spacer()
                            Text(formatCurrency(owe.amount))
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(expenseColor)
                        }
                    }
                }
            } else {
                Text(message.text)
                    .font(.system(size: 13))
                    .foregroundColor(textColor)
                    .fixedSize(horizontal: false, vertical: true)
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
        CurrencyService.shared.formatCurrency(amount)
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

    private func pieColorForCategory(_ category: String) -> Color {
        let colors: [String: Color] = [
            "Food": Color(hex: "ff453a"),
            "Groceries": Color(hex: "30d158"),
            "Transport": Color(hex: "0a84ff"),
            "Shopping": Color(hex: "ff9f0a"),
            "Entertainment": Color(hex: "bf5af2"),
            "Health": Color(hex: "64d2ff"),
            "Bills": Color(hex: "ffd60a"),
            "Travel": Color(hex: "ff375f"),
            "Education": Color(hex: "ac8e68"),
            "Salary": Color(hex: "34c759"),
            "Other": Color(hex: "8e8e93")
        ]
        return colors[category] ?? Color(hex: "8e8e93")
    }
}

// MARK: - Mini Pie Chart for Monthly Report

struct MiniPieChart: View {
    let categories: [MonthlyReport.CategorySpending]

    var body: some View {
        GeometryReader { geo in
            let radius = min(geo.size.width, geo.size.height) / 2
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                ForEach(Array(sliceData.enumerated()), id: \.offset) { index, slice in
                    ChartPieSlice(startAngle: slice.startAngle, endAngle: slice.endAngle)
                        .fill(paletteColor(for: index))
                }

                // Donut hole
                Circle()
                    .fill(Color(hex: "1c1c1e"))
                    .frame(width: radius * 0.5, height: radius * 0.5)
            }
        }
    }

    private var sliceData: [(startAngle: Angle, endAngle: Angle)] {
        var slices: [(startAngle: Angle, endAngle: Angle)] = []
        var currentAngle: Double = -90

        for cat in categories {
            let degrees = cat.percentage / 100 * 360
            let startAngle = Angle(degrees: currentAngle)
            let endAngle = Angle(degrees: currentAngle + degrees)
            slices.append((startAngle, endAngle))
            currentAngle += degrees
        }

        return slices
    }

    private func paletteColor(for index: Int) -> Color {
        let palette: [Color] = [
            Color(hex: "ff453a"),
            Color(hex: "0a84ff"),
            Color(hex: "30d158"),
            Color(hex: "ff9f0a"),
            Color(hex: "bf5af2"),
            Color(hex: "64d2ff"),
            Color(hex: "ffd60a"),
            Color(hex: "ff375f")
        ]
        return palette[index % palette.count]
    }
}

struct ChartPieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()

        return path
    }
}
