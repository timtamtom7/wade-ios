import Foundation
import UIKit
import PDFKit

/// Service for exporting expense data in various formats
@MainActor
final class ExportService {
    static let shared = ExportService()

    private let db = DatabaseService.shared
    private let currencyService = CurrencyService.shared

    private init() {}

    // MARK: - CSV Export

    /// Export all transactions to CSV string
    func exportToCSV(transactions: [Transaction]? = nil) -> String {
        let txs = transactions ?? db.fetchAll()
        var csv = "Date,Type,Category,Amount,Currency,Note,Recurring\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for tx in txs {
            let date = dateFormatter.string(from: tx.date)
            let type = tx.type.rawValue
            let category = escapeCSV(tx.category)
            let amount = String(format: "%.2f", tx.amount)
            let currency = tx.currencyCode
            let note = escapeCSV(tx.note)
            let recurring = tx.isRecurring ? "Yes" : "No"
            csv += "\(date),\(type),\(category),\(amount),\(currency),\(note),\(recurring)\n"
        }

        return csv
    }

    /// Export transactions for a specific month to CSV
    func exportMonthToCSV(year: Int, month: Int) -> String {
        let txs = db.fetchMonth(year: year, month: month)
        return exportToCSV(transactions: txs)
    }

    /// Save CSV to a temporary file and return URL
    func saveCSVToFile(_ csv: String, filename: String = "wade_export") -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("\(filename).csv")

        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("CSV export error: \(error)")
            return nil
        }
    }

    // MARK: - PDF Export

    /// Generate a formatted monthly report PDF
    func generateMonthlyPDF(report: MonthlyReport, transactions: [Transaction]? = nil) -> Data? {
        let pageWidth: CGFloat = 612  // US Letter
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50

        let pdfMetaData = [
            kCGPDFContextCreator: "Wade",
            kCGPDFContextTitle: "Monthly Report - \(report.formattedMonth)"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let txs = transactions ?? db.fetchMonth(year: report.year, month: report.month)
            .filter { $0.type == .expense }
            .sorted { $0.date < $1.date }

        let data = renderer.pdfData { context in
            context.beginPage()

            var yPosition: CGFloat = margin

            // Title
            let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
            let title = "Monthly Report"
            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]
            title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttr)
            yPosition += 35

            // Month subtitle
            let subtitleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
            let subtitle = report.formattedMonth
            let subtitleAttr: [NSAttributedString.Key: Any] = [
                .font: subtitleFont,
                .foregroundColor: UIColor.darkGray
            ]
            subtitle.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: subtitleAttr)
            yPosition += 30

            // Divider
            let dividerPath = UIBezierPath()
            dividerPath.move(to: CGPoint(x: margin, y: yPosition))
            dividerPath.addLine(to: CGPoint(x: pageWidth - margin, y: yPosition))
            UIColor.lightGray.setStroke()
            dividerPath.stroke()
            yPosition += 20

            // Summary section
            let sectionFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
            let valueFont = UIFont.systemFont(ofSize: 14, weight: .regular)

            var summaryItems: [(String, String)] = [
                ("Total Spent:", currencyService.formatCurrency(report.totalSpent)),
                ("Total Income:", currencyService.formatCurrency(report.totalIncome)),
                ("Net:", currencyService.formatCurrency(report.net)),
                ("Top Category:", report.topCategory),
            ]

            if let pct = report.vsLastMonthPercent {
                let sign = pct >= 0 ? "+" : ""
                summaryItems.append(("vs Last Month:", "\(sign)\(String(format: "%.1f", pct))%"))
            }

            for (label, value) in summaryItems {
                let labelAttr: [NSAttributedString.Key: Any] = [
                    .font: sectionFont,
                    .foregroundColor: UIColor.black
                ]
                let valueAttr: [NSAttributedString.Key: Any] = [
                    .font: valueFont,
                    .foregroundColor: UIColor.darkGray
                ]
                label.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: labelAttr)
                value.draw(at: CGPoint(x: margin + 120, y: yPosition), withAttributes: valueAttr)
                yPosition += 22
            }

            yPosition += 15

            // Category breakdown
            let categoryHeader = "Spending by Category"
            categoryHeader.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.black
            ])
            yPosition += 25

            for cat in report.categoryBreakdown {
                let catText = "\(cat.category)  \(String(format: "%.1f", cat.percentage))%  \(currencyService.formatCurrency(cat.amount))"
                catText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [
                    .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                    .foregroundColor: UIColor.darkGray
                ])
                yPosition += 18

                // Check for page break
                if yPosition > pageHeight - margin - 50 {
                    context.beginPage()
                    yPosition = margin
                }
            }

            yPosition += 15

            // Transaction list
            let txHeader = "Transactions"
            txHeader.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.black
            ])
            yPosition += 25

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d"

            for tx in txs {
                if yPosition > pageHeight - margin - 30 {
                    context.beginPage()
                    yPosition = margin
                }

                let txLine = "\(dateFormatter.string(from: tx.date))  \(tx.category)  \(currencyService.formatCurrency(tx.amount))"
                txLine.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: [
                    .font: UIFont.systemFont(ofSize: 11, weight: .regular),
                    .foregroundColor: UIColor.darkGray
                ])
                yPosition += 16
            }

            // Footer
            let footerText = "Generated by Wade"
            footerText.draw(at: CGPoint(x: margin, y: pageHeight - margin), withAttributes: [
                .font: UIFont.systemFont(ofSize: 9, weight: .regular),
                .foregroundColor: UIColor.lightGray
            ])
        }

        return data
    }

    /// Save PDF to a temporary file and return URL
    func savePDFToFile(_ data: Data, filename: String = "wade_report") -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("\(filename).pdf")

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("PDF export error: \(error)")
            return nil
        }
    }

    // MARK: - QuickBooks/Xero Export

    /// Export transactions in a format suitable for accounting software import
    func exportForAccountingSoftware(transactions: [Transaction]? = nil) -> String {
        let txs = transactions ?? db.fetchAll()
        var output = "DATE,DESCRIPTION,AMOUNT,TRANSACTION_TYPE,CATEGORY\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for tx in txs {
            let date = dateFormatter.string(from: tx.date)
            let desc = escapeCSV(tx.note.isEmpty ? tx.category : tx.note)
            // Negate expenses, keep income positive for accounting software convention
            let amount = tx.type == .expense ? -tx.amount : tx.amount
            let type = tx.type == .expense ? "EXPENSE" : "INCOME"
            let category = escapeCSV(tx.category)
            output += "\(date),\"\(desc)\",\(String(format: "%.2f", amount)),\(type),\"\(category)\"\n"
        }

        return output
    }

    // MARK: - Yearly Summary

    func generateYearlySummary(year: Int? = nil) -> YearlySummary? {
        let calendar = Calendar.current
        let targetYear = year ?? calendar.component(.year, from: Date())

        guard let yearStart = calendar.date(from: DateComponents(year: targetYear, month: 1, day: 1)),
              let yearEnd = calendar.date(from: DateComponents(year: targetYear + 1, month: 1, day: 1)) else {
            return nil
        }

        let allTransactions = db.fetchAll()
        let yearTransactions = allTransactions.filter { $0.date >= yearStart && $0.date < yearEnd }

        if yearTransactions.isEmpty { return nil }

        let expenses = yearTransactions.filter { $0.type == .expense }
        let income = yearTransactions.filter { $0.type == .income }

        let totalSpent = expenses.reduce(0) { $0 + $1.amount }
        let totalIncome = income.reduce(0) { $0 + $1.amount }

        // Monthly breakdown
        var monthlyTotals: [Int: Double] = [:]
        for tx in expenses {
            let month = calendar.component(.month, from: tx.date)
            monthlyTotals[month, default: 0] += tx.amount
        }

        // Category totals
        var categoryTotals: [String: Double] = [:]
        for tx in expenses {
            categoryTotals[tx.category, default: 0] += tx.amount
        }

        let topCategories = categoryTotals
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { YearlySummary.CategoryTotal(category: $0.key, amount: $0.value) }

        // Find biggest month
        let biggestMonth = monthlyTotals.max { $0.value < $1.value }

        let monthlyBreakdown = monthlyTotals.map { YearlySummary.MonthlyTotal(month: $0.key, total: $0.value) }.sorted { $0.month < $1.month }

        return YearlySummary(
            year: targetYear,
            totalSpent: totalSpent,
            totalIncome: totalIncome,
            net: totalIncome - totalSpent,
            monthlyBreakdown: monthlyBreakdown,
            topCategories: Array(topCategories),
            biggestMonth: biggestMonth.map { YearlySummary.MonthlyTotal(month: $0.key, total: $0.value) },
            transactionCount: yearTransactions.count
        )
    }

    // MARK: - Helpers

    private func escapeCSV(_ text: String) -> String {
        if text.contains(",") || text.contains("\"") || text.contains("\n") {
            return "\"\(text.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return text
    }
}
