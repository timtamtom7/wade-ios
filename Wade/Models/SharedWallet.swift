import Foundation

// MARK: - Shared Wallet

struct SharedWallet: Codable {
    var id: UUID
    var name: String
    var members: [WalletMember]
    var transactions: [SharedTransaction]
    var monthlyBudget: SharedBudget?
    var createdAt: Date

    init(id: UUID = UUID(), name: String = "Our Wallet", members: [WalletMember] = [], transactions: [SharedTransaction] = [], monthlyBudget: SharedBudget? = nil, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.members = members
        self.transactions = transactions
        self.monthlyBudget = monthlyBudget
        self.createdAt = createdAt
    }
}

struct WalletMember: Identifiable, Codable {
    let id: UUID
    var name: String
    var colorHex: String

    init(id: UUID = UUID(), name: String, colorHex: String) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }
}

struct SharedTransaction: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let category: String
    let note: String
    let date: Date
    let paidBy: UUID  // member ID
    let splitEvenly: Bool
    let splitAmounts: [UUID: Double]?  // member ID -> amount owed
    let currencyCode: String

    init(
        id: UUID = UUID(),
        amount: Double,
        category: String,
        note: String,
        date: Date = Date(),
        paidBy: UUID,
        splitEvenly: Bool = true,
        splitAmounts: [UUID: Double]? = nil,
        currencyCode: String = "USD"
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.note = note
        self.date = date
        self.paidBy = paidBy
        self.splitEvenly = splitEvenly
        self.splitAmounts = splitAmounts
        self.currencyCode = currencyCode
    }
}

struct SharedBudget: Codable {
    var limit: Double
    var currencyCode: String

    init(limit: Double, currencyCode: String = "USD") {
        self.limit = limit
        self.currencyCode = currencyCode
    }
}

// MARK: - Shared Wallet Manager

@MainActor
final class SharedWalletManager: ObservableObject {
    static let shared = SharedWalletManager()

    private let walletKey = "wade_shared_wallet"
    @Published var wallet: SharedWallet?
    @Published var isEnabled: Bool = false

    private init() {
        loadWallet()
    }

    private func loadWallet() {
        if let data = UserDefaults.standard.data(forKey: walletKey),
           let saved = try? JSONDecoder().decode(SharedWallet.self, from: data) {
            wallet = saved
            isEnabled = true
        }
    }

    private func save() {
        if let w = wallet, let data = try? JSONEncoder().encode(w) {
            UserDefaults.standard.set(data, forKey: walletKey)
        }
    }

    func createWallet(name: String, members: [WalletMember]) {
        var newWallet = SharedWallet(name: name, members: members)
        wallet = newWallet
        isEnabled = true
        save()
    }

    func addMember(name: String, colorHex: String) {
        guard var w = wallet else { return }
        let member = WalletMember(name: name, colorHex: colorHex)
        w.members.append(member)
        wallet = w
        save()
    }

    func removeMember(id: UUID) {
        guard var w = wallet else { return }
        w.members.removeAll { $0.id == id }
        wallet = w
        save()
    }

    func addSharedExpense(amount: Double, category: String, note: String, paidBy: UUID, splitEvenly: Bool = true, splitAmounts: [UUID: Double]? = nil) {
        guard var w = wallet else { return }
        let tx = SharedTransaction(
            amount: amount,
            category: category,
            note: note,
            date: Date(),
            paidBy: paidBy,
            splitEvenly: splitEvenly,
            splitAmounts: splitAmounts
        )
        w.transactions.append(tx)
        wallet = w
        save()
    }

    func setSharedBudget(limit: Double) {
        guard var w = wallet else { return }
        w.monthlyBudget = SharedBudget(limit: limit)
        wallet = w
        save()
    }

    func clearSharedBudget() {
        guard var w = wallet else { return }
        w.monthlyBudget = nil
        wallet = w
        save()
    }

    func deleteWallet() {
        wallet = nil
        isEnabled = false
        UserDefaults.standard.removeObject(forKey: walletKey)
    }

    func totalSpentThisMonth() -> Double {
        guard let w = wallet else { return 0 }
        let calendar = Calendar.current
        let now = Date()
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!

        return w.transactions
            .filter { $0.date >= monthStart && $0.date < monthEnd }
            .reduce(0) { $0 + $1.amount }
    }

    func categorySpendingThisMonth() -> [String: Double] {
        guard let w = wallet else { return [:] }
        let calendar = Calendar.current
        let now = Date()
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!

        var result: [String: Double] = [:]
        for tx in w.transactions where tx.date >= monthStart && tx.date < monthEnd {
            result[tx.category, default: 0] += tx.amount
        }
        return result
    }

    func spendingByMember() -> [UUID: Double] {
        guard let w = wallet else { return [:] }
        let calendar = Calendar.current
        let now = Date()
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!

        var result: [UUID: Double] = [:]
        for tx in w.transactions where tx.date >= monthStart {
            result[tx.paidBy, default: 0] += tx.amount
        }
        return result
    }

    func owes() -> [(from: UUID, to: UUID, amount: Double)] {
        guard let w = wallet else { return [] }

        // Calculate who owes whom based on shared transactions
        var balances: [UUID: Double] = [:]
        for member in w.members {
            balances[member.id] = 0
        }

        for tx in w.transactions {
            let splitAmount = tx.splitEvenly ? tx.amount / Double(w.members.count) : tx.amount
            balances[tx.paidBy, default: 0] += tx.amount - splitAmount

            for member in w.members where member.id != tx.paidBy {
                let owed = tx.splitEvenly ? tx.amount / Double(w.members.count) : (tx.splitAmounts?[member.id] ?? splitAmount)
                balances[member.id, default: 0] -= owed
            }
        }

        // Simplify debts
        var creditors: [(UUID, Double)] = []
        var debtors: [(UUID, Double)] = []

        for (id, balance) in balances {
            if balance > 0.01 {
                creditors.append((id, balance))
            } else if balance < -0.01 {
                debtors.append((id, -balance))
            }
        }

        var owesList: [(from: UUID, to: UUID, amount: Double)] = []
        var dIdx = 0

        while dIdx < debtors.count {
            let (debtor, debtAmt) = debtors[dIdx]
            var cIdx = 0
            while cIdx < creditors.count && debtors[dIdx].1 > 0.01 {
                let (creditor, creditAmt) = creditors[cIdx]
                let payment = min(debtors[dIdx].1, creditors[cIdx].1)
                if payment > 0.01 {
                    owesList.append((from: debtor, to: creditor, amount: payment))
                    debtors[dIdx].1 -= payment
                    creditors[cIdx].1 -= payment
                }
                if creditors[cIdx].1 < 0.01 { cIdx += 1 }
            }
            dIdx += 1
        }

        return owesList
    }
}
