import SwiftUI

/// Design System for Wade - centralized design tokens
enum DesignSystem {
    enum Colors {
        static let primaryBackground = Color(hex: "0d0d0e")
        static let secondaryBackground = Color(hex: "111112")
        static let cardBackground = Color(hex: "1c1c1e")
        static let textPrimary = Color(hex: "f5f5f7")
        static let textSecondary = Color(hex: "8a8a8a")
        static let accentGreen = Color(hex: "34c759")
        static let expenseRed = Color(hex: "ff453a")
        static let incomeGreen = Color(hex: "34c759")
        static let warningOrange = Color(hex: "ff9f0a")
        static let accentYellow = Color(hex: "ffd60a")
        static let userBubble = Color(hex: "007aff")
        static let wadeBubble = Color(hex: "2c2c2e")
        static let divider = Color(hex: "3a3a3c")
        static let tabInactive = Color(hex: "8a8a8a")
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
    }

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let card: CGFloat = 20
        static let bubble: CGFloat = 18
    }

    enum Typography {
        static let largeTitle = Font.system(size: 28, weight: .bold)
        static let title = Font.system(size: 22, weight: .bold)
        static let headline = Font.system(size: 17, weight: .semibold)
        static let body = Font.system(size: 15, weight: .regular)
        static let caption = Font.system(size: 12, weight: .regular)
        static let footnote = Font.system(size: 11, weight: .regular)
        static let monoBody = Font.system(size: 14, design: .monospaced)
    }
}
