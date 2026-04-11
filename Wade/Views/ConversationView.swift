import SwiftUI

struct ConversationView: View {
    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    @State private var showSettings: Bool = false
    @State private var showPricing: Bool = false
    @State private var showParseError: Bool = false
    @State private var showStorageFull: Bool = false
    @State private var parseErrorMessage: String = ""
    @State private var currentErrorType: ErrorStateType = .couldntParse
    @State private var showErrorState: Bool = false
    @FocusState private var isInputFocused: Bool

    private let conversationService = ConversationService.shared
    private let subscription = SubscriptionManager.shared
    private let backgroundColor = Color(hex: "0d0d0e")

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                VStack(spacing: 0) {
                    if messages.isEmpty {
                        EmptyConversationView { example in
                            inputText = example
                            sendMessage()
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(messages) { message in
                                        Group {
                                            if message.role == .user {
                                                MessageBubbleView(message: message)
                                            } else {
                                                WadeResponseCard(message: message)
                                            }
                                        }
                                        .id(message.id)
                                    }
                                }
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                            }
                            .onChange(of: messages.count) { _, _ in
                                if let last = messages.last {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        proxy.scrollTo(last.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    }

                    Divider()
                        .background(Color(hex: "2a2a2e"))

                    inputBar
                }
            }
            .navigationTitle("Wade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if subscription.currentTier != .overview {
                        Button {
                            showPricing = true
                        } label: {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "ffd60a"))
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            sendWeeklySummary()
                        } label: {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .foregroundColor(Color(hex: "8a8a8a"))
                        }
                        .accessibilityLabel("Send weekly summary")

                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(Color(hex: "8a8a8a"))
                        }
                        .accessibilityLabel("Settings")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(showPricing: $showPricing)
            }
            .sheet(isPresented: $showPricing) {
                PricingView()
            }
            .sheet(isPresented: $showErrorState) {
                ErrorStateView(type: currentErrorType) {
                    // Retry action based on error type
                }
            }
            .alert("Couldn't parse that", isPresented: $showParseError) {
                Button("OK", role: .cancel) { }
                Button("Try again") {
                    // inputText still contains the last text
                }
            } message: {
                Text(parseErrorMessage)
            }
            .alert("Storage full", isPresented: $showStorageFull) {
                Button("OK", role: .cancel) { }
                Button("Upgrade") {
                    showPricing = true
                }
            } message: {
                Text("You've hit the free limit of 20 expenses. Upgrade to Track for unlimited tracking.")
            }
            .onAppear {
                if messages.isEmpty {
                    let greeting = conversationService.getGreeting()
                    messages.append(greeting)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Type your expense...", text: $inputText)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "f5f5f7"))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(hex: "2a2a2e"))
                )
                .focused($isInputFocused)
                .accessibilityHint("Enter expense amount and description, for example £12.50 lunch")

            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(inputText.isEmpty ? Color(hex: "3a3a3e") : Color(hex: "34c759"))
            }
            .disabled(inputText.isEmpty || isLoading)
            .accessibilityLabel("Send")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(Color(hex: "1c1c1e"))
        )
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let userMsg = Message.userMessage(text)
        messages.append(userMsg)
        inputText = ""

        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isLoading = false
            let response = conversationService.processUserInput(text)

            // Check for parse failure - show as card (already handled by WadeResponseCard)
            if response.messageType == .parseFailure {
                parseErrorMessage = response.text
            }

            // Check for monthly report failure
            if response.text.contains("Couldn't generate") || response.text.contains("No data for that month") {
                currentErrorType = .monthlyReportFailed
                // Show as Wade card instead of full error state
            }

            // Check if storage is full
            let monthCount = DatabaseService.shared.fetchThisMonth().count
            if !subscription.canAddExpense(currentMonthCount: monthCount) {
                showStorageFull = true
            }

            messages.append(response)
        }
    }

    private func sendWeeklySummary() {
        let summary = conversationService.getWeeklySummaryMessage()
        messages.append(summary)
    }
}
