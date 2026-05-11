import Foundation
import SwiftUI
import Observation
import ApphudSDK

@Observable
final class SubscriptionManager {

    static let shared = SubscriptionManager()

    private(set) var isPremium: Bool = false
    var showPaywall: Bool = false
    var currentPlacement: PaywallPlacement = .onboarding

    private init() {
        checkSubscriptionStatus()
        setupApphudObserver()
    }

    // MARK: - Subscription Status

    func checkSubscriptionStatus() {
        let hasActive = Apphud.hasActiveSubscription()
        if isPremium != hasActive {
            isPremium = hasActive
        }
    }

    // MARK: - Premium Gating

    func requirePremium(for feature: PremiumFeature, placement: PaywallPlacement = .premiumFeature) -> Bool {
        guard feature.requiresPremium else { return true }
        if isPremium { return true }
        showPaywall(for: placement)
        return false
    }

    func canAccessFeature(_ feature: PremiumFeature) -> Bool {
        if isPremium { return true }
        return !feature.requiresPremium
    }

    // MARK: - Paywall Presentation

    func showPaywall(for placement: PaywallPlacement) {
        guard !isPremium else { return }
        currentPlacement = placement
        showPaywall = true
    }

    func dismissPaywall() {
        showPaywall = false
    }

    // MARK: - Purchase Handling

    func handleSuccessfulPurchase() {
        checkSubscriptionStatus()
        dismissPaywall()
        NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
    }

    func restorePurchases() async -> Bool {
        return await withCheckedContinuation { continuation in
            Apphud.restorePurchases { _ in
                Task { @MainActor in
                    self.checkSubscriptionStatus()
                    if self.isPremium {
                        self.dismissPaywall()
                        NotificationCenter.default.post(name: .subscriptionStatusChanged, object: nil)
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }

    // MARK: - Private

    private func setupApphudObserver() {
        #if os(iOS)
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor [weak self] in
                self?.checkSubscriptionStatus()
            }
        }
        #endif
    }
}

// MARK: - Paywall Placement

enum PaywallPlacement: String {
    case onboarding = "onboarding"
    case premiumFeature = "premium_feature"

    var identifier: String { rawValue }
}

// MARK: - Premium Feature

enum PremiumFeature {
    case adBlocking
    case trackerProtection
    case cookieBannerCleaner
    case adultContentFilter
    case gamblingFilter
    case imageBlocking
    case allowedWebsites
    case blockedWebsites

    var requiresPremium: Bool { true }
}

// MARK: - Notifications

extension Notification.Name {
    static let subscriptionStatusChanged = Notification.Name("subscriptionStatusChanged")
}
