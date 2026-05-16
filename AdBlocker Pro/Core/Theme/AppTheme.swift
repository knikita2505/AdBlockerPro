import SwiftUI

// MARK: - Colors

enum AppTheme {

    static let background = Color(hex: "FAFBFC")
    static let surface = Color.white
    static let surfaceSecondary = Color(hex: "F4F6F8")

    static let primaryText = Color(hex: "1A1D21")
    static let secondaryText = Color(hex: "6B7280")
    static let tertiaryText = Color(hex: "9CA3AF")

    static let accent = Color(hex: "10B981")
    static let accentLight = Color(hex: "34D399")
    static let accentSoft = Color(hex: "ECFDF5")

    static let gradientStart = Color(hex: "10B981")
    static let gradientEnd = Color(hex: "059669")

    static let success = Color(hex: "10B981")
    static let warning = Color(hex: "F59E0B")
    static let destructive = Color(hex: "EF4444")

    static let shadowSoft = Color.black.opacity(0.04)
    static let shadowMedium = Color.black.opacity(0.08)

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48

    // MARK: - Corner Radius

    static let radiusS: CGFloat = 8
    static let radiusM: CGFloat = 12
    static let radiusL: CGFloat = 16
    static let radiusXL: CGFloat = 24
    static let radiusFull: CGFloat = 100

    // MARK: - Fonts (Rounded)

    static let displayLarge = Font.system(size: 48, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 36, weight: .bold, design: .rounded)

    static let titleFont = Font.system(size: 28, weight: .bold, design: .rounded)
    static let titleMedium = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let titleSmall = Font.system(size: 18, weight: .semibold, design: .rounded)

    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .rounded)
    static let bodyFont = Font.system(size: 15, weight: .regular, design: .rounded)
    static let bodyMedium = Font.system(size: 15, weight: .medium, design: .rounded)

    static let captionFont = Font.system(size: 13, weight: .regular, design: .rounded)
    static let captionMedium = Font.system(size: 13, weight: .medium, design: .rounded)
    static let captionSmall = Font.system(size: 11, weight: .medium, design: .rounded)

    // backward compat aliases
    static let groupedBackground = background
    static let cardBackground = surface
    static let secondaryGroupedBackground = surfaceSecondary
    static let headlineFont = titleSmall
    static let footnoteFont = captionSmall
    static let cornerRadiusS = radiusS
    static let cornerRadiusM = radiusM
    static let cornerRadiusL = radiusL
}

// MARK: - Card Modifier

struct CardStyle: ViewModifier {
    var padding: CGFloat = AppTheme.spacingM

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
            .shadow(color: AppTheme.shadowSoft, radius: 8, x: 0, y: 2)
            .shadow(color: AppTheme.shadowMedium, radius: 1, x: 0, y: 1)
    }
}

// MARK: - Pressed Style

struct PressedStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle(padding: CGFloat = AppTheme.spacingM) -> some View {
        modifier(CardStyle(padding: padding))
    }

    func pressable() -> some View {
        buttonStyle(PressedStyle())
    }
}

// MARK: - Text Styles

extension Text {
    func displayStyle() -> some View {
        self.font(AppTheme.displayLarge)
            .foregroundColor(AppTheme.primaryText)
    }

    func titleStyle() -> some View {
        self.font(AppTheme.titleFont)
            .foregroundColor(AppTheme.primaryText)
    }

    func bodyStyle() -> some View {
        self.font(AppTheme.bodyFont)
            .foregroundColor(AppTheme.secondaryText)
    }

    func captionStyle() -> some View {
        self.font(AppTheme.captionFont)
            .foregroundColor(AppTheme.tertiaryText)
    }
}

// MARK: - Gradient Background

struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                AppTheme.background,
                AppTheme.surfaceSecondary.opacity(0.5)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Color Hex Init

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
