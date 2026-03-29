import SwiftUI

struct GroupPlanningView: View {
    @StateObject private var viewModel: GroupPlanningViewModel
    @State private var selectedTripId: UUID?
    @State private var selectedSegment = 0
    @State private var showAddExpense = false
    @State private var showCreateVote = false

    init() {
        // Use a sample trip for demo
        let sampleTripId = UUID()
        _viewModel = StateObject(wrappedValue: GroupPlanningViewModel(tripId: sampleTripId))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Segment Control
            Picker("View", selection: $selectedSegment) {
                Text("Expenses").tag(0)
                Text("Voting").tag(1)
                Text("Members").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()

            Divider()

            // Content
            Group {
                switch selectedSegment {
                case 0:
                    expensesView
                case 1:
                    votingView
                case 2:
                    membersView
                default:
                    EmptyView()
                }
            }
        }
        .background(Theme.surface)
        .sheet(isPresented: $showAddExpense) {
            AddExpenseSheet(plan: $viewModel.plan)
        }
        .sheet(isPresented: $showCreateVote) {
            CreateVoteSheet(plan: $viewModel.plan)
        }
        .onAppear {
            viewModel.loadPlan()
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.3.fill")
                    .font(.title2)
                    .foregroundColor(Theme.oceanBlue)

                Text("Group Planning")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Button {
                    if selectedSegment == 0 {
                        showAddExpense = true
                    } else if selectedSegment == 1 {
                        showCreateVote = true
                    }
                } label: {
                    Image(systemName: selectedSegment == 0 ? "plus.circle.fill" : "plus.circle")
                        .font(.title3)
                        .foregroundColor(Theme.oceanBlue)
                }
            }

            Text("Plan together, split costs, vote on activities")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    // MARK: - Expenses View

    private var expensesView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Balance Summary
                balanceSummaryCard

                // Expense List
                if viewModel.plan.expenses.isEmpty {
                    emptyExpensesView
                } else {
                    ForEach(viewModel.plan.expenses) { expense in
                        ExpenseRowView(expense: expense)
                    }
                }
            }
            .padding()
        }
    }

    private var balanceSummaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Group Balance")
                    .font(.headline)
                Spacer()
            }

            let splits = viewModel.calculateSplits()
            ForEach(Array(splits.sorted(by: { abs($0.value) > abs($1.value) })), id: \.key) { userId, balance in
                let member = viewModel.plan.members.first { $0.userId == userId }
                let memberName = member?.userName ?? userId
                let isOwing = balance > 0
                let isSettled = abs(balance) < 0.01

                HStack {
                    Text(memberName)
                        .font(.subheadline)

                    Spacer()

                    if isSettled {
                        Text("Settled")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else if isOwing {
                        Text("is owed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(String(format: "%.2f", balance))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    } else {
                        Text("owes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(String(format: "%.2f", abs(balance)))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
        .background(Theme.surface)
        .cornerRadius(12)
    }

    private var emptyExpensesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No expenses yet")
                .font(.headline)

            Text("Add expenses to track who paid what")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Add First Expense") {
                showAddExpense = true
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.oceanBlue)
        }
        .padding(40)
    }

    // MARK: - Voting View

    private var votingView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.plan.votes.isEmpty {
                    emptyVotingView
                } else {
                    ForEach(viewModel.plan.votes) { vote in
                        VoteCardView(
                            vote: vote,
                            onVote: { optionId in
                                viewModel.castVote(voteId: vote.id, optionId: optionId)
                            },
                            onClose: {
                                viewModel.closeVote(voteId: vote.id)
                            }
                        )
                    }
                }
            }
            .padding()
        }
    }

    private var emptyVotingView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No votes yet")
                .font(.headline)

            Text("Create a vote to decide things as a group")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Create First Vote") {
                showCreateVote = true
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.oceanBlue)
        }
        .padding(40)
    }

    // MARK: - Members View

    private var membersView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.plan.members) { member in
                    MemberRowView(member: member)
                }
            }
            .padding()
        }
    }
}

// MARK: - Expense Row

struct ExpenseRowView: View {
    let expense: GroupExpense

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(Theme.oceanBlue.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: "dollarsign")
                    .foregroundColor(Theme.oceanBlue)
            }

            // Details
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.description)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Paid by \(expense.paidByName) • \(expense.splitType.rawValue.capitalized) split")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Amount
            Text("$\(String(format: "%.2f", expense.amount))")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Theme.surface)
        .cornerRadius(12)
    }
}

// MARK: - Vote Card

struct VoteCardView: View {
    let vote: GroupVote
    let onVote: (UUID) -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(vote.question)
                    .font(.headline)

                Spacer()

                statusBadge
            }

            // Options
            ForEach(vote.options) { option in
                VoteOptionRow(
                    option: option,
                    isSelected: vote.votedBy.contains("currentUser"),
                    isClosed: vote.status == .closed
                ) {
                    if vote.status == .open {
                        onVote(option.id)
                    }
                }
            }

            // Footer
            HStack {
                Text("\(vote.votedBy.count) votes")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if vote.status == .open {
                    Button("Close Vote") {
                        onClose()
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                } else if let winner = vote.winningOption {
                    Label("Winner: \(winner.text)", systemImage: "crown.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding()
        .background(Theme.surface)
        .cornerRadius(12)
    }

    private var statusBadge: some View {
        Text(vote.status.rawValue.uppercased())
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(vote.status == .open ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
            .foregroundColor(vote.status == .open ? .green : .gray)
            .cornerRadius(4)
    }
}

struct VoteOptionRow: View {
    let option: VoteOption
    let isSelected: Bool
    let isClosed: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(option.text)
                    .font(.subheadline)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.oceanBlue)
                }

                Text("\(option.votes)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isClosed ? .primary : .secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Theme.oceanBlue.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Theme.oceanBlue : Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isClosed)
    }
}

// MARK: - Member Row

struct MemberRowView: View {
    let member: GroupMember

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(roleColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Text(member.avatarInitials)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(roleColor)
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(member.userName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(member.role.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Role badge
            if member.role == .organizer {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(Theme.surface)
        .cornerRadius(12)
    }

    private var roleColor: Color {
        switch member.role {
        case .organizer: return .orange
        case .editor: return Theme.oceanBlue
        case .viewer: return .gray
        }
    }
}

// MARK: - Add Expense Sheet

struct AddExpenseSheet: View {
    @Binding var plan: GroupPlan
    @Environment(\.dismiss) private var dismiss

    @State private var description = ""
    @State private var amount = ""
    @State private var paidBy = ""
    @State private var splitType: SplitType = .equal
    @State private var selectedMembers: Set<String> = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Expense Details") {
                    TextField("Description", text: $description)

                    TextField("Amount ($)", text: $amount)
                }

                Section("Paid By") {
                    Picker("Who paid?", selection: $paidBy) {
                        Text("Select...").tag("")
                        ForEach(plan.members) { member in
                            Text(member.userName).tag(member.userId)
                        }
                    }
                }

                Section("Split Type") {
                    Picker("Split", selection: $splitType) {
                        ForEach(SplitType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Split Among") {
                    ForEach(plan.members) { member in
                        Toggle(member.userName, isOn: Binding(
                            get: { selectedMembers.contains(member.userId) },
                            set: { isOn in
                                if isOn { selectedMembers.insert(member.userId) }
                                else { selectedMembers.remove(member.userId) }
                            }
                        ))
                    }
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addExpense()
                        dismiss()
                    }
                    .disabled(description.isEmpty || amount.isEmpty || paidBy.isEmpty)
                }
            }
        }
        .onAppear {
            selectedMembers = Set(plan.members.map { $0.userId })
            if let first = plan.members.first {
                paidBy = first.userId
            }
        }
    }

    private func addExpense() {
        guard let amountDouble = Double(amount),
              let payer = plan.members.first(where: { $0.userId == paidBy }) else { return }

        let expense = GroupExpense(
            id: UUID(),
            paidBy: paidBy,
            paidByName: payer.userName,
            amount: amountDouble,
            currency: "USD",
            description: description,
            splitType: splitType,
            splitAmong: Array(selectedMembers),
            date: Date()
        )

        plan.expenses.append(expense)
    }
}

// MARK: - Create Vote Sheet

struct CreateVoteSheet: View {
    @Binding var plan: GroupPlan
    @Environment(\.dismiss) private var dismiss

    @State private var question = ""
    @State private var optionsText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Question") {
                    TextField("e.g., Where should we go for dinner?", text: $question)
                }

                Section("Options (one per line)") {
                    TextEditor(text: $optionsText)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("Create Vote")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createVote()
                        dismiss()
                    }
                    .disabled(question.isEmpty || optionsText.isEmpty)
                }
            }
        }
    }

    private func createVote() {
        let options = optionsText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard options.count >= 2 else { return }

        let vote = GroupVote(
            id: UUID(),
            question: question,
            options: options.map { VoteOption(id: UUID(), text: $0, votes: 0) },
            votedBy: [],
            closedAt: nil,
            status: .open
        )

        plan.votes.append(vote)
    }
}

// MARK: - ViewModel

final class GroupPlanningViewModel: ObservableObject {
    @Published var plan: GroupPlan

    private let tripId: UUID
    private let socialService = TravelSocialService.shared

    init(tripId: UUID) {
        self.tripId = tripId
        self.plan = GroupPlan(
            id: UUID(),
            tripId: tripId,
            members: [],
            expenses: [],
            votes: [],
            designatedOrganizer: nil
        )
    }

    func loadPlan() {
        plan = socialService.getOrCreateGroupPlan(for: tripId)
        // Add sample vote for demo
        if plan.votes.isEmpty {
            _ = socialService.createVote(
                in: &plan,
                question: "Where should we go for dinner?",
                options: ["Sushi Palace", "Local Bistro", "Rooftop Bar", "Street Food Market"]
            )
        }
    }

    func castVote(voteId: UUID, optionId: UUID) {
        socialService.castVote(in: &plan, voteId: voteId, optionId: optionId)
        objectWillChange.send()
    }

    func closeVote(voteId: UUID) {
        socialService.closeVote(in: &plan, voteId: voteId)
        objectWillChange.send()
    }

    func calculateSplits() -> [String: Double] {
        socialService.calculateSplits(for: plan)
    }
}
