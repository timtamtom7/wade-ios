import SwiftUI

enum Theme {
    static let oceanBlue = Color(hex: "0077B6")
    static let sunsetOrange = Color(hex: "FF6B35")
    static let palmGreen = Color(hex: "2D6A4F")
    static let sand = Color(hex: "F4E1C1")
    static let surface = Color(hex: "FAFCFF")
    static let cardBg = Color(hex: "FFFFFF")
    static let textPrimary = Color(hex: "1A1A2E")

    static let accentCoral = Color(hex: "FF6B6B")
    static let skyBlue = Color(hex: "90E0EF")
    static let midnight = Color(hex: "03045E")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
