import SwiftUI

enum AppTheme {

    // MARK: - Colors

    static let accent = Color.green
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)
    static let secondaryGroupedBackground = Color(.secondarySystemGroupedBackground)

    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let tertiaryText = Color(.tertiaryLabel)

    static let destructive = Color.red
    static let warning = Color.orange

    static let cardBackground = Color(.secondarySystemGroupedBackground)

    // MARK: - Spacing

    static let spacingXS: CGFloat = 4
    static let spacingS: CGFloat = 8
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24
    static let spacingXL: CGFloat = 32

    // MARK: - Corner Radius

    static let cornerRadiusS: CGFloat = 8
    static let cornerRadiusM: CGFloat = 12
    static let cornerRadiusL: CGFloat = 16

    // MARK: - Font Styles

    static let titleFont: Font = .title2.bold()
    static let headlineFont: Font = .headline
    static let bodyFont: Font = .body
    static let captionFont: Font = .caption
    static let footnoteFont: Font = .footnote
}

// MARK: - Card Modifier

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.spacingM)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
