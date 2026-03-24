import Foundation

@MainActor
final class RecurringExpenseService {
    static let shared = RecurringExpenseService()

    private let recurringKey = "wade_recurring_expenses"

    private init() {}

    var recurringExpenses: [RecurringExpense] {
        guard let data = UserDefaults.standard.data(forKey: recurringKey),
              let items = try? JSONDecoder().decode([RecurringExpense].self, from: data) else {
            return []
        }
        return items
    }

    func markAsRecurring(_ transaction: Transaction, frequency: RecurringExpense.RecurringFrequency) {
        var recurring = recurringExpenses

        // Remove existing if already exists
        recurring.removeAll { $0.category == transaction.category && $0.label == transaction.note }

        let newRecurring = RecurringExpense(
            id: UUID(),
            label: transaction.note.isEmpty ? transaction.category : transaction.note,
            estimatedAmount: transaction.amount,
            frequency: frequency,
            category: transaction.category,
            note: transaction.note,
            lastSeen: transaction.date,
            lastAmount: transaction.amount
        )

        recurring.append(newRecurring)
        save(recurring)
    }

    func removeRecurring(_ id: UUID) {
        var recurring = recurringExpenses
        recurring.removeAll { $0.id == id }
        save(recurring)
    }

    func totalRecurringThisMonth() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!

        var total = 0.0
        for item in recurringExpenses {
            let nextDate = item.nextExpectedDate
            if nextDate >= monthStart && nextDate < monthEnd {
                total += item.estimatedAmount
            }
        }
        return total
    }

    func detectRecurringPatterns(from transactions: [Transaction]) -> [RecurringDetection] {
        guard transactions.count >= 3 else { return [] }

        let expenses = transactions.filter { $0.type == .expense }

        // Group by category
        var byCategory: [String: [Transaction]] = [:]
        for tx in expenses {
            byCategory[tx.category, default: []].append(tx)
        }

        var detections: [RecurringDetection] = []

        for (category, txs) in byCategory {
            guard txs.count >= 3 else { continue }

            let sorted = txs.sorted { $0.date < $1.date }
            let intervals = zip(sorted, sorted.dropFirst()).map { ($1.date.timeIntervalSince($0.date)) }

            let avgInterval = intervals.reduce(0, +) / Double(intervals.count)

            // Determine frequency
            let dayInterval = avgInterval / 86400
            let frequency: String
            if dayInterval >= 5 && dayInterval <= 9 {
                frequency = "weekly"
            } else if dayInterval >= 12 && dayInterval <= 18 {
                frequency = "bi-weekly"
            } else if dayInterval >= 25 && dayInterval <= 35 {
                frequency = "monthly"
            } else {
                continue // Not a recognizable pattern
            }

            let avgAmount = txs.reduce(0) { $0 + $1.amount } / Double(txs.count)
            let lastDate = sorted.last!.date

            let detection = RecurringDetection(
                category: category,
                estimatedAmount: avgAmount,
                frequency: frequency,
                sampleCount: txs.count,
                lastDate: lastDate
            )
            detections.append(detection)
        }

        return detections
    }

    func upcomingBills(withinDays: Int = 7) -> [RecurringExpense] {
        let calendar = Calendar.current
        let now = Date()
        let future = calendar.date(byAdding: .day, value: withinDays, to: now)!

        return recurringExpenses.filter { item in
            let next = item.nextExpectedDate
            return next >= now && next <= future
        }
    }

    private func save(_ items: [RecurringExpense]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: recurringKey)
        }
    }
}
