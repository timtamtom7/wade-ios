import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showPricing: Bool
    @StateObject private var subscription = SubscriptionManager.shared

    @AppStorage("monthlyBudget") private var monthlyBudget: Double = 0
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true

    private let backgroundColor = Color(hex: "0d0d0e")
    private let cardColor = Color(hex: "1c1c1e")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")
    private let accentGreen = Color(hex: "34c759")
    private let expenseRed = Color(hex: "ff453a")

    init(showPricing: Binding<Bool> = .constant(false)) {
        self._showPricing = showPricing
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        wadeProSection

                        preferencesSection

                        currencySection

                        budgetSection

                        notificationSection

                        subscriptionSection

                        aboutSection

                        Spacer()
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(accentGreen)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Wade Pro Section
    private var wadeProSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wade Pro")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(secondaryColor)

            Button {
                showPricing = true
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "1a3a2a"))
                            .frame(width: 44, height: 44)

                        if subscription.currentTier == .overview {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "ffd60a"))
                        } else {
                            Text("W")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(accentGreen)
                        }
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text("Current Plan")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(textColor)

                            if subscription.currentTier != .free {
                                Text(subscription.currentTier.displayName)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Color(hex: "0d0d0e"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(Color(hex: "34c759"))
                                    )
                            }
                        }

                        Text(tierDescription)
                            .font(.system(size: 13))
                            .foregroundColor(secondaryColor)
                    }

                    Spacer()

                    if subscription.currentTier == .free {
                        Text("Upgrade")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "0d0d0e"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(accentGreen)
                            )
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(accentGreen)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(cardColor)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var tierDescription: String {
        switch subscription.currentTier {
        case .free:
            return "20 expenses/month · No summaries"
        case .track:
            return "Unlimited expenses · Weekly summaries"
        case .overview:
            return "Everything · Monthly reports · Export"
        }
    }

    // MARK: - Preferences Section
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preferences")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(secondaryColor)

            VStack(spacing: 0) {
                settingsRow(
                    icon: "bell.fill",
                    title: "Weekly Summary",
                    subtitle: "Friday at 6pm",
                    showToggle: true,
                    isOn: $notificationsEnabled
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardColor)
            )
        }
    }

    // MARK: - Currency Section
    private var currencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Currency")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(secondaryColor)

            VStack(spacing: 0) {
                Menu {
                    ForEach(CurrencyService.supportedCurrencies, id: \.code) { currency in
                        Button {
                            CurrencyService.shared.primaryCurrencyCode = currency.code
                        } label: {
                            HStack {
                                Text("\(currency.symbol) \(currency.code)")
                                if currency.code == CurrencyService.shared.primaryCurrencyCode {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "sterlingsign.circle.fill")
                            .foregroundColor(accentGreen)
                            .font(.system(size: 20))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Display Currency")
                                .font(.system(size: 16))
                                .foregroundColor(textColor)

                            Text("All amounts shown in this currency")
                                .font(.system(size: 12))
                                .foregroundColor(secondaryColor)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Text(CurrencyService.shared.primaryCurrencySymbol)
                                .font(.system(size: 16, design: .monospaced))
                                .foregroundColor(textColor)
                            Text(CurrencyService.shared.primaryCurrencyCode)
                                .font(.system(size: 12))
                                .foregroundColor(secondaryColor)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 10))
                                .foregroundColor(secondaryColor)
                        }
                    }
                    .padding(16)
                }
                .buttonStyle(.plain)

                // Note about multi-currency tracking
                Divider()
                    .background(Color(hex: "2a2a2e"))

                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "5ac8fa"))

                    Text("Track in any currency — £, $, €, ¥ all supported. Amounts convert to your display currency for totals.")
                        .font(.system(size: 12))
                        .foregroundColor(secondaryColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardColor)
            )
        }
    }

    // MARK: - Budget Section
    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Budget")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(secondaryColor)

            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "target")
                        .foregroundColor(accentGreen)
                        .font(.system(size: 20))

                    Text("Monthly Budget")
                        .font(.system(size: 16))
                        .foregroundColor(textColor)

                    Spacer()

                    Text(monthlyBudget > 0 ? formatCurrency(monthlyBudget) : "Not set")
                        .font(.system(size: 16, design: .monospaced))
                        .foregroundColor(secondaryColor)
                }
                .padding(16)

                if monthlyBudget > 0 {
                    Divider()
                        .background(Color(hex: "2a2a2e"))

                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(accentGreen)
                            .font(.system(size: 20))

                        Text("Spent this month")
                            .font(.system(size: 16))
                            .foregroundColor(textColor)

                        Spacer()

                        let spent = DatabaseService.shared.fetchThisMonth()
                            .filter { $0.type == .expense }
                            .reduce(0) { $0 + $1.amount }

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(formatCurrency(spent))
                                .font(.system(size: 16, design: .monospaced))
                                .foregroundColor(spent > monthlyBudget ? expenseRed : textColor)

                            if spent > monthlyBudget {
                                Text("Over budget!")
                                    .font(.system(size: 11))
                                    .foregroundColor(expenseRed)
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardColor)
            )
        }
    }

    // MARK: - Notification Section
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notifications")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(secondaryColor)

            VStack(spacing: 0) {
                Button {
                    openNotificationSettings()
                } label: {
                    HStack {
                        Image(systemName: "app.badge.fill")
                            .foregroundColor(accentGreen)
                            .font(.system(size: 20))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Notification Settings")
                                .font(.system(size: 16))
                                .foregroundColor(textColor)

                            Text("Manage permissions in iOS Settings")
                                .font(.system(size: 12))
                                .foregroundColor(secondaryColor)
                        }

                        Spacer()

                        Image(systemName: "arrow.up.forward")
                            .font(.system(size: 13))
                            .foregroundColor(secondaryColor)
                    }
                    .padding(16)
                }
                .buttonStyle(.plain)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardColor)
            )
        }
    }

    // MARK: - Subscription Section
    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Subscription")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(secondaryColor)

            VStack(spacing: 0) {
                Button {
                    showPricing = true
                } label: {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(Color(hex: "ffd60a"))
                            .font(.system(size: 20))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Manage Subscription")
                                .font(.system(size: 16))
                                .foregroundColor(textColor)

                            Text("Change or cancel your plan")
                                .font(.system(size: 12))
                                .foregroundColor(secondaryColor)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13))
                            .foregroundColor(secondaryColor)
                    }
                    .padding(16)
                }
                .buttonStyle(.plain)

                Divider()
                    .background(Color(hex: "2a2a2e"))

                Button {
                    // Restore purchases
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(accentGreen)
                            .font(.system(size: 20))

                        Text("Restore Purchases")
                            .font(.system(size: 16))
                            .foregroundColor(textColor)

                        Spacer()
                    }
                    .padding(16)
                }
                .buttonStyle(.plain)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardColor)
            )
        }
    }

    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(secondaryColor)

            VStack(spacing: 0) {
                HStack {
                    Text("Version")
                        .font(.system(size: 16))
                        .foregroundColor(textColor)
                    Spacer()
                    Text("1.0.0")
                        .font(.system(size: 16))
                        .foregroundColor(secondaryColor)
                }
                .padding(16)

                Divider()
                    .background(Color(hex: "2a2a2e"))

                HStack {
                    Text("Build")
                        .font(.system(size: 16))
                        .foregroundColor(textColor)
                    Spacer()
                    Text("1")
                        .font(.system(size: 16))
                        .foregroundColor(secondaryColor)
                }
                .padding(16)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardColor)
            )
        }
    }

    // MARK: - Helper Methods
    private func settingsRow(icon: String, title: String, subtitle: String, showToggle: Bool = false, isOn: Binding<Bool> = .constant(true)) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(accentColor(for: icon))
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(textColor)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(secondaryColor)
            }

            Spacer()

            if showToggle {
                Toggle("", isOn: isOn)
                    .labelsHidden()
                    .tint(accentGreen)
            }
        }
        .padding(16)
    }

    private func accentColor(for icon: String) -> Color {
        switch icon {
        case "bell.fill": return accentGreen
        case "crown.fill": return Color(hex: "ffd60a")
        default: return accentGreen
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }

    private func openNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
