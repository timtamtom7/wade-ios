import SwiftUI

struct WadeResponseCard: View {
    let message: Message

    private let cardColor = Color(hex: "1c1c1e")
    private let errorCardColor = Color(hex: "2a1a0a")
    private let incomeColor = Color(hex: "34c759")
    private let expenseColor = Color(hex: "ff453a")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")
    private let warningColor = Color(hex: "ff9f0a")
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    private var isErrorMessage: Bool {
        message.transaction == nil &&
        (message.text.contains("didn't") ||
         message.text.contains("Oops") ||
         message.text.contains("limit") ||
         message.text.contains("Upgrade") ||
         message.text.contains("hit the free"))
    }

    private var isUpgradePrompt: Bool {
        message.transaction == nil &&
        (message.text.contains("Upgrade") || message.text.contains("Wade Pro"))
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                if let tx = message.transaction {
                    transactionContent(tx)
                } else {
                    textContent
                }
            }
            .padding(16)
            .frame(maxWidth: 280, alignment: .leading)
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

            if !tx.category.isEmpty {
                Text(tx.category)
                    .font(.system(size: 14))
                    .foregroundColor(secondaryColor)
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
        }
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            if isErrorMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(warningColor)

                    Text(isUpgradePrompt ? "Upgrade" : "Note")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(warningColor)
                }
            }

            Text(message.text)
                .font(.system(size: 14))
                .foregroundColor(isErrorMessage ? textColor : textColor)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var cardForMessage: Color {
        if isErrorMessage {
            return errorCardColor
        }
        return cardColor
    }

    private var borderForMessage: Color {
        if isErrorMessage {
            return warningColor.opacity(0.3)
        }
        return .clear
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }
}
