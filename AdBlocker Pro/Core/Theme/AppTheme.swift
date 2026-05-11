import SwiftUI

enum AppTheme {

    // MARK: - Colors

    static let accent = Color(red: 0.18, green: 0.80, blue: 0.55)
    static let background = Color.white
    static let groupedBackground = Color(red: 0.96, green: 0.97, blue: 0.97)
    static let cardBackground = Color.white
    static let secondaryGroupedBackground = Color.white

    static let primaryText = Color.black
    static let secondaryText = Color(red: 0.55, green: 0.57, blue: 0.60)
    static let tertiaryText = Color(red: 0.72, green: 0.74, blue: 0.76)

    static let destructive = Color.red
    static let warning = Color.orange
    static let secondaryBackground = Color(red: 0.95, green: 0.95, blue: 0.96)

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32

    // MARK: - Corner Radius

    static let cornerRadiusS: CGFloat = 10
    static let cornerRadiusM: CGFloat = 14
    static let cornerRadiusL: CGFloat = 18

    // MARK: - Font Styles

    static let titleFont: Font = .system(size: 22, weight: .bold)
    static let headlineFont: Font = .system(size: 16, weight: .semibold)
    static let bodyFont: Font = .system(size: 15, weight: .regular)
    static let captionFont: Font = .system(size: 13, weight: .regular)
    static let footnoteFont: Font = .system(size: 12, weight: .regular)
}

// MARK: - Card Modifier

struct CardStyle: ViewModifier {
    var padding: CGFloat = AppTheme.spacingM

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
    }
}

extension View {
    func cardStyle(padding: CGFloat = AppTheme.spacingM) -> some View {
        modifier(CardStyle(padding: padding))
    }
}
