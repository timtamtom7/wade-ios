import Foundation
import NaturalLanguage

struct ParsedExpense {
    let amount: Double
    let type: TransactionType
    let category: String
    let rawText: String
    let detectedCurrency: String

    var transaction: Transaction {
        Transaction(
            amount: amount,
            type: type,
            category: category,
            note: rawText,
            currencyCode: detectedCurrency
        )
    }
}

struct ExpenseParser: Sendable {
    private static let incomeKeywords = ["salary", "paid", "income", "got paid", "received", "earned", "deposit", "paycheck", "wage", "freelance", "consulting", "bonus", "dividend", "refund"]
    private static let expenseKeywords = ["spent", "bought", "paid", "for", "on", "at", "with", "buy", "purchase", "pickup", "pick up"]

    private static let categoryKeywords: [String: [String]] = [
        "Food": ["lunch", "dinner", "breakfast", "meal", "food", "snack", "coffee", "tea", "drink", "restaurant", "cafe", "burger", "pizza", "sushi", "taco", "sandwich", "smoothie", "juice", "bread", "cake", "cookie", "donut", "pastry", "cereal", "yogurt", "salad", "soup", "wrap", "noodle", "pasta"],
        "Groceries": ["groceries", "grocery", "supermarket", "market", "whole foods", "trader joe", "safeway", "kroger", "costco", "walmart", "target", "aldi", "publix", "wegmans", "sainsbury", "tesco", "asda", "morrisons", "co-op"],
        "Transport": ["uber", "lyft", "taxi", "bus", "train", "metro", "subway", "gas", "fuel", "parking", "toll", "transit", "tfl", "amtrak", "flight", "airline", "petrol", "diesel", " charge", "charging", "ev charge"],
        "Shopping": ["clothes", "clothing", "shoes", "amazon", "shop", "shopping", "store", "mall", "online", "ebay", "etsy", "fashion", "accessories", "jewelry", "watch", "bag", "wallet"],
        "Entertainment": ["movie", "netflix", "spotify", "game", "concert", "ticket", "hulu", "disney", "subscription", "hbo", "apple tv", "youtube", "twitch", "steam", "playstation", "xbox", "cinema", "theatre", "theater", "museum", "exhibition"],
        "Health": ["doctor", "pharmacy", "medicine", "hospital", "gym", "fitness", "health", "dentist", "optician", "glasses", "prescription", "therapy", "counselling", "yoga", "pilates", "massage", "spa", "beauty", "haircut", "barber", "nail"],
        "Bills": ["rent", "utility", "electric", "water", "internet", "phone", "bill", "insurance", "broadband", "heating", "council tax", "mortgage", "lease", "subscription", "membership"],
        "Travel": ["hotel", "airbnb", "vacation", "trip", "travel", "booking", "hostel", "motel", "resort", "camping", "tour", "cruise", "visa", "passport", "travel insurance"],
        "Education": ["book", "course", " tuition", "school", "university", "online course", "udemy", "coursera", "masterclass", "skillshare", "textbook", "stationery", "exam", "tuition", "student"],
        "Salary": ["salary", "paycheck", "wage", "income", "freelance", "consulting fee", "bonus", "commission"],
        "Other": []
    ]

    // MARK: - Currency Detection

    enum Currency: String {
        case gbp = "£"
        case usd = "$"
        case eur = "€"
        case jpy = "¥"
        case unknown = ""

        var code: String {
            switch self {
            case .gbp: return "GBP"
            case .usd: return "USD"
            case .eur: return "EUR"
            case .jpy: return "JPY"
            case .unknown: return "USD"
            }
        }
    }

    func parse(_ input: String) -> ParsedExpense? {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)

        let amount = extractAmount(from: text)
        guard let amountValue = amount.value else { return nil }

        let type = detectType(from: text)
        let category = detectCategory(from: text)
        let currency = amount.currency

        return ParsedExpense(
            amount: amountValue,
            type: type,
            category: category,
            rawText: input,
            detectedCurrency: currency.code
        )
    }

    // MARK: - Amount Extraction

    private struct ExtractionResult {
        let value: Double?
        let currency: Currency
    }

    private func extractAmount(from text: String) -> ExtractionResult {
        let patterns: [(pattern: String, currency: Currency)] = [
            // £ symbol with optional spaces
            ("£\\s*([0-9]+(?:[.,][0-9]{1,2})?)", .gbp),
            // $ symbol with optional spaces
            ("\\$\\s*([0-9]+(?:[.,][0-9]{1,2})?)", .usd),
            // € symbol with optional spaces
            ("€\\s*([0-9]+(?:[.,][0-9]{1,2})?)", .eur),
            // ¥ symbol with optional spaces
            ("¥\\s*([0-9]+(?:[.,][0-9]{1,2})?)", .jpy),
            // Currency word patterns (after amount)
            ("([0-9]+(?:[.,][0-9]{1,2})?)\\s*(?:pounds?|lbs?)", .gbp),
            ("([0-9]+(?:[.,][0-9]{1,2})?)\\s*(?:dollars?|usd)", .usd),
            ("([0-9]+(?:[.,][0-9]{1,2})?)\\s*(?:euros?|eur)", .eur),
            ("([0-9]+(?:[.,][0-9]{1,2})?)\\s*(?:yen|jp[yY])", .jpy),
            // Bare number (default to GBP context for UK users)
            ("([0-9]+(?:[.,][0-9]{1,2})?)", .gbp)
        ]

        for (pattern, currency) in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(text.startIndex..., in: text)
                if let match = regex.firstMatch(in: text, options: [], range: range) {
                    if let amountRange = Range(match.range(at: 1), in: text) {
                        var amountStr = String(text[amountRange])
                        // Normalize separator: if both comma and period exist, use the last as decimal
                        amountStr = amountStr.replacingOccurrences(of: ",", with: ".")
                        // If comma is the only separator (European format), it stays
                        if let amount = Double(amountStr) {
                            return ExtractionResult(value: amount, currency: currency)
                        }
                    }
                }
            }
        }
        return ExtractionResult(value: nil, currency: .unknown)
    }

    // MARK: - Type Detection

    private func detectType(from text: String) -> TransactionType {
        for keyword in Self.incomeKeywords {
            if text.contains(keyword) {
                return .income
            }
        }
        return .expense
    }

    // MARK: - Category Detection

    private func detectCategory(from text: String) -> String {
        let lowercased = text.lowercased()

        for (category, keywords) in Self.categoryKeywords {
            for keyword in keywords {
                if lowercased.contains(keyword) {
                    return category
                }
            }
        }
        return "Other"
    }

    // MARK: - Budget Limit Parsing

    func parseBudgetLimit(_ text: String) -> Double? {
        let lowercased = text.lowercased()

        // Pattern: "set budget to £500" or "budget of £500" or "limit of $1000"
        let patterns = [
            "(?:budget|limit|spend limit|monthly limit)\\s*(?:of|to|at|:)?\\s*([£$€¥]?\\s*[0-9]+(?:[.,][0-9]+)?)",
            "([£$€¥]?\\s*[0-9]+(?:[.,][0-9]+)?)\\s*(?:budget|limit|per month)",
            "don't spend more than\\s*([£$€¥]?\\s*[0-9]+(?:[.,][0-9]+)?)",
            "max\\s*([£$€¥]?\\s*[0-9]+(?:[.,][0-9]+)?)"
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(lowercased.startIndex..., in: lowercased)
                if let match = regex.firstMatch(in: lowercased, options: [], range: range) {
                    if let amountRange = Range(match.range(at: 1), in: lowercased) {
                        var amountStr = String(lowercased[amountRange])
                        amountStr = amountStr.replacingOccurrences(of: "£", with: "")
                            .replacingOccurrences(of: "$", with: "")
                            .replacingOccurrences(of: "€", with: "")
                            .replacingOccurrences(of: "¥", with: "")
                            .replacingOccurrences(of: " ", with: "")
                            .replacingOccurrences(of: ",", with: ".")
                        if let amount = Double(amountStr) {
                            return amount
                        }
                    }
                }
            }
        }
        return nil
    }

    // MARK: - Recurring Frequency Parsing

    func parseRecurringFrequency(_ text: String) -> RecurringExpense.RecurringFrequency? {
        let lowercased = text.lowercased()

        if lowercased.contains("weekly") || lowercased.contains("every week") {
            return .weekly
        }
        if lowercased.contains("biweekly") || lowercased.contains("bi-weekly") || lowercased.contains("every two weeks") || lowercased.contains("fortnightly") {
            return .biweekly
        }
        if lowercased.contains("monthly") || lowercased.contains("every month") || lowercased.contains("each month") {
            return .monthly
        }
        if lowercased.contains("yearly") || lowercased.contains("annual") || lowercased.contains("every year") {
            return .yearly
        }
        return nil
    }

    // MARK: - Multi-Currency Text Patterns

    /// Returns true if the input looks like an expense or income entry
    func isExpenseInput(_ text: String) -> Bool {
        let lowercased = text.lowercased()

        // Has a currency symbol
        if lowercased.contains("£") || lowercased.contains("$") || lowercased.contains("€") || lowercased.contains("¥") {
            return true
        }

        // Has a number
        if extractAmount(from: lowercased).value != nil {
            return true
        }

        // Contains common expense/income keywords
        for keyword in Self.incomeKeywords + Self.expenseKeywords {
            if lowercased.contains(keyword) {
                return true
            }
        }

        return false
    }
}
