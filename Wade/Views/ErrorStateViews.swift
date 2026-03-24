import SwiftUI

// MARK: - Error State Views

struct ErrorStateView: View {
    let type: ErrorStateType
    let retryAction: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    private let backgroundColor = Color(hex: "0d0d0e")
    private let cardColor = Color(hex: "1c1c1e")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")

    init(type: ErrorStateType, retryAction: (() -> Void)? = nil) {
        self.type = type
        self.retryAction = retryAction
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                errorGraphic

                VStack(spacing: 12) {
                    Text(type.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)

                    Text(type.message)
                        .font(.system(size: 15))
                        .foregroundColor(secondaryColor)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 32)
                }

                if let retryAction = retryAction {
                    Button {
                        retryAction()
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14))
                            Text("Try again")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "0d0d0e"))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color(hex: "34c759"))
                        )
                    }
                    .padding(.top, 8)
                }

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var errorGraphic: some View {
        ZStack {
            Circle()
                .fill(type.color.opacity(0.1))
                .frame(width: 120, height: 120)

            Image(systemName: type.icon)
                .font(.system(size: 44))
                .foregroundColor(type.color)
        }
    }
}

enum ErrorStateType {
    case couldntParse
    case storageFull
    case notificationDenied
    case emptyConversation
    case monthlyReportFailed
    case budgetLimitNotSet
    case parseFailureForValidExpense

    var title: String {
        switch self {
        case .couldntParse: return "Couldn't parse that"
        case .storageFull: return "Storage full"
        case .notificationDenied: return "Notifications off"
        case .emptyConversation: return "Nothing here yet"
        case .monthlyReportFailed: return "Report unavailable"
        case .budgetLimitNotSet: return "No budget set"
        case .parseFailureForValidExpense: return "Couldn't read that"
        }
    }

    var message: String {
        switch self {
        case .couldntParse:
            return "I didn't catch the amount. Try formats like \"£12.50 lunch\" or \"$40 groceries\"."
        case .storageFull:
            return "You've hit the free limit of 20 expenses. Upgrade to Track for unlimited tracking."
        case .notificationDenied:
            return "Enable notifications in Settings to get your weekly summary every Friday."
        case .emptyConversation:
            return "Send your first expense to get started. Try something like \"£12.50 lunch\"."
        case .monthlyReportFailed:
            return "Couldn't generate the monthly report. Make sure you have expenses logged for that month."
        case .budgetLimitNotSet:
            return "No budget limit set. Say \"set budget to £500\" or \"budget of $1000\" to get started."
        case .parseFailureForValidExpense:
            return "I had trouble reading that expense. Try a simpler format like \"£15 lunch\" or \"$25 groceries\"."
        }
    }

    var icon: String {
        switch self {
        case .couldntParse: return "exclamationmark.questionmark"
        case .storageFull: return "internaldrive.fill"
        case .notificationDenied: return "bell.slash.fill"
        case .emptyConversation: return "bubble.left.and.bubble.right.fill"
        case .monthlyReportFailed: return "chart.bar.xaxis"
        case .budgetLimitNotSet: return "target"
        case .parseFailureForValidExpense: return "text.badge.xmark"
        }
    }

    var color: Color {
        switch self {
        case .couldntParse: return Color(hex: "ff9f0a")
        case .storageFull: return Color(hex: "ff453a")
        case .notificationDenied: return Color(hex: "8a8a8a")
        case .emptyConversation: return Color(hex: "34c759")
        case .monthlyReportFailed: return Color(hex: "ff9f0a")
        case .budgetLimitNotSet: return Color(hex: "5ac8fa")
        case .parseFailureForValidExpense: return Color(hex: "ff9f0a")
        }
    }
}

// MARK: - Empty State for Conversation

struct EmptyConversationView: View {
    let onSendExample: (String) -> Void

    private let backgroundColor = Color(hex: "0d0d0e")
    private let cardColor = Color(hex: "1c1c1e")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")
    private let accentGreen = Color(hex: "34c759")

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Wade avatar
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "1a3a2a"), Color(hex: "0d0d0e")],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 100, height: 100)

                Text("W")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(accentGreen)
            }

            VStack(spacing: 12) {
                Text("Your conversation with Wade")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(textColor)

                Text("Send your first expense to get started")
                    .font(.system(size: 15))
                    .foregroundColor(secondaryColor)
            }

            // Example suggestions
            VStack(spacing: 12) {
                Text("Try these:")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(secondaryColor)

                VStack(spacing: 8) {
                    ForEach(exampleExpenses, id: \.self) { expense in
                        Button {
                            onSendExample(expense)
                        } label: {
                            HStack {
                                Text(expense)
                                    .font(.system(size: 15))
                                    .foregroundColor(textColor)

                                Spacer()

                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(accentGreen)
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(cardColor)
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()
        }
        .padding(.top, 40)
    }

    private var exampleExpenses: [String] {
        ["£12.50 lunch", "£40 groceries", "£8 coffee", "£25 uber"]
    }
}

// MARK: - Conversation Graphics Preview

struct ChatBubbleCompositionView: View {
    private let backgroundColor = Color(hex: "0d0d0e")
    private let cardColor = Color(hex: "1c1c1e")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")
    private let accentGreen = Color(hex: "34c759")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Text("Chat Bubble Compositions")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(textColor)
                        .padding(.top, 20)

                    // 1. User message
                    previewSection(title: "User Message Bubble") {
                        HStack {
                            Spacer(minLength: 80)
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("£12.50 lunch")
                                    .font(.system(size: 16))
                                    .foregroundColor(textColor)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(hex: "2a2a2e"))
                                    )
                                Text("2:34 PM")
                                    .font(.caption2)
                                    .foregroundColor(secondaryColor)
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // 2. Wade confirmation card
                    previewSection(title: "Wade Confirmation Card") {
                        HStack {
                            WadeResponseCard(
                                message: Message.wadeConfirmation(
                                    transaction: Transaction(amount: 12.50, type: .expense, category: "Food", note: "£12.50 lunch", date: Date()),
                                    weeklyTotal: 127.40,
                                    weeklyIncome: 0,
                                    weeklyNet: -127.40
                                )
                            )
                        }
                        .padding(.horizontal, 16)
                    }

                    // 3. Wade greeting
                    previewSection(title: "Wade Greeting Card") {
                        HStack {
                            WadeResponseCard(
                                message: Message(
                                    role: .wade,
                                    text: "Hey! I'm Wade — send me your expenses like \"£12.50 lunch\" and I'll keep track."
                                )
                            )
                        }
                        .padding(.horizontal, 16)
                    }

                    // 4. Mixed conversation
                    previewSection(title: "Mixed Conversation Flow") {
                        VStack(spacing: 8) {
                            HStack {
                                Spacer(minLength: 80)
                                Text("£12.50 lunch")
                                    .font(.system(size: 15))
                                    .foregroundColor(textColor)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color(hex: "2a2a2e"))
                                    )
                            }

                            HStack {
                                WadeResponseCard(
                                    message: Message.wadeConfirmation(
                                        transaction: Transaction(amount: 12.50, type: .expense, category: "Food", note: "", date: Date()),
                                        weeklyTotal: 127.40,
                                        weeklyIncome: 0,
                                        weeklyNet: -127.40
                                    )
                                )
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 0)

                            HStack {
                                Spacer(minLength: 80)
                                Text("£8 coffee")
                                    .font(.system(size: 15))
                                    .foregroundColor(textColor)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color(hex: "2a2a2e"))
                                    )
                            }

                            HStack {
                                WadeResponseCard(
                                    message: Message.wadeConfirmation(
                                        transaction: Transaction(amount: 8.00, type: .expense, category: "Food", note: "", date: Date()),
                                        weeklyTotal: 135.40,
                                        weeklyIncome: 0,
                                        weeklyNet: -135.40
                                    )
                                )
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 0)
                        }
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
}

// MARK: - Money & Expense Abstract Icons

struct MoneyIconSetView: View {
    private let backgroundColor = Color(hex: "0d0d0e")
    private let cardColor = Color(hex: "1c1c1e")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")
    private let accentGreen = Color(hex: "34c759")
    private let expenseRed = Color(hex: "ff453a")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Text("Money & Expense Icons")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(textColor)
                        .padding(.top, 20)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        iconCard(icon: "sterlingsign.circle.fill", color: accentGreen, label: "GBP")
                        iconCard(icon: "dollarsign.circle.fill", color: accentGreen, label: "USD")
                        iconCard(icon: "eurosign.circle.fill", color: accentGreen, label: "EUR")
                        iconCard(icon: "arrow.down.circle.fill", color: accentGreen, label: "Income")
                        iconCard(icon: "arrow.up.circle.fill", color: expenseRed, label: "Expense")
                        iconCard(icon: "chart.bar.doc.horizontal.fill", color: Color(hex: "ffd60a"), label: "Summary")
                        iconCard(icon: "crown.fill", color: Color(hex: "ffd60a"), label: "Pro")
                        iconCard(icon: "bell.fill", color: secondaryColor, label: "Notify")
                        iconCard(icon: "checkmark.circle.fill", color: accentGreen, label: "Logged")
                    }
                    .padding(.horizontal, 20)

                    // Custom Wade icons
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Custom Compositions")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(textColor)

                        HStack(spacing: 16) {
                            // Wade avatar icon
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "1a3a2a"))
                                    .frame(width: 60, height: 60)
                                Text("W")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(accentGreen)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Wade Avatar")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(textColor)
                                Text("Deep green circle with bold W")
                                    .font(.system(size: 12))
                                    .foregroundColor(secondaryColor)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(cardColor)
                        )

                        HStack(spacing: 16) {
                            // Wave motif
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "1a2a3a"))
                                    .frame(width: 60, height: 60)
                                Image(systemName: "water.waves")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(hex: "5ac8fa"))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Wave Motif")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(textColor)
                                Text("Water/wave symbol for brand")
                                    .font(.system(size: 12))
                                    .foregroundColor(secondaryColor)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(cardColor)
                        )
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func iconCard(icon: String, color: Color, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(secondaryColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardColor)
        )
    }
}

// MARK: - Weekly Summary Card Preview

struct WeeklySummaryCardPreviewView: View {
    private let backgroundColor = Color(hex: "0d0d0e")
    private let cardColor = Color(hex: "1c1c1e")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")
    private let accentGreen = Color(hex: "34c759")
    private let expenseRed = Color(hex: "ff453a")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Text("Weekly Summary Card")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(textColor)
                        .padding(.top, 20)

                    // Compact version
                    previewSection(title: "Compact (In-chat)") {
                        WadeResponseCard(
                            message: Message.wadeConfirmation(
                                transaction: Transaction(amount: 127.40, type: .expense, category: "This week total", note: "", date: Date()),
                                weeklyTotal: 127.40,
                                weeklyIncome: 4200.00,
                                weeklyNet: 4072.60
                            )
                        )
                        .padding(.horizontal, 16)
                    }

                    // Full notification version
                    previewSection(title: "Full Card (Expanded / Notification)") {
                        VStack(spacing: 0) {
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("📊")
                                            .font(.system(size: 24))
                                        Text("Weekly Summary")
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundColor(textColor)
                                    }

                                    Spacer()

                                    Text("Fri 6pm")
                                        .font(.system(size: 13))
                                        .foregroundColor(secondaryColor)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            Capsule()
                                                .fill(Color(hex: "2a2a2e"))
                                        )
                                }

                                Divider()
                                    .background(Color(hex: "2a2a2e"))

                                HStack(spacing: 20) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Spent")
                                            .font(.system(size: 11))
                                            .foregroundColor(secondaryColor)
                                        Text("£127.40")
                                            .font(.system(size: 18, weight: .semibold, design: .monospaced))
                                            .foregroundColor(expenseRed)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Income")
                                            .font(.system(size: 11))
                                            .foregroundColor(secondaryColor)
                                        Text("£4,200")
                                            .font(.system(size: 18, weight: .semibold, design: .monospaced))
                                            .foregroundColor(accentGreen)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Net")
                                            .font(.system(size: 11))
                                            .foregroundColor(secondaryColor)
                                        HStack(spacing: 2) {
                                            Text("+")
                                                .font(.system(size: 16, weight: .semibold))
                                            Text("£4,072.60")
                                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                        }
                                        .foregroundColor(accentGreen)
                                    }
                                }

                                // Category breakdown
                                VStack(spacing: 8) {
                                    categoryRow(icon: "fork.knife", category: "Food & Drink", amount: "£67.40", percentage: 53)
                                    categoryRow(icon: "cart.fill", category: "Groceries", amount: "£40.00", percentage: 31)
                                    categoryRow(icon: "car.fill", category: "Transport", amount: "£20.00", percentage: 16)
                                }
                                .padding(.top, 4)
                            }
                            .padding(16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(cardColor)
                        )
                        .padding(.horizontal, 16)
                    }

                    // Mini bar chart version
                    previewSection(title: "With Chart") {
                        VStack(spacing: 12) {
                            HStack {
                                Text("📊 Weekly Summary")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(textColor)
                                Spacer()
                                Text("Fri 6pm")
                                    .font(.system(size: 12))
                                    .foregroundColor(secondaryColor)
                            }

                            HStack(alignment: .bottom, spacing: 6) {
                                ForEach(["Mon", "Tue", "Wed", "Thu", "Fri"], id: \.self) { day in
                                    VStack(spacing: 4) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(dayColor(for: day))
                                            .frame(width: 36, height: chartHeight(for: day))

                                        Text(day)
                                            .font(.system(size: 10))
                                            .foregroundColor(secondaryColor)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)

                            Divider()
                                .background(Color(hex: "2a2a2e"))

                            HStack {
                                summaryStat(label: "Spent", value: "£127.40", color: expenseRed)
                                Spacer()
                                summaryStat(label: "Income", value: "£4,200", color: accentGreen)
                                Spacer()
                                summaryStat(label: "Net", value: "+£4,072", color: accentGreen)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
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

    private func categoryRow(icon: String, category: String, amount: String, percentage: Int) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(secondaryColor)
                .frame(width: 20)

            Text(category)
                .font(.system(size: 13))
                .foregroundColor(textColor)

            Spacer()

            Text(amount)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(secondaryColor)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "2a2a2e"))
                        .frame(width: 60, height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(expenseRed)
                        .frame(width: 60 * CGFloat(percentage) / 100, height: 4)
                }
            }
            .frame(width: 60, height: 4)
        }
    }

    private func chartHeight(for day: String) -> CGFloat {
        switch day {
        case "Mon": return 30
        case "Tue": return 50
        case "Wed": return 75
        case "Thu": return 25
        case "Fri": return 45
        default: return 30
        }
    }

    private func dayColor(for day: String) -> Color {
        day == "Wed" ? expenseRed : accentGreen.opacity(0.5)
    }

    private func summaryStat(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(secondaryColor)
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(color)
        }
    }
}

// MARK: - Text Message UI Mockup

struct TextMessageUIMockupView: View {
    private let backgroundColor = Color(hex: "0d0d0e")
    private let cardColor = Color(hex: "1c1c1e")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")
    private let accentGreen = Color(hex: "34c759")
    private let expenseRed = Color(hex: "ff453a")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Text("Text Message UI Mockup")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(textColor)
                        .padding(.top, 20)

                    // iMessage style conversation
                    previewSection(title: "iMessage Style") {
                        VStack(spacing: 8) {
                            HStack {
                                Spacer(minLength: 60)
                                Text("£12.50 lunch")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        BlueGradient()
                                    )
                            }

                            HStack {
                                WadeResponseCard(
                                    message: Message.wadeConfirmation(
                                        transaction: Transaction(amount: 12.50, type: .expense, category: "Food", note: "", date: Date()),
                                        weeklyTotal: 127.40,
                                        weeklyIncome: 0,
                                        weeklyNet: -127.40
                                    )
                                )
                                Spacer(minLength: 0)
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // All-green dark theme
                    previewSection(title: "Dark Theme (Wade Style)") {
                        VStack(spacing: 8) {
                            HStack {
                                Spacer(minLength: 80)
                                Text("£12.50 lunch")
                                    .font(.system(size: 15))
                                    .foregroundColor(textColor)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color(hex: "2a2a2e"))
                                    )
                                Text("2:34 PM")
                                    .font(.caption2)
                                    .foregroundColor(secondaryColor)
                            }

                            HStack {
                                WadeResponseCard(
                                    message: Message.wadeConfirmation(
                                        transaction: Transaction(amount: 12.50, type: .expense, category: "Food", note: "", date: Date()),
                                        weeklyTotal: 127.40,
                                        weeklyIncome: 4200,
                                        weeklyNet: 4072.60
                                    )
                                )
                                Spacer(minLength: 0)
                            }
                        }
                    }

                    // Input bar mockup
                    previewSection(title: "Input Bar") {
                        HStack(spacing: 12) {
                            TextField("Type your expense...", text: .constant(""))
                                .font(.system(size: 16))
                                .foregroundColor(textColor)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color(hex: "2a2a2e"))
                                )

                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(accentGreen)
                        }
                        .padding(16)
                    }

                    // Full conversation flow
                    previewSection(title: "Full Conversation Flow") {
                        VStack(spacing: 12) {
                            // Greeting from Wade
                            HStack {
                                WadeResponseCard(
                                    message: Message(
                                        role: .wade,
                                        text: "Hey! I'm Wade — send me your expenses like \"£12.50 lunch\" or \"£40 groceries\" and I'll keep track."
                                    )
                                )
                                Spacer(minLength: 0)
                            }

                            // User expense
                            HStack {
                                Spacer(minLength: 60)
                                Text("£12.50 lunch")
                                    .font(.system(size: 15))
                                    .foregroundColor(textColor)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color(hex: "2a2a2e"))
                                    )
                            }

                            // Wade confirmation
                            HStack {
                                WadeResponseCard(
                                    message: Message.wadeConfirmation(
                                        transaction: Transaction(amount: 12.50, type: .expense, category: "Food", note: "", date: Date()),
                                        weeklyTotal: 12.50,
                                        weeklyIncome: 0,
                                        weeklyNet: -12.50
                                    )
                                )
                                Spacer(minLength: 0)
                            }

                            // User income
                            HStack {
                                Spacer(minLength: 60)
                                Text("salary")
                                    .font(.system(size: 15))
                                    .foregroundColor(textColor)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color(hex: "2a2a2e"))
                                    )
                            }

                            // Wade income confirmation
                            HStack {
                                WadeResponseCard(
                                    message: Message(
                                        role: .wade,
                                        text: "✓ Income logged: £4,200.00\nMar 24",
                                        transaction: Transaction(amount: 4200, type: .income, category: "Salary", note: "salary", date: Date())
                                    )
                                )
                                Spacer(minLength: 0)
                            }
                        }
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
}

// Blue gradient for iMessage bubbles
struct BlueGradient: View {
    var body: some View {
        LinearGradient(
            colors: [Color(hex: "0a84ff"), Color(hex: "0056b3")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
