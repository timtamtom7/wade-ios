import SwiftUI

// MARK: - Theme

enum Theme {
    // MARK: - Brand Colors (fixed, no dark mode)
    static let oceanBlue = Color(hex: "0077B6")
    static let sunsetOrange = Color(hex: "FF6B35")
    static let palmGreen = Color(hex: "2D6A4F")
    static let sand = Color(hex: "F4E1C1")
    static let accentCoral = Color(hex: "FF6B6B")
    static let skyBlue = Color(hex: "90E0EF")
    static let midnight = Color(hex: "03045E")

    // MARK: - Semantic Colors — Light
    static let surfaceLight = Color(hex: "FAFCFF")
    static let cardBgLight = Color(hex: "FFFFFF")
    static let textPrimaryLight = Color(hex: "1A1A2E")
    static let textSecondaryLight = Color(hex: "6B7280")
    static let statusOpenLight = Color(hex: "22C55E")
    static let statusClosedLight = Color(hex: "9CA3AF")
    static let borderSubtleLight = Color(hex: "E5E7EB")

    // MARK: - Semantic Colors — Dark
    static let surfaceDark = Color(hex: "0D1117")
    static let cardBgDark = Color(hex: "161B22")
    static let textPrimaryDark = Color(hex: "E6EDF3")
    static let textSecondaryDark = Color(hex: "8B949E")
    static let statusOpenDark = Color(hex: "3FB950")
    static let statusClosedDark = Color(hex: "6E7681")
    static let borderSubtleDark = Color(hex: "30363D")
}

// MARK: - Environment Keys for Adaptive Colors

private struct ThemeSurfaceKey: EnvironmentKey {
    static let defaultValue: Color = Theme.surfaceLight
}
private struct ThemeCardBgKey: EnvironmentKey {
    static let defaultValue: Color = Theme.cardBgLight
}
private struct ThemeTextPrimaryKey: EnvironmentKey {
    static let defaultValue: Color = Theme.textPrimaryLight
}
private struct ThemeTextSecondaryKey: EnvironmentKey {
    static let defaultValue: Color = Theme.textSecondaryLight
}
private struct ThemeStatusOpenKey: EnvironmentKey {
    static let defaultValue: Color = Theme.statusOpenLight
}
private struct ThemeStatusClosedKey: EnvironmentKey {
    static let defaultValue: Color = Theme.statusClosedLight
}
private struct ThemeBorderSubtleKey: EnvironmentKey {
    static let defaultValue: Color = Theme.borderSubtleLight
}

extension EnvironmentValues {
    var _themeSurface: Color {
        get { self[ThemeSurfaceKey.self] }
        set { self[ThemeSurfaceKey.self] = newValue }
    }
    var _themeCardBg: Color {
        get { self[ThemeCardBgKey.self] }
        set { self[ThemeCardBgKey.self] = newValue }
    }
    var _themeTextPrimary: Color {
        get { self[ThemeTextPrimaryKey.self] }
        set { self[ThemeTextPrimaryKey.self] = newValue }
    }
    var _themeTextSecondary: Color {
        get { self[ThemeTextSecondaryKey.self] }
        set { self[ThemeTextSecondaryKey.self] = newValue }
    }
    var _themeStatusOpen: Color {
        get { self[ThemeStatusOpenKey.self] }
        set { self[ThemeStatusOpenKey.self] = newValue }
    }
    var _themeStatusClosed: Color {
        get { self[ThemeStatusClosedKey.self] }
        set { self[ThemeStatusClosedKey.self] = newValue }
    }
    var _themeBorderSubtle: Color {
        get { self[ThemeBorderSubtleKey.self] }
        set { self[ThemeBorderSubtleKey.self] = newValue }
    }
}

// MARK: - Theme Injection Modifier

struct InjectTheme: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .environment(\._themeSurface, colorScheme == .dark ? Theme.surfaceDark : Theme.surfaceLight)
            .environment(\._themeCardBg, colorScheme == .dark ? Theme.cardBgDark : Theme.cardBgLight)
            .environment(\._themeTextPrimary, colorScheme == .dark ? Theme.textPrimaryDark : Theme.textPrimaryLight)
            .environment(\._themeTextSecondary, colorScheme == .dark ? Theme.textSecondaryDark : Theme.textSecondaryLight)
            .environment(\._themeStatusOpen, colorScheme == .dark ? Theme.statusOpenDark : Theme.statusOpenLight)
            .environment(\._themeStatusClosed, colorScheme == .dark ? Theme.statusClosedDark : Theme.statusClosedLight)
            .environment(\._themeBorderSubtle, colorScheme == .dark ? Theme.borderSubtleDark : Theme.borderSubtleLight)
    }
}

extension View {
    /// Inject adaptive theme colors into the environment.
    /// Apply once on the root view.
    func injectTheme() -> some View {
        modifier(InjectTheme())
    }
}

// MARK: - ThemeToken — adaptive colors for use in Views

enum ThemeToken {
    static func surface(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Theme.surfaceDark : Theme.surfaceLight
    }
    static func cardBg(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Theme.cardBgDark : Theme.cardBgLight
    }
    static func textPrimary(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Theme.textPrimaryDark : Theme.textPrimaryLight
    }
    static func textSecondary(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Theme.textSecondaryDark : Theme.textSecondaryLight
    }
    static func statusOpen(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Theme.statusOpenDark : Theme.statusOpenLight
    }
    static func statusClosed(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Theme.statusClosedDark : Theme.statusClosedLight
    }
    static func borderSubtle(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Theme.borderSubtleDark : Theme.borderSubtleLight
    }
}

// MARK: - Color from hex

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
