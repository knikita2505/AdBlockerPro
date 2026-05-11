#if os(iOS)
import UIKit

enum HapticManager {

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
#else
enum HapticManager {
    static func impact(_ style: Any? = nil) {}
    static func notification(_ type: Any? = nil) {}
    static func selection() {}
}
#endif
