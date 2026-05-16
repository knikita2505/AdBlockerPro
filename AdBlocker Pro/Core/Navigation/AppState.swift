import SwiftUI
import Observation

enum AppTab: Int, CaseIterable {
    case network = 0
    case safari = 1
    case passwords = 2

    var title: String {
        switch self {
        case .network: return String(localized: "Network")
        case .safari: return String(localized: "Protection")
        case .passwords: return String(localized: "Passwords")
        }
    }

    var icon: String {
        switch self {
        case .network: return "wifi"
        case .safari: return "shield.checkered"
        case .passwords: return "key.fill"
        }
    }
}

@Observable
final class AppState {

    static let shared = AppState()

    var selectedTab: AppTab = .safari
    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }
    var showPaywall = false

    private init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}
