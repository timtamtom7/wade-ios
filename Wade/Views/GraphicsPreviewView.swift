import SwiftUI

/// Preview collector for all custom graphics
/// This view showcases the complete design system
struct GraphicsPreviewView: View {
    @State private var selectedTab: Int = 0

    private let backgroundColor = Color(hex: "0d0d0e")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Tab bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        tabButton("Bubbles", tag: 0)
                        tabButton("Icons", tag: 1)
                        tabButton("Summary", tag: 2)
                        tabButton("Messages", tag: 3)
                        tabButton("Reports", tag: 4)
                        tabButton("Budget", tag: 5)
                        tabButton("Wallet", tag: 6)
                        tabButton("Bills", tag: 7)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
                .background(Color(hex: "111112"))

                TabView(selection: $selectedTab) {
                    ChatBubbleCompositionView()
                        .tag(0)

                    MoneyIconSetView()
                        .tag(1)

                    WeeklySummaryCardPreviewView()
                        .tag(2)

                    TextMessageUIMockupView()
                        .tag(3)

                    MonthlyReportPreviewView()
                        .tag(4)

                    BudgetProgressPreviewView()
                        .tag(5)

                    SharedWalletPreviewView()
                        .tag(6)

                    BillsListPreviewView()
                        .tag(7)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .preferredColorScheme(.dark)
    }

    private func tabButton(_ title: String, tag: Int) -> some View {
        Button {
            withAnimation {
                selectedTab = tag
            }
        } label: {
            Text(title)
                .font(.system(size: 14, weight: selectedTab == tag ? .semibold : .regular))
                .foregroundColor(selectedTab == tag ? DesignSystem.Colors.accentGreen : DesignSystem.Colors.tabInactive)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedTab == tag ? DesignSystem.Colors.accentGreen.opacity(0.15) : Color.clear)
                )
        }
        .accessibilityLabel(title)
    }
}

// MARK: - Real Content Examples

struct RealConversationExamples {
    static let examples: [(user: String, wade: String, category: String, amount: Double)] = [
        ("£12.50 lunch", "✓ Logged: £12.50\nFood · Mar 24\nThis week: £127.40", "Food", 12.50),
        ("£40 groceries", "✓ Logged: £40.00\nGroceries · Mar 24\nThis week: £167.40", "Groceries", 40.00),
        ("£8.45 coffee", "✓ Logged: £8.45\nFood · Mar 24\nThis week: £175.85", "Food", 8.45),
        ("£25 uber to airport", "✓ Logged: £25.00\nTransport · Mar 23\nThis week: £202.85", "Transport", 25.00),
        ("£15 netflix", "✓ Logged: £15.00\nEntertainment · Mar 23\nThis week: £217.85", "Entertainment", 15.00),
        ("£89 new shoes", "✓ Logged: £89.00\nShopping · Mar 22\nThis week: £306.85", "Shopping", 89.00),
        ("salary", "✓ Income logged: £4,200.00\nSalary · Mar 22", "Salary", 4200.00),
        ("£6.50 coffee", "✓ Logged: £6.50\nFood · Mar 21\nThis week: £337.35", "Food", 6.50),
        ("£120 dentist", "✓ Logged: £120.00\nHealth · Mar 21\nThis week: £457.35", "Health", 120.00),
        ("£45 restaurant dinner", "✓ Logged: £45.00\nFood · Mar 20\nThis week: £502.35", "Food", 45.00),
    ]

    static let weeklySummaryExample = """
    📊 Weekly Summary

    Spent: £127.40
    Income: £4,200.00
    Net: +£4,072.60 📈

    Top categories:
    • Food & Drink: £67.40
    • Groceries: £40.00
    • Transport: £20.00

    Tap to see more →
    """

    static let onboardingCopy = [
        (
            headline: "Money, without\nthe effort",
            body: "Wade keeps track of your spending so you don't have to open an app, categorize expenses, or touch a spreadsheet."
        ),
        (
            headline: "Just text it",
            body: "Send \"£12.50 lunch\" or \"£40 groceries\" and Wade understands. Amount, category, done."
        ),
        (
            headline: "Every Friday",
            body: "At 6pm, Wade texts you a summary. See the week at a glance — no digging through apps."
        ),
        (
            headline: "Start tracking",
            body: "Enable notifications so Wade can send your weekly summary every Friday at 6pm."
        )
    ]

    static let greetingMessages = [
        "Hey! I'm Wade — send me your expenses like \"£12.50 lunch\" or \"£40 groceries\" and I'll keep track. Type something to get started!",
        "Ready when you are 💸 Send your first expense to get started.",
        "Wade here. Just text me what you spend — \"£15 lunch\", \"£40 groceries\", anything. I'll handle the rest."
    ]

    static let parseFailureMessages = [
        "Hmm, I didn't catch that. Try formats like \"£12.50 lunch\" or \"£40 groceries\".",
        "Couldn't find an amount in that. Try something like \"£25 food\" or \"£10 coffee\".",
        "I didn't understand that. Send an amount and what it was for, like \"£15 dinner\"."
    ]
}

// MARK: - App Store Copy Snippets

struct AppStoreCopy {
    static let tagline = "Your money, over text."

    static let shortPitch = "The budget tracker you never have to open."

    static let longPitch = """
    Most budget apps feel like work. You have to open them, categorize every expense, remember what you spent.

    Wade removes all that friction.

    You already know what you spent — you just text it. \"£12.50 lunch\", \"£40 groceries\", \"salary\" — Wade parses it, logs it, and sends you a weekly summary every Friday.

    No forms. No menus. No spreadsheets.

    It's the budget tracker for people who hate budget trackers.
    """

    static let features = [
        "Text your expenses — no app to open",
        "Smart parsing understands natural language",
        "Weekly summaries every Friday at 6pm",
        "Category insights and spending patterns",
        "Monthly reports (Overview tier)",
        "Export to CSV and PDF (Overview tier)",
        "Multiple currencies (Overview tier)",
        "Private — all data stays on your device"
    ]

    static let keywords = [
        "expense tracker",
        "budget app",
        "spending tracker",
        "money tracker",
        "finance app",
        "weekly summary",
        "text expenses",
        "simple budget",
        "personal finance",
        "money management"
    ]
}

// MARK: - R2: Monthly Report Preview

struct MonthlyReportPreviewView: View {
    private let backgroundColor = Color(hex: "0d0d0e")
    private let cardColor = Color(hex: "1c1c1e")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")
    private let expenseRed = Color(hex: "ff453a")
    private let incomeGreen = Color(hex: "34c759")
    private let accentYellow = Color(hex: "ffd60a")

    private let sampleReport = MonthlyReport(
        id: UUID(),
        year: 2026,
        month: 3,
        totalSpent: 1274.50,
        totalIncome: 4200.00,
        net: 2925.50,
        categoryBreakdown: [
            MonthlyReport.CategorySpending(category: "Food", amount: 420.30, percentage: 33, icon: "fork.knife"),
            MonthlyReport.CategorySpending(category: "Transport", amount: 310.00, percentage: 24, icon: "car.fill"),
            MonthlyReport.CategorySpending(category: "Groceries", amount: 240.00, percentage: 19, icon: "cart.fill"),
            MonthlyReport.CategorySpending(category: "Shopping", amount: 180.20, percentage: 14, icon: "bag.fill"),
            MonthlyReport.CategorySpending(category: "Entertainment", amount: 124.00, percentage: 10, icon: "gamecontroller.fill")
        ],
        topCategory: "Food",
        vsLastMonthPercent: -8.5,
        vsLastMonthAmount: -118.20,
        recurringTotal: 89.99,
        currencyCode: "USD"
    )

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Text("Monthly Report Card")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(textColor)
                        .padding(.top, 20)

                    // Full monthly report card
                    previewSection(title: "Monthly Report Card (In-chat)") {
                        WadeResponseCard(
                            message: Message.monthlyReportMessage(sampleReport)
                        )
                        .padding(.horizontal, 16)
                    }

                    // Category pie chart
                    previewSection(title: "Category Pie Chart") {
                        VStack(spacing: 16) {
                            Text("March 2026 Spending")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(textColor)

                            PieChartView(categories: sampleReport.categoryBreakdown)
                                .frame(width: 180, height: 180)

                            // Legend
                            VStack(spacing: 6) {
                                ForEach(sampleReport.categoryBreakdown.prefix(5)) { cat in
                                    HStack {
                                        Circle()
                                            .fill(colorForCategory(cat.category))
                                            .frame(width: 10, height: 10)
                                        Text(cat.category)
                                            .font(.system(size: 13))
                                            .foregroundColor(textColor)
                                        Spacer()
                                        Text("\(Int(cat.percentage))%")
                                            .font(.system(size: 13, design: .monospaced))
                                            .foregroundColor(secondaryColor)
                                        Text(formatCurrency(cat.amount))
                                            .font(.system(size: 13, design: .monospaced))
                                            .foregroundColor(secondaryColor)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(cardColor)
                        )
                        .padding(.horizontal, 16)
                    }

                    // vs last month comparison
                    previewSection(title: "Month-over-Month") {
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("March 2026")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(textColor)
                                    Text(formatCurrency(sampleReport.totalSpent))
                                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                                        .foregroundColor(expenseRed)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("vs Feb")
                                        .font(.system(size: 11))
                                        .foregroundColor(secondaryColor)
                                    HStack(spacing: 2) {
                                        Text("▼")
                                            .font(.system(size: 12))
                                        Text("8.5%")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundColor(incomeGreen)
                                    Text("~$118 less")
                                        .font(.system(size: 11))
                                        .foregroundColor(secondaryColor)
                                }
                            }

                            // Bar comparison
                            HStack(spacing: 8) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Feb")
                                        .font(.system(size: 10))
                                        .foregroundColor(secondaryColor)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(expenseRed.opacity(0.6))
                                        .frame(width: 120, height: 16)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Mar")
                                        .font(.system(size: 10))
                                        .foregroundColor(secondaryColor)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(expenseRed)
                                        .frame(width: 110, height: 16)
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(cardColor)
                        )
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func previewSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(secondaryColor)
                .padding(.horizontal, 16)

            content()
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "111112"))
                )
                .padding(.horizontal, 16)
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }

    private func colorForCategory(_ category: String) -> Color {
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
            "Other": Color(hex: "8e8e93")
        ]
        return colors[category] ?? Color(hex: "8e8e93")
    }
}

// MARK: - Pie Chart View

struct PieChartView: View {
    let categories: [MonthlyReport.CategorySpending]

    private let foodColor = Color(hex: "ff453a")
    private let transportColor = Color(hex: "0a84ff")
    private let groceriesColor = Color(hex: "30d158")
    private let shoppingColor = Color(hex: "ff9f0a")
    private let entertainmentColor = Color(hex: "bf5af2")

    var body: some View {
        GeometryReader { geo in
            let radius = min(geo.size.width, geo.size.height) / 2
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                ForEach(Array(sliceData.enumerated()), id: \.offset) { index, slice in
                    PieSlice(
                        startAngle: slice.startAngle,
                        endAngle: slice.endAngle
                    )
                    .fill(colorForIndex(index))
                }

                // Donut hole
                Circle()
                    .fill(Color(hex: "1c1c1e"))
                    .frame(width: radius, height: radius)

                // Center label
                VStack(spacing: 2) {
                    Text("Total")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "8a8a8a"))
                    Text("\(categories.count)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "f5f5f7"))
                    Text("categories")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "8a8a8a"))
                }
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

    private func colorForIndex(_ index: Int) -> Color {
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

struct PieSlice: Shape {
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

// MARK: - R2: Budget Progress Preview

struct BudgetProgressPreviewView: View {
    private let backgroundColor = Color(hex: "0d0d0e")
    private let cardColor = Color(hex: "1c1c1e")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")
    private let incomeGreen = Color(hex: "34c759")
    private let warningOrange = Color(hex: "ff9f0a")
    private let expenseRed = Color(hex: "ff453a")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Text("Budget Progress UI")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(textColor)
                        .padding(.top, 20)

                    // 80% budget alert
                    previewSection(title: "80% Budget Alert") {
                        WadeResponseCard(
                            message: Message.budgetAlertMessage(
                                BudgetAlert(type: .at80, spent: 1600, limit: 2000, percentage: 80)
                            )
                        )
                        .padding(.horizontal, 16)
                    }

                    // 100% budget alert
                    previewSection(title: "100% Budget Reached") {
                        WadeResponseCard(
                            message: Message.budgetAlertMessage(
                                BudgetAlert(type: .at100, spent: 2000, limit: 2000, percentage: 100)
                            )
                        )
                        .padding(.horizontal, 16)
                    }

                    // Over budget
                    previewSection(title: "Over Budget") {
                        WadeResponseCard(
                            message: Message.budgetAlertMessage(
                                BudgetAlert(type: .overBudget, spent: 2340, limit: 2000, percentage: 117)
                            )
                        )
                        .padding(.horizontal, 16)
                    }

                    // Budget progress bar component
                    previewSection(title: "Budget Progress Bar") {
                        VStack(spacing: 16) {
                            budgetRow(label: "80%", spent: 1600, limit: 2000, percentage: 0.8, color: warningOrange)
                            budgetRow(label: "100%", spent: 2000, limit: 2000, percentage: 1.0, color: expenseRed)
                            budgetRow(label: "Over", spent: 2400, limit: 2000, percentage: 1.2, color: expenseRed)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(cardColor)
                        )
                        .padding(.horizontal, 16)
                    }

                    // Set budget card
                    previewSection(title: "Set Budget Prompt") {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "target")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(hex: "5ac8fa"))
                                Text("Set a monthly budget")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(textColor)
                            }

                            Text("Say things like \"budget of £500\" or \"set limit to $2000\"")
                                .font(.system(size: 13))
                                .foregroundColor(secondaryColor)

                            // Example
                            HStack {
                                Text("\"budget of £2000\"")
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(incomeGreen)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(incomeGreen.opacity(0.15))
                                    )
                                Spacer()
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(cardColor)
                        )
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func previewSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(secondaryColor)
                .padding(.horizontal, 16)

            content()
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "111112"))
                )
                .padding(.horizontal, 16)
        }
    }

    private func budgetRow(label: String, spent: Double, limit: Double, percentage: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
                Spacer()
                Text("\(formatCurrency(spent)) / \(formatCurrency(limit))")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(secondaryColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "2a2a2e"))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(min(percentage, 1.0)), height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }
}

// MARK: - R5: Shared Wallet UI Preview

struct SharedWalletPreviewView: View {
    private let backgroundColor = Color(hex: "0d0d0e")
    private let cardColor = Color(hex: "1c1c1e")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")
    private let expenseRed = Color(hex: "ff453a")
    private let incomeGreen = Color(hex: "34c759")
    private let warningOrange = Color(hex: "ff9f0a")
    private let accentYellow = Color(hex: "ffd60a")

    private let sampleMembers = [
        WalletMember(name: "Alex", colorHex: "0a84ff"),
        WalletMember(name: "Sam", colorHex: "ff9f0a")
    ]

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Text("Shared Wallet UI")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(textColor)
                        .padding(.top, 20)

                    // Shared wallet in-chat card
                    previewSection(title: "Shared Wallet Card (In-chat)") {
                        sharedWalletCardPreview
                            .padding(.horizontal, 16)
                    }

                    // Member avatars
                    previewSection(title: "Member Avatars") {
                        HStack(spacing: 16) {
                            ForEach(sampleMembers) { member in
                                VStack(spacing: 6) {
                                    Circle()
                                        .fill(Color(hex: member.colorHex))
                                        .frame(width: 56, height: 56)
                                        .overlay(
                                            Text(String(member.name.prefix(1)))
                                                .font(.system(size: 22, weight: .bold))
                                                .foregroundColor(.white)
                                        )

                                    Text(member.name)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(textColor)

                                    Text("Paid £340")
                                        .font(.system(size: 11))
                                        .foregroundColor(secondaryColor)
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(cardColor)
                        )
                        .padding(.horizontal, 16)
                    }

                    // Budget progress
                    previewSection(title: "Shared Budget Progress") {
                        VStack(spacing: 12) {
                            HStack {
                                Text("£1,847")
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                                    .foregroundColor(textColor)
                                Text("/ £2,500")
                                    .font(.system(size: 16, design: .monospaced))
                                    .foregroundColor(secondaryColor)
                                Spacer()
                                Text("74%")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(warningOrange)
                            }

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(hex: "2a2a2e"))
                                        .frame(height: 10)
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(warningOrange)
                                        .frame(width: geo.size.width * 0.74, height: 10)
                                }
                            }
                            .frame(height: 10)

                            HStack {
                                Text("£653 left")
                                    .font(.system(size: 12))
                                    .foregroundColor(secondaryColor)
                                Spacer()
                                Text("Groceries: £340 · Rent: £800")
                                    .font(.system(size: 11))
                                    .foregroundColor(secondaryColor)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(cardColor)
                        )
                        .padding(.horizontal, 16)
                    }

                    // Settling up
                    previewSection(title: "Settling Up") {
                        VStack(spacing: 10) {
                            HStack {
                                Circle()
                                    .fill(Color(hex: "ff9f0a"))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Text("S")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                Text("Sam owes Alex")
                                    .font(.system(size: 14))
                                    .foregroundColor(textColor)
                                Spacer()
                                Text("£127.50")
                                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                                    .foregroundColor(expenseRed)
                            }

                            Text("Based on 8 shared expenses this month")
                                .font(.system(size: 11))
                                .foregroundColor(secondaryColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(cardColor)
                        )
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var sharedWalletCardPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text("👥")
                    .font(.system(size: 18))
                Text("Shared Wallet")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(textColor)
                Spacer()
                Text("This month")
                    .font(.system(size: 11))
                    .foregroundColor(secondaryColor)
            }

            Divider()
                .background(secondaryColor.opacity(0.3))

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("£1,847.00")
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(textColor)
                    Text("2 members")
                        .font(.system(size: 11))
                        .foregroundColor(secondaryColor)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("74% of budget")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(warningOrange)
                    Text("£653 left")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(secondaryColor)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "2a2a2e"))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(warningOrange)
                        .frame(width: geo.size.width * 0.74, height: 6)
                }
            }
            .frame(height: 6)

            HStack(spacing: 8) {
                ForEach(sampleMembers) { member in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: member.colorHex))
                            .frame(width: 20, height: 20)
                            .overlay(
                                Text(String(member.name.prefix(1)))
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        Text(member.name)
                            .font(.system(size: 11))
                            .foregroundColor(secondaryColor)
                    }
                }
                Spacer()
                Image(systemName: "crown.fill")
                    .font(.system(size: 10))
                    .foregroundColor(accentYellow)
                Text("Sam spent most")
                    .font(.system(size: 10))
                    .foregroundColor(secondaryColor)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardColor)
        )
    }

    private func previewSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(secondaryColor)
                .padding(.horizontal, 16)

            content()
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "111112"))
                )
                .padding(.horizontal, 16)
        }
    }
}

// MARK: - R3-5: Bills List Visual Preview

struct BillsListPreviewView: View {
    private let backgroundColor = Color(hex: "0d0d0e")
    private let cardColor = Color(hex: "1c1c1e")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")
    private let expenseRed = Color(hex: "ff453a")
    private let incomeGreen = Color(hex: "34c759")
    private let warningOrange = Color(hex: "ff9f0a")

    private let sampleBills = [
        ("Netflix", "Monthly", 15.99, 1),
        ("Spotify", "Monthly", 9.99, 1),
        ("Gym", "Monthly", 49.99, 2),
        ("Internet", "Monthly", 39.99, 5),
        ("Phone", "Monthly", 25.00, 7),
    ]

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Text("Bills List UI")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(textColor)
                        .padding(.top, 20)

                    // Bills list in recurring service preview
                    previewSection(title: "Bills List (In-chat)") {
                        billsCardPreview
                            .padding(.horizontal, 16)
                    }

                    // Monthly total
                    previewSection(title: "Monthly Bills Total") {
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Monthly Bills")
                                        .font(.system(size: 13))
                                        .foregroundColor(secondaryColor)
                                    Text("£140.96")
                                        .font(.system(size: 26, weight: .bold, design: .monospaced))
                                        .foregroundColor(expenseRed)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("5 subscriptions")
                                        .font(.system(size: 12))
                                        .foregroundColor(secondaryColor)
                                    Text("Due this month")
                                        .font(.system(size: 11))
                                        .foregroundColor(warningOrange)
                                }
                            }

                            Divider()
                                .background(secondaryColor.opacity(0.3))

                            // Category breakdown
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    billMiniRow(icon: "🎵", name: "Entertainment", amount: 25.98)
                                    billMiniRow(icon: "💪", name: "Health", amount: 49.99)
                                    billMiniRow(icon: "📱", name: "Utilities", amount: 64.99)
                                }
                                Spacer()
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(cardColor)
                        )
                        .padding(.horizontal, 16)
                    }

                    // Upcoming bills timeline
                    previewSection(title: "Bills Timeline") {
                        VStack(spacing: 0) {
                            ForEach(Array(sampleBills.enumerated()), id: \.offset) { index, bill in
                                HStack(spacing: 12) {
                                    // Timeline dot
                                    VStack(spacing: 0) {
                                        Circle()
                                            .fill(dotColor(days: bill.3))
                                            .frame(width: 10, height: 10)
                                        if index < sampleBills.count - 1 {
                                            Rectangle()
                                                .fill(secondaryColor.opacity(0.3))
                                                .frame(width: 2, height: 40)
                                        }
                                    }

                                    HStack(spacing: 8) {
                                        Text(bill.0)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(textColor)

                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(formatCurrency(bill.2))
                                                .font(.system(size: 13, design: .monospaced))
                                                .foregroundColor(dueColor(days: bill.3))
                                            Text(daysLabel(bill.3))
                                                .font(.system(size: 10))
                                                .foregroundColor(secondaryColor)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(cardColor)
                        )
                        .padding(.horizontal, 16)
                    }

                    // Budget progress for bills
                    previewSection(title: "Bills Budget") {
                        VStack(spacing: 10) {
                            HStack {
                                Text("Bills budget")
                                    .font(.system(size: 13))
                                    .foregroundColor(secondaryColor)
                                Spacer()
                                Text("£200/month")
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(textColor)
                            }

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(hex: "2a2a2e"))
                                        .frame(height: 8)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(incomeGreen)
                                        .frame(width: geo.size.width * 0.70, height: 8)
                                }
                            }
                            .frame(height: 8)

                            HStack {
                                Text("£140.96 spent")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(secondaryColor)
                                Spacer()
                                Text("£59.04 left")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(incomeGreen)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(cardColor)
                        )
                        .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var billsCardPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text("📅")
                    .font(.system(size: 16))
                Text("Upcoming Bills")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(textColor)
                Spacer()
                Text("5 this week")
                    .font(.system(size: 11))
                    .foregroundColor(warningOrange)
            }

            Divider()
                .background(secondaryColor.opacity(0.3))

            ForEach(Array(sampleBills.enumerated()), id: \.offset) { _, bill in
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(dueColor(days: bill.3).opacity(0.2))
                            .frame(width: 32, height: 32)

                        if bill.3 == 1 {
                            Text("Tmrw")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundColor(dueColor(days: bill.3))
                        } else if bill.3 == 0 {
                            Text("Today")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundColor(dueColor(days: bill.3))
                        } else {
                            Text("\(bill.3)d")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(dueColor(days: bill.3))
                        }
                    }
                    .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(bill.0)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(textColor)
                        Text(bill.1)
                            .font(.system(size: 10))
                            .foregroundColor(secondaryColor)
                    }

                    Spacer()

                    Text(formatCurrency(bill.2))
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(dueColor(days: bill.3))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardColor)
        )
    }

    private func billMiniRow(icon: String, name: String, amount: Double) -> some View {
        HStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 12))
            Text(name)
                .font(.system(size: 12))
                .foregroundColor(textColor)
            Spacer()
            Text(formatCurrency(amount))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(secondaryColor)
        }
    }

    private func dueColor(days: Int) -> Color {
        if days == 0 { return expenseRed }
        if days <= 2 { return warningOrange }
        return incomeGreen
    }

    private func dotColor(days: Int) -> Color {
        if days == 0 { return expenseRed }
        if days <= 2 { return warningOrange }
        return incomeGreen
    }

    private func daysLabel(_ days: Int) -> String {
        if days == 0 { return "Due today" }
        if days == 1 { return "Due tomorrow" }
        return "In \(days) days"
    }

    private func previewSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(secondaryColor)
                .padding(.horizontal, 16)

            content()
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "111112"))
                )
                .padding(.horizontal, 16)
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }
}
