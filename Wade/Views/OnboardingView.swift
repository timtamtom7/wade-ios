import SwiftUI

struct OnboardingView: View {
    @StateObject private var subscription = SubscriptionManager.shared
    @State private var currentPage: Int = 0
    @State private var showNotificationPermission: Bool = false

    private let backgroundColor = Color(hex: "0d0d0e")
    private let cardColor = Color(hex: "1c1c1e")
    private let accentGreen = Color(hex: "34c759")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            TabView(selection: $currentPage) {
                OnboardingPage1()
                    .tag(0)

                OnboardingPage2()
                    .tag(1)

                OnboardingPage3()
                    .tag(2)

                OnboardingPage4(onComplete: {
                    completeOnboarding()
                })
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            VStack {
                Spacer()

                pageIndicator

                if currentPage < 3 {
                    skipButton
                }

                Spacer()
                    .frame(height: 60)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? accentGreen : Color(hex: "2a2a2e"))
                    .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
        .padding(.bottom, 16)
    }

    private var skipButton: some View {
        Button {
            withAnimation {
                currentPage = min(currentPage + 1, 3)
            }
        } label: {
            HStack {
                Text(currentPage < 3 ? "Next" : "Get Started")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(accentGreen)

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(accentGreen)
            }
        }
        .padding(.top, 8)
    }

    private func completeOnboarding() {
        subscription.hasCompletedOnboarding = true
    }
}

// MARK: - Page 1: Concept
struct OnboardingPage1: View {
    private let backgroundColor = Color(hex: "0d0d0e")
    private let cardColor = Color(hex: "1c1c1e")
    private let accentGreen = Color(hex: "34c759")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 40)

            // Abstract wave/water graphic
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "1a3a2a"), Color(hex: "0d0d0e")],
                            center: .center,
                            startRadius: 20,
                            endRadius: 200
                        )
                    )
                    .frame(width: 280, height: 280)

                // Water ripple effect
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(Color(hex: "34c759").opacity(0.3 - Double(i) * 0.1), lineWidth: 1)
                        .frame(width: CGFloat(100 + i * 60), height: CGFloat(100 + i * 60))
                }

                // Dollar sign
                Text("£")
                    .font(.system(size: 80, weight: .light, design: .rounded))
                    .foregroundColor(accentGreen.opacity(0.8))
            }
            .padding(.bottom, 48)

            VStack(spacing: 16) {
                Text("Money, without\nthe effort")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)

                Text("Wade keeps track of your spending so you don't have to open an app, categorize expenses, or touch a spreadsheet.")
                    .font(.system(size: 16))
                    .foregroundColor(secondaryColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
    }
}

// MARK: - Page 2: How it works
struct OnboardingPage2: View {
    private let backgroundColor = Color(hex: "0d0d0e")
    private let cardColor = Color(hex: "1c1c1e")
    private let accentGreen = Color(hex: "34c759")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")
    private let expenseRed = Color(hex: "ff453a")

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 40)

            // Text message mockup
            VStack(spacing: 12) {
                // User message bubble
                HStack {
                    Spacer(minLength: 60)
                    Text("£12.50 lunch")
                        .font(.system(size: 16))
                        .foregroundColor(textColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "2a2a2e"))
                        )
                }
                .padding(.horizontal, 20)

                // Wade response
                HStack {
                    Text("")
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(cardColor)
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text("W")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(accentGreen)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(accentGreen)
                                .font(.system(size: 14))
                            Text("Logged: £12.50")
                                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                                .foregroundColor(textColor)
                        }
                        Text("Food · Just now")
                            .font(.system(size: 12))
                            .foregroundColor(secondaryColor)
                        Text("This week: £127.40")
                            .font(.system(size: 12))
                            .foregroundColor(secondaryColor)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(cardColor)
                    )

                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 20)

                // Second user message
                HStack {
                    Spacer(minLength: 60)
                    Text("£40 groceries")
                        .font(.system(size: 16))
                        .foregroundColor(textColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: "2a2a2e"))
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
            }
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: "111112"))
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 40)

            VStack(spacing: 16) {
                Text("Just text it")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)

                Text("Send \"£12.50 lunch\" or \"£40 groceries\" and Wade understands. Amount, category, done.")
                    .font(.system(size: 16))
                    .foregroundColor(secondaryColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
    }
}

// MARK: - Page 3: Weekly Summary
struct OnboardingPage3: View {
    private let backgroundColor = Color(hex: "0d0d0e")
    private let cardColor = Color(hex: "1c1c1e")
    private let accentGreen = Color(hex: "34c759")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")
    private let expenseRed = Color(hex: "ff453a")

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 40)

            // Weekly summary card preview
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("📊")
                            .font(.system(size: 28))
                        Text("Weekly Summary")
                            .font(.system(size: 17, weight: .semibold))
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

                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Spent")
                            .font(.system(size: 12))
                            .foregroundColor(secondaryColor)
                        Text("£127.40")
                            .font(.system(size: 20, weight: .semibold, design: .monospaced))
                            .foregroundColor(expenseRed)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Income")
                            .font(.system(size: 12))
                            .foregroundColor(secondaryColor)
                        Text("£4,200")
                            .font(.system(size: 20, weight: .semibold, design: .monospaced))
                            .foregroundColor(accentGreen)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Net")
                            .font(.system(size: 12))
                            .foregroundColor(secondaryColor)
                        HStack(spacing: 2) {
                            Text("+")
                                .font(.system(size: 18, weight: .semibold))
                            Text("£4,072.60")
                                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        }
                        .foregroundColor(accentGreen)
                    }
                }

                // Mini bar chart
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(["Mon", "Tue", "Wed", "Thu", "Fri"], id: \.self) { day in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(day == "Wed" ? expenseRed : accentGreen.opacity(0.4))
                                .frame(width: 28, height: CGFloat.random(in: 20...70))

                            Text(day)
                                .font(.system(size: 10))
                                .foregroundColor(secondaryColor)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(cardColor)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 40)

            VStack(spacing: 16) {
                Text("Every Friday")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)

                Text("At 6pm, Wade texts you a summary. See the week at a glance — no digging through apps.")
                    .font(.system(size: 16))
                    .foregroundColor(secondaryColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }

            Spacer()
        }
    }
}

// MARK: - Page 4: Notification Permission
struct OnboardingPage4: View {
    let onComplete: () -> Void

    @State private var notificationStatus: NotificationStatus = .unknown

    private let backgroundColor = Color(hex: "0d0d0e")
    private let cardColor = Color(hex: "1c1c1e")
    private let accentGreen = Color(hex: "34c759")
    private let textColor = Color(hex: "f5f5f7")
    private let secondaryColor = Color(hex: "8a8a8a")

    enum NotificationStatus {
        case unknown, granted, denied, restricted
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 40)

            // Notification preview
            ZStack {
                RoundedRectangle(cornerRadius: 40)
                    .fill(cardColor)
                    .frame(width: 200, height: 400)

                VStack(spacing: 12) {
                    // App icon placeholder
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "1c1c1e"))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text("W")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(accentGreen)
                        )

                    Text("Wade")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(textColor)

                    // Notification preview
                    VStack(alignment: .leading, spacing: 6) {
                        Text("📊 This Week's Summary")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(textColor)

                        Text("Spent: £127.40\nIncome: £4,200.00\nNet: +£4,072.60")
                            .font(.system(size: 12))
                            .foregroundColor(secondaryColor)
                            .lineSpacing(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "0d0d0e"))
                    )
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 30)
            }
            .padding(.bottom, 40)

            VStack(spacing: 16) {
                Text("Start tracking")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)

                Text("Enable notifications so Wade can send your weekly summary every Friday at 6pm.")
                    .font(.system(size: 16))
                    .foregroundColor(secondaryColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)

                notificationButton
            }

            Spacer()

            // Continue button
            Button {
                onComplete()
            } label: {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(accentGreen)
            }
            .padding(.bottom, 40)
        }
    }

    @ViewBuilder
    private var notificationButton: some View {
        switch notificationStatus {
        case .unknown:
            Button {
                requestNotificationPermission()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 14))
                    Text("Enable Notifications")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(Color(hex: "0d0d0e"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(accentGreen)
                )
            }
            .padding(.horizontal, 40)

        case .granted:
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(accentGreen)
                Text("Notifications enabled!")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(accentGreen)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(accentGreen.opacity(0.15))
            )
            .padding(.horizontal, 40)

        case .denied:
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(hex: "ff453a"))
                    Text("Notifications off")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "ff453a"))
                }

                Text("Enable in Settings → Notifications → Wade")
                    .font(.system(size: 12))
                    .foregroundColor(secondaryColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "ff453a").opacity(0.1))
            )
            .padding(.horizontal, 40)

        case .restricted:
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .foregroundColor(secondaryColor)
                Text("Notifications restricted")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(secondaryColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "2a2a2e"))
            )
            .padding(.horizontal, 40)
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    notificationStatus = .granted
                    NotificationService.shared.scheduleWeeklySummary()
                } else {
                    notificationStatus = .denied
                }
            }
        }
    }
}
