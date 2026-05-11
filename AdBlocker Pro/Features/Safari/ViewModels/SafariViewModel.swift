import SwiftUI
import Observation

@Observable
final class SafariViewModel {

    let contentBlockerManager = ContentBlockerManager.shared
    let subscriptionManager = SubscriptionManager.shared

    func toggleFilter(_ category: FilterCategory, isOn: Bool) {
        guard subscriptionManager.requirePremium(for: category.premiumFeature) else { return }
        contentBlockerManager.toggleFilter(category, isOn: isOn)
        HapticManager.impact(.light)
    }

    func isFilterEnabled(_ category: FilterCategory) -> Bool {
        contentBlockerManager.isFilterEnabled(category)
    }

    func addAllowedWebsite(_ domain: String) -> Bool {
        guard subscriptionManager.requirePremium(for: .allowedWebsites) else { return false }
        let normalized = domain.normalizedDomain
        guard normalized.isValidDomain else { return false }
        contentBlockerManager.addAllowedWebsite(normalized)
        HapticManager.notification(.success)
        return true
    }

    func addBlockedWebsite(_ domain: String) -> Bool {
        guard subscriptionManager.requirePremium(for: .blockedWebsites) else { return false }
        let normalized = domain.normalizedDomain
        guard normalized.isValidDomain else { return false }
        contentBlockerManager.addBlockedWebsite(normalized)
        HapticManager.notification(.success)
        return true
    }
}
