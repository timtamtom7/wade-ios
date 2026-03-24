import Foundation

/// Manages multi-currency settings and conversions
@MainActor
final class CurrencyService: ObservableObject {
    static let shared = CurrencyService()

    private let primaryCurrencyKey = "wade_primary_currency"

    /// Supported currencies with symbol and name
    static let supportedCurrencies: [(code: String, symbol: String, name: String)] = [
        ("USD", "$", "US Dollar"),
        ("GBP", "£", "British Pound"),
        ("EUR", "€", "Euro"),
        ("JPY", "¥", "Japanese Yen"),
        ("CAD", "CA$", "Canadian Dollar"),
        ("AUD", "A$", "Australian Dollar"),
        ("CHF", "CHF", "Swiss Franc"),
        ("INR", "₹", "Indian Rupee"),
        ("CNY", "¥", "Chinese Yuan"),
        ("MXN", "MX$", "Mexican Peso")
    ]

    /// Conversion rates to USD (as of base)
    /// In production, fetch live rates. These are static for offline use.
    private let usdRates: [String: Double] = [
        "USD": 1.0,
        "GBP": 1.27,
        "EUR": 1.08,
        "JPY": 0.0067,
        "CAD": 0.74,
        "AUD": 0.65,
        "CHF": 1.12,
        "INR": 0.012,
        "CNY": 0.14,
        "MXN": 0.058
    ]

    var primaryCurrencyCode: String {
        get {
            UserDefaults.standard.string(forKey: primaryCurrencyKey) ?? "USD"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: primaryCurrencyKey)
        }
    }

    var primaryCurrencySymbol: String {
        Self.supportedCurrencies.first { $0.code == primaryCurrencyCode }?.symbol ?? "$"
    }

    /// Format amount in primary currency
    func formatCurrency(_ amount: Double, currencyCode: String? = nil) -> String {
        let code = currencyCode ?? primaryCurrencyCode
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.string(from: NSNumber(value: amount)) ?? "\(symbolFor(code))\(String(format: "%.2f", amount))"
    }

    /// Format amount in original currency (with symbol)
    func formatOriginal(_ amount: Double, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: amount)) ?? "\(symbolFor(currencyCode))\(String(format: "%.2f", amount))"
    }

    /// Convert amount from one currency to primary display currency
    func convertToPrimary(_ amount: Double, fromCurrency: String) -> Double {
        guard fromCurrency != primaryCurrencyCode else { return amount }
        guard let toUSD = usdRates[fromCurrency] else { return amount }
        guard let fromUSD = usdRates[primaryCurrencyCode], fromUSD > 0 else { return amount }
        return amount * toUSD / fromUSD
    }

    /// Convert amount from primary currency to another currency
    func convertFromPrimary(_ amount: Double, toCurrency: String) -> Double {
        guard primaryCurrencyCode != toCurrency else { return amount }
        guard let fromUSD = usdRates[primaryCurrencyCode], fromUSD > 0 else { return amount }
        guard let toUSD = usdRates[toCurrency] ?? usdRates["USD"] else { return amount }
        return amount * fromUSD / toUSD
    }

    /// Show both original and converted amounts
    func formatDual(_ amount: Double, originalCurrency: String) -> String {
        if originalCurrency == primaryCurrencyCode {
            return formatCurrency(amount, currencyCode: originalCurrency)
        }
        let converted = convertToPrimary(amount, fromCurrency: originalCurrency)
        return "\(formatOriginal(amount, currencyCode: originalCurrency)) (\(formatCurrency(converted)))"
    }

    private func symbolFor(_ code: String) -> String {
        Self.supportedCurrencies.first { $0.code == code }?.symbol ?? "$"
    }

    /// Returns true if the currency code is different from primary
    func needsConversion(_ currencyCode: String) -> Bool {
        currencyCode != primaryCurrencyCode
    }
}
