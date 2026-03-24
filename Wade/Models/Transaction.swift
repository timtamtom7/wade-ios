import Foundation

enum TransactionType: String, Codable {
    case expense
    case income
}

struct Transaction: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let type: TransactionType
    let category: String
    let note: String
    let date: Date

    init(id: UUID = UUID(), amount: Double, type: TransactionType, category: String, note: String, date: Date = Date()) {
        self.id = id
        self.amount = amount
        self.type = type
        self.category = category
        self.note = note
        self.date = date
    }
}
