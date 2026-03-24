import Foundation
import NaturalLanguage

struct ParsedExpense {
    let amount: Double
    let type: TransactionType
    let category: String
    let rawText: String

    var transaction: Transaction {
        Transaction(
            amount: amount,
            type: type,
            category: category,
            note: rawText
        )
    }
}

struct ExpenseParser {
    private static let incomeKeywords = ["salary", "paid", "income", "got paid", "received", "earned", "deposit", "paycheck", "wage"]
    private static let expenseKeywords = ["spent", "bought", "bought", "paid", "for", "on", "at", "with"]

    private static let categoryKeywords: [String: [String]] = [
        "Food": ["lunch", "dinner", "breakfast", "meal", "food", "snack", "coffee", "tea", "drink", "restaurant", "cafe", "burger", "pizza", "sushi", "taco"],
        "Groceries": ["groceries", "grocery", "supermarket", "market", "whole foods", "trader joe", "safeway", "kroger", "costco", "walmart", "target"],
        "Transport": ["uber", "lyft", "taxi", "bus", "train", "metro", "subway", "gas", "fuel", "parking", "toll", "transit"],
        "Shopping": ["clothes", "clothing", "shoes", "amazon", "shop", "shopping", "store", "mall", "online"],
        "Entertainment": ["movie", "netflix", "spotify", "game", "concert", "ticket", "hulu", "disney", "subscription"],
        "Health": ["doctor", "pharmacy", "medicine", "hospital", "gym", "fitness", "health"],
        "Bills": ["rent", "utility", "electric", "water", "internet", "phone", "bill", "insurance"],
        "Travel": ["hotel", "flight", "airbnb", "vacation", "trip", "travel", "booking"],
        "Education": ["book", "course", " tuition", "school", "university", "online course", "udemy", "coursera"],
        "Other": []
    ]

    func parse(_ input: String) -> ParsedExpense? {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let amount = extractAmount(from: text)
        guard let amountValue = amount else { return nil }

        let type = detectType(from: text)
        let category = detectCategory(from: text)

        return ParsedExpense(
            amount: amountValue,
            type: type,
            category: category,
            rawText: input
        )
    }

    private func extractAmount(from text: String) -> Double? {
        // Pattern: £X, $X, X USD, dollars, pounds
        let patterns = [
            "£\\s*([0-9]+(?:[.,][0-9]+)?)",
            "\\$\\s*([0-9]+(?:[.,][0-9]+)?)",
            "([0-9]+(?:[.,][0-9]+)?)\\s*(?:pounds?|lbs?)",
            "([0-9]+(?:[.,][0-9]+)?)\\s*(?:dollars?|usd)",
            "([0-9]+(?:[.,][0-9]+)?)"
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(text.startIndex..., in: text)
                if let match = regex.firstMatch(in: text, options: [], range: range) {
                    if let amountRange = Range(match.range(at: 1), in: text) {
                        var amountStr = String(text[amountRange])
                        amountStr = amountStr.replacingOccurrences(of: ",", with: ".")
                        if let amount = Double(amountStr) {
                            return amount
                        }
                    }
                }
            }
        }
        return nil
    }

    private func detectType(from text: String) -> TransactionType {
        for keyword in Self.incomeKeywords {
            if text.contains(keyword) {
                return .income
            }
        }
        return .expense
    }

    private func detectCategory(from text: String) -> String {
        for (category, keywords) in Self.categoryKeywords {
            for keyword in keywords {
                if text.contains(keyword) {
                    return category
                }
            }
        }
        return "Other"
    }
}
