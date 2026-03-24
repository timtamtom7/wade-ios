import SwiftUI

struct PricingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscription = SubscriptionManager.shared
    @State private var selectedTier: SubscriptionTier? = nil
    @State private var showConfirmUpgrade: Bool = false

    private let backgroundColor = Color(hex: "0d0d0e")
    private let cardColor = Color(hex: "1c1c1e")
    private let accentGreen = Color(hex: "34c759")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")
    private let expenseRed = Color(hex: "ff453a")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    headerSection

                    tiersSection

                    featuresComparison

                    Spacer(minLength: 40)
                }
                .padding(.top, 24)
                .padding(.horizontal, 20)
            }

            VStack {
                Spacer()

                if subscription.currentTier == .free {
                    upgradeButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                        .background(
                            LinearGradient(
                                colors: [Color.clear, backgroundColor],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 120)
                            .allowsHitTesting(false)
                        )
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert("Upgrade to \(selectedTier?.displayName ?? "")?", isPresented: $showConfirmUpgrade) {
            Button("Cancel", role: .cancel) { }
            Button("Upgrade") {
                if let tier = selectedTier {
                    subscription.upgrade(to: tier)
                    dismiss()
                }
            }
        } message: {
            if let tier = selectedTier, let price = tier.monthlyPrice {
                Text("You'll be charged \(String(format: "$%.2f", price))/month. Cancel anytime in Settings.")
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "ffd60a"))

                Text("Unlock Wade Pro")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(textColor)
            }

            Text("Get more from your money, without the spreadsheets")
                .font(.system(size: 16))
                .foregroundColor(secondaryColor)
                .multilineTextAlignment(.center)
        }
    }

    private var tiersSection: some View {
        VStack(spacing: 16) {
            ForEach(SubscriptionTier.allCases, id: \.self) { tier in
                TierCard(
                    tier: tier,
                    isCurrent: subscription.currentTier == tier,
                    isSelected: selectedTier == tier,
                    onSelect: {
                        if tier != .free && tier != subscription.currentTier {
                            selectedTier = tier
                            showConfirmUpgrade = true
                        }
                    }
                )
            }
        }
    }

    private var featuresComparison: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What's included")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(textColor)

            comparisonRow(
                icon: "number",
                title: "20 expenses/month",
                free: true,
                track: true,
                overview: true
            )

            comparisonRow(
                icon: "chart.bar.fill",
                title: "Weekly summaries",
                free: false,
                track: true,
                overview: true
            )

            comparisonRow(
                icon: "square.grid.2x2.fill",
                title: "Category insights",
                free: false,
                track: true,
                overview: true
            )

            comparisonRow(
                icon: "chart.pie.fill",
                title: "Monthly reports",
                free: false,
                track: false,
                overview: true
            )

            comparisonRow(
                icon: "target",
                title: "Budget goals",
                free: false,
                track: false,
                overview: true
            )

            comparisonRow(
                icon: "arrow.down.doc.fill",
                title: "Export CSV / PDF",
                free: false,
                track: false,
                overview: true
            )

            comparisonRow(
                icon: "dollarsign.arrow.circlepath",
                title: "Multiple currencies",
                free: false,
                track: false,
                overview: true
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardColor)
        )
    }

    private func comparisonRow(icon: String, title: String, free: Bool, track: Bool, overview: Bool) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(secondaryColor)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 14))
                .foregroundColor(textColor)

            Spacer()

            HStack(spacing: 20) {
                checkmarkOrCross(free)
                checkmarkOrCross(track)
                checkmarkOrCross(overview)
            }
        }
    }

    @ViewBuilder
    private func checkmarkOrCross(_ included: Bool) -> some View {
        if included {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(accentGreen)
                .font(.system(size: 16))
        } else {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(Color(hex: "3a3a3e"))
                .font(.system(size: 16))
        }
    }

    private var upgradeButton: some View {
        Button {
            selectedTier = .track
            showConfirmUpgrade = true
        } label: {
            HStack {
                Text("Start 7-day free trial")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "0d0d0e"))

                Image(systemName: "arrow.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "0d0d0e"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(accentGreen)
            )
        }
    }
}

struct TierCard: View {
    let tier: SubscriptionTier
    let isCurrent: Bool
    let isSelected: Bool
    let onSelect: () -> Void

    private let cardColor = Color(hex: "1c1c1e")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")
    private let accentGreen = Color(hex: "34c759")

    private var tierAccentColor: Color {
        Color(hex: tier.accentColorHex)
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(tier.displayName)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(textColor)

                            if isCurrent {
                                Text("Current")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Color(hex: "0d0d0e"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(accentGreen)
                                    )
                            }
                        }

                        Text(tier.tagline)
                            .font(.system(size: 13))
                            .foregroundColor(secondaryColor)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(tier.price)
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(tierAccentColor)

                        if tier.isFree {
                            Text("")
                                .font(.system(size: 11))
                        }
                    }
                }

                Divider()
                    .background(Color(hex: "2a2a2e"))

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(tier.features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(accentGreen)

                            Text(feature)
                                .font(.system(size: 13))
                                .foregroundColor(textColor)
                        }
                    }

                    if tier == .free {
                        ForEach(tier.featuresNotIncluded, id: \.self) { feature in
                            HStack(spacing: 8) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(hex: "3a3a3e"))

                                Text(feature)
                                    .font(.system(size: 13))
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? tierAccentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isCurrent || tier.isFree)
    }
}
