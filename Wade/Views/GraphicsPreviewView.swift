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
                .foregroundColor(selectedTab == tag ? Color(hex: "34c759") : Color(hex: "8a8a8a"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedTab == tag ? Color(hex: "34c759").opacity(0.15) : Color.clear)
                )
        }
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
