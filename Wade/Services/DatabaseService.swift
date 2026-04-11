import Foundation
import SQLite

@MainActor
final class DatabaseService {
    static let shared = DatabaseService()

    private var db: Connection?

    private let transactions = Table("transactions")
    private let id = SQLite.Expression<String>("id")
    private let amount = SQLite.Expression<Double>("amount")
    private let type = SQLite.Expression<String>("type")
    private let category = SQLite.Expression<String>("category")
    private let note = SQLite.Expression<String>("note")
    private let date = SQLite.Expression<Date>("date")
    private let currencyCode = SQLite.Expression<String>("currency_code")
    private let isRecurringCol = SQLite.Expression<Bool>("is_recurring")

    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("wade.sqlite3")
            db = try Connection(path.path)
            try createTables()
        } catch {
            print("Database setup error: \(error)")
        }
    }

    private func createTables() throws {
        try db?.run(transactions.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(amount)
            t.column(type)
            t.column(category)
            t.column(note)
            t.column(date)
            t.column(currencyCode)
            t.column(isRecurringCol)
        })
    }

    func insert(_ transaction: Transaction) throws {
        let insert = transactions.insert(
            id <- transaction.id.uuidString,
            amount <- transaction.amount,
            type <- transaction.type.rawValue,
            category <- transaction.category,
            note <- transaction.note,
            date <- transaction.date,
            currencyCode <- transaction.currencyCode,
            isRecurringCol <- transaction.isRecurring
        )
        try db?.run(insert)
    }

    func fetchAll() -> [Transaction] {
        guard let db = db else { return [] }
        var result: [Transaction] = []
        do {
            for row in try db.prepare(transactions.order(date.desc)) {
                if let uuid = UUID(uuidString: row[id]),
                   let txType = TransactionType(rawValue: row[type]) {
                    result.append(Transaction(
                        id: uuid,
                        amount: row[amount],
                        type: txType,
                        category: row[category],
                        note: row[note],
                        date: row[date],
                        isRecurring: row[isRecurringCol],
                        currencyCode: row[currencyCode]
                    ))
                }
            }
        } catch {
            print("Fetch error: \(error)")
        }
        return result
    }

    func fetchThisWeek() -> [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            return []
        }
        return fetchAll().filter { $0.date >= weekStart }
    }

    func fetchThisMonth() -> [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)
        guard let monthStart = calendar.date(from: components) else {
            return []
        }
        return fetchAll().filter { $0.date >= monthStart }
    }

    func fetchMonth(year: Int, month: Int) -> [Transaction] {
        let calendar = Calendar.current
        guard let monthStart = calendar.date(from: DateComponents(year: year, month: month)),
              let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
            return []
        }
        return fetchAll().filter { $0.date >= monthStart && $0.date < monthEnd }
    }

    func fetchLastMonth() -> [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        guard let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart) else {
            return []
        }
        return fetchAll().filter { $0.date >= lastMonthStart && $0.date < currentMonthStart }
    }

    func search(query: String) -> [Transaction] {
        let lowercased = query.lowercased()
        return fetchAll().filter {
            $0.category.lowercased().contains(lowercased) ||
            $0.note.lowercased().contains(lowercased) ||
            String(format: "%.2f", $0.amount).contains(lowercased)
        }
    }

    func weeklyStats() -> (expenses: Double, income: Double, net: Double) {
        let thisWeek = fetchThisWeek()
        let expenses = thisWeek.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        let income = thisWeek.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        return (expenses, income, income - expenses)
    }

    func monthlyStats() -> (expenses: Double, income: Double, net: Double) {
        let thisMonth = fetchThisMonth()
        let expenses = thisMonth.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        let income = thisMonth.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        return (expenses, income, income - expenses)
    }
}
