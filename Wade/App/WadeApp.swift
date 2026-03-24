import SwiftUI

@main
struct WadeApp: App {
    @StateObject private var subscription = SubscriptionManager.shared

    init() {
        NotificationService.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            if !subscription.hasCompletedOnboarding {
                OnboardingView()
            } else {
                ConversationView()
            }
        }
    }
}
