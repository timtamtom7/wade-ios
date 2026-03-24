import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                self.scheduleWeeklySummary()
            }
        }
    }

    func scheduleWeeklySummary() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["weekly_summary"])

        let content = UNMutableNotificationContent()
        content.title = "📊 Wade Weekly Summary"
        content.body = "Tap to see your spending this week."
        content.sound = .default

        // Schedule for Friday at 6pm
        var dateComponents = DateComponents()
        dateComponents.weekday = 6 // Friday
        dateComponents.hour = 18
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly_summary", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error)")
            }
        }
    }

    func sendImmediateSummary(expenses: Double, income: Double, net: Double) {
        let content = UNMutableNotificationContent()
        content.title = "📊 This Week's Summary"

        let sign = net >= 0 ? "+" : ""
        let netStr = formatCurrency(abs(net))
        content.body = "Spent: \(formatCurrency(expenses))\nIncome: \(formatCurrency(income))\nNet: \(sign)\(netStr)"
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }
}
