import SwiftUI

struct CurrencyView: View {
    @State private var amount: String = "100"
    @State private var fromCurrency: Currency = .usd
    @State private var toCurrency: Currency = .eur
    @State private var convertedAmount: Double = 0
    @State private var tipPercent: Double = 15
    @State private var billAmount: String = ""
    @State private var calculatedTip: Double = 0
    @State private var totalWithTip: Double = 0
    @State private var selectedTab: CurrencyTab = .converter

    enum CurrencyTab: String, CaseIterable {
        case converter = "Converter"
        case tip = "Tip"
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            Picker("", selection: $selectedTab) {
                ForEach(CurrencyTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Theme.cardBg)

            if selectedTab == .converter {
                converterSection
            } else {
                tipSection
            }
        }
        .background(Theme.surface)
        .onAppear {
            convert()
            calculateTip()
        }
    }

    private var headerSection: some View {
        HStack {
            Image(systemName: "dollarsign.circle.fill")
                .font(.title3)
                .foregroundColor(Theme.oceanBlue)
            Text("Currency & Tips")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
            Spacer()
        }
        .padding(16)
        .background(Theme.cardBg)
    }

    private var converterSection: some View {
        ScrollView {
            VStack(spacing: 16) {
                amountInputSection
                currencySelectorSection
                resultSection
                ratesInfoSection
            }
            .padding(16)
        }
    }

    private var amountInputSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Amount")
                .font(.caption)
                .foregroundColor(Theme.textPrimary.opacity(0.6))

            HStack {
                Text(fromCurrency.symbol)
                    .font(.title2)
                    .foregroundColor(Theme.oceanBlue)
                TextField("0.00", text: $amount)
                    .textFieldStyle(.plain)
                    .font(.title2)
                    
                    .onChange(of: amount) { _, _ in convert() }
            }
            .padding(12)
            .background(Theme.surface)
            .cornerRadius(10)
        }
        .padding(16)
        .background(Theme.cardBg)
        .cornerRadius(12)
    }

    private var currencySelectorSection: some View {
        VStack(spacing: 12) {
            HStack {
                CurrencyPicker(selected: $fromCurrency, label: "From")
                    .onChange(of: fromCurrency) { _, _ in convert() }

                Button(action: swapCurrencies) {
                    Image(systemName: "arrow.left.arrow.right")
                        .foregroundColor(Theme.oceanBlue)
                        .padding(8)
                        .background(Theme.surface)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)

                CurrencyPicker(selected: $toCurrency, label: "To")
                    .onChange(of: toCurrency) { _, _ in convert() }
            }
        }
        .padding(16)
        .background(Theme.cardBg)
        .cornerRadius(12)
    }

    private var resultSection: some View {
        VStack(spacing: 8) {
            Text("Converted Amount")
                .font(.caption)
                .foregroundColor(Theme.textPrimary.opacity(0.6))

            Text("\(toCurrency.symbol) \(String(format: "%.2f", convertedAmount))")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(Theme.oceanBlue)

            Text("1 \(fromCurrency.code) = \(String(format: "%.4f", fromCurrency.rate)) \(toCurrency.code)")
                .font(.caption2)
                .foregroundColor(Theme.textPrimary.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            LinearGradient(
                colors: [Theme.oceanBlue.opacity(0.1), Theme.skyBlue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .padding(16)
        .background(Theme.cardBg)
        .cornerRadius(16)
    }

    private var ratesInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(Theme.oceanBlue)
                Text("Exchange Rates")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.textPrimary)
            }
            Text("Rates updated daily. For accurate rates, check your bank or a live forex source before traveling.")
                .font(.caption2)
                .foregroundColor(Theme.textPrimary.opacity(0.5))
        }
        .padding(12)
        .background(Theme.cardBg)
        .cornerRadius(10)
    }

    private var tipSection: some View {
        ScrollView {
            VStack(spacing: 16) {
                billInputSection
                tipPercentSection
                tipResultSection
            }
            .padding(16)
        }
    }

    private var billInputSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Bill Amount")
                .font(.caption)
                .foregroundColor(Theme.textPrimary.opacity(0.6))

            HStack {
                Text("$")
                    .font(.title2)
                    .foregroundColor(Theme.sunsetOrange)
                TextField("0.00", text: $billAmount)
                    .textFieldStyle(.plain)
                    .font(.title2)
                    
                    .onChange(of: billAmount) { _, _ in calculateTip() }
            }
            .padding(12)
            .background(Theme.surface)
            .cornerRadius(10)
        }
        .padding(16)
        .background(Theme.cardBg)
        .cornerRadius(12)
    }

    private var tipPercentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Tip Percentage")
                    .font(.caption)
                    .foregroundColor(Theme.textPrimary.opacity(0.6))
                Spacer()
                Text("\(Int(tipPercent))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.sunsetOrange)
            }

            HStack(spacing: 8) {
                ForEach([10, 15, 18, 20, 25], id: \.self) { pct in
                    Button(action: {
                        tipPercent = Double(pct)
                        calculateTip()
                    }) {
                        Text("\(pct)%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Int(tipPercent) == pct ? Theme.sunsetOrange : Theme.surface)
                            .foregroundColor(Int(tipPercent) == pct ? .white : Theme.textPrimary)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }

            Slider(value: $tipPercent, in: 0...50, step: 1) { _ in
                calculateTip()
            }
            .tint(Theme.sunsetOrange)
        }
        .padding(16)
        .background(Theme.cardBg)
        .cornerRadius(12)
    }

    private var tipResultSection: some View {
        VStack(spacing: 12) {
            HStack {
                TipResultCard(title: "Tip", amount: calculatedTip, color: Theme.sunsetOrange)
                TipResultCard(title: "Total", amount: totalWithTip, color: Theme.oceanBlue)
            }

            VStack(spacing: 4) {
                Text("Per Person Split")
                    .font(.caption)
                    .foregroundColor(Theme.textPrimary.opacity(0.5))
                Text("\(splitAmount(2).formatted(.currency(code: "USD"))) × 2 people")
                    .font(.subheadline)
                    .foregroundColor(Theme.textPrimary)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Theme.surface)
            .cornerRadius(10)
        }
        .padding(16)
        .background(Theme.cardBg)
        .cornerRadius(12)
    }

    private func convert() {
        let fromRate = fromCurrency.rate
        let toRate = toCurrency.rate
        guard let amountVal = Double(amount), amountVal > 0 else {
            convertedAmount = 0
            return
        }
        let usdAmount = amountVal / fromRate
        convertedAmount = usdAmount * toRate
    }

    private func swapCurrencies() {
        let temp = fromCurrency
        fromCurrency = toCurrency
        toCurrency = temp
        convert()
    }

    private func calculateTip() {
        guard let bill = Double(billAmount), bill > 0 else {
            calculatedTip = 0
            totalWithTip = 0
            return
        }
        calculatedTip = bill * (tipPercent / 100)
        totalWithTip = bill + calculatedTip
    }

    private func splitAmount(_ people: Int) -> Double {
        guard people > 0 else { return totalWithTip }
        return totalWithTip / Double(people)
    }
}

struct CurrencyPicker: View {
    @Binding var selected: Currency
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(Theme.textPrimary.opacity(0.5))

            Menu {
                ForEach(Currency.allCases, id: \.self) { currency in
                    Button(action: { selected = currency }) {
                        HStack {
                            Text(currency.flag)
                            Text("\(currency.code) - \(currency.name)")
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selected.flag)
                        .font(.title3)
                    Text(selected.code)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.textPrimary)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundColor(Theme.textPrimary.opacity(0.4))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Theme.surface)
                .cornerRadius(8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct TipResultCard: View {
    let title: String
    let amount: Double
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(Theme.textPrimary.opacity(0.5))
            Text("$\(String(format: "%.2f", amount))")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Theme.surface)
        .cornerRadius(10)
    }
}

enum Currency: String, CaseIterable {
    case usd, eur, gbp, jpy, aud, cad, chf, cny, inr, mxn, brl, krw, thb, sgd, hkd, nzd, sek, nok, dkk, zar

    var name: String {
        switch self {
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        case .jpy: return "Japanese Yen"
        case .aud: return "Australian Dollar"
        case .cad: return "Canadian Dollar"
        case .chf: return "Swiss Franc"
        case .cny: return "Chinese Yuan"
        case .inr: return "Indian Rupee"
        case .mxn: return "Mexican Peso"
        case .brl: return "Brazilian Real"
        case .krw: return "South Korean Won"
        case .thb: return "Thai Baht"
        case .sgd: return "Singapore Dollar"
        case .hkd: return "Hong Kong Dollar"
        case .nzd: return "New Zealand Dollar"
        case .sek: return "Swedish Krona"
        case .nok: return "Norwegian Krone"
        case .dkk: return "Danish Krone"
        case .zar: return "South African Rand"
        }
    }

    var flag: String {
        switch self {
        case .usd: return "🇺🇸"
        case .eur: return "🇪🇺"
        case .gbp: return "🇬🇧"
        case .jpy: return "🇯🇵"
        case .aud: return "🇦🇺"
        case .cad: return "🇨🇦"
        case .chf: return "🇨🇭"
        case .cny: return "🇨🇳"
        case .inr: return "🇮🇳"
        case .mxn: return "🇲🇽"
        case .brl: return "🇧🇷"
        case .krw: return "🇰🇷"
        case .thb: return "🇹🇭"
        case .sgd: return "🇸🇬"
        case .hkd: return "🇭🇰"
        case .nzd: return "🇳🇿"
        case .sek: return "🇸🇪"
        case .nok: return "🇳🇴"
        case .dkk: return "🇩🇰"
        case .zar: return "🇿🇦"
        }
    }

    var symbol: String {
        switch self {
        case .usd, .aud, .cad, .sgd, .hkd, .nzd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy, .krw, .thb: return "¥"
        case .chf: return "CHF"
        case .cny: return "¥"
        case .inr: return "₹"
        case .mxn: return "MX$"
        case .brl: return "R$"
        case .sek: return "kr"
        case .nok: return "kr"
        case .dkk: return "kr"
        case .zar: return "R"
        }
    }

    var code: String {
        rawValue.uppercased()
    }

    var rate: Double {
        let rates: [Currency: Double] = [
            .usd: 1.0,
            .eur: 0.92,
            .gbp: 0.79,
            .jpy: 149.50,
            .aud: 1.53,
            .cad: 1.36,
            .chf: 0.88,
            .cny: 7.24,
            .inr: 83.12,
            .mxn: 17.15,
            .brl: 4.97,
            .krw: 1320.0,
            .thb: 35.50,
            .sgd: 1.34,
            .hkd: 7.82,
            .nzd: 1.64,
            .sek: 10.42,
            .nok: 10.58,
            .dkk: 6.87,
            .zar: 18.65
        ]
        return rates[self] ?? 1.0
    }
}
