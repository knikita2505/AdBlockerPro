import SwiftUI
import ApphudSDK
import StoreKit
import Observation

@Observable
final class PaywallViewModel {

    let placement: PaywallPlacement

    var selectedPlan: PaywallSubscriptionPlan = .weekly
    var isPurchasing = false
    var showError = false
    var errorMessage: String?
    var purchaseSuccessful = false

    private(set) var weeklyProduct: ApphudProduct?
    private(set) var yearlyProduct: ApphudProduct?
    private var weeklyStoreProduct: Product?
    private var yearlyStoreProduct: Product?
    var isTrialEligible = false
    var isLoadingProducts = true
    var loadingError: PaywallError?

    private var currentPaywall: ApphudPaywall?

    init(placement: PaywallPlacement = .onboarding) {
        self.placement = placement
    }

    var hasAnyProduct: Bool { weeklyProduct != nil || yearlyProduct != nil }

    var weeklyTitle: String {
        isTrialEligible ? String(localized: "Weekly + Free Trial") : String(localized: "Weekly")
    }

    var weeklyPriceText: String? {
        guard let p = weeklyStoreProduct else { return nil }
        return isTrialEligible
            ? String(localized: "then \(p.displayPrice)/wk")
            : String(localized: "\(p.displayPrice)/wk")
    }

    var yearlyPriceText: String? {
        guard let p = yearlyStoreProduct else { return nil }
        return String(localized: "\(p.displayPrice)/yr")
    }

    var trialPriceLine: String {
        if let price = weeklyStoreProduct?.displayPrice {
            if isTrialEligible {
                return String(localized: "First 3d free, then \(price)/week")
            }
            return String(localized: "\(price)/week")
        }
        return isTrialEligible
            ? String(localized: "3-day free trial, then auto-renews")
            : String(localized: "Cancel anytime")
    }

    var yearlySavePercent: Int? {
        guard let weekly = weeklyStoreProduct, let yearly = yearlyStoreProduct else { return nil }
        let yearOfWeekly = weekly.price * 52
        guard yearOfWeekly > 0 else { return nil }
        let raw = ((yearOfWeekly - yearly.price) / yearOfWeekly * 100) as Decimal
        let value = NSDecimalNumber(decimal: raw).intValue
        return value > 0 ? value : nil
    }

    func onAppear() {
        loadProducts()
    }

    func retryLoadProducts() {
        loadProducts()
    }

    func select(_ plan: PaywallSubscriptionPlan) {
        withAnimation(.easeInOut(duration: 0.2)) { selectedPlan = plan }
    }

    func purchaseSelected() {
        let product: ApphudProduct? = selectedPlan == .weekly ? weeklyProduct : yearlyProduct
        guard let product else {
            showErr(String(localized: "Unable to load subscription. Please check your connection."))
            return
        }

        isPurchasing = true
        Apphud.purchase(product) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                self.isPurchasing = false
                if result.success {
                    self.purchaseSuccessful = true
                } else {
                    self.showErr(self.friendlyError(result.error))
                }
            }
        }
    }

    func restore() {
        isPurchasing = true
        Apphud.restorePurchases { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                self.isPurchasing = false
                if Apphud.hasActiveSubscription() {
                    self.purchaseSuccessful = true
                } else {
                    self.showErr(String(localized: "No active subscription found."))
                }
            }
        }
    }

    private func loadProducts() {
        isLoadingProducts = true
        loadingError = nil

        Apphud.fetchPlacements { [weak self] placements, error in
            guard let self else { return }
            Task { @MainActor in
                guard let found = placements.first(where: { $0.identifier == self.placement.identifier }),
                      let paywall = found.paywall else {
                    self.isLoadingProducts = false
                    self.loadingError = .productsNotAvailable
                    return
                }

                self.currentPaywall = paywall
                Apphud.paywallShown(paywall)

                self.weeklyProduct = paywall.products.first { $0.productId == PaywallConstants.weeklyProductId }
                self.yearlyProduct = paywall.products.first { $0.productId == PaywallConstants.yearlyProductId }

                if self.weeklyProduct == nil, self.yearlyProduct != nil {
                    self.selectedPlan = .yearly
                }

                await self.refreshStoreKitProducts()
                await self.updateTrialEligibility()
                self.isLoadingProducts = false
            }
        }
    }

    private func refreshStoreKitProducts() async {
        weeklyStoreProduct = try? await weeklyProduct?.product()
        yearlyStoreProduct = try? await yearlyProduct?.product()
    }

    private func updateTrialEligibility() async {
        guard let product = weeklyStoreProduct,
              product.subscription?.introductoryOffer != nil else {
            isTrialEligible = false
            return
        }
        isTrialEligible = await product.subscription?.isEligibleForIntroOffer ?? false
    }

    private func showErr(_ msg: String) {
        errorMessage = msg
        showError = true
    }

    private func friendlyError(_ error: Error?) -> String {
        guard let error else { return String(localized: "Purchase could not be completed.") }
        let code = (error as NSError).code
        switch code {
        case 2: return String(localized: "Purchase was cancelled.")
        case 4: return String(localized: "Purchases are not allowed on this device.")
        case 7: return String(localized: "Could not connect to the App Store. Check your internet.")
        default:
            if (error as NSError).domain == NSURLErrorDomain {
                return String(localized: "No internet connection.")
            }
            return String(localized: "Purchase failed. Please try again.")
        }
    }
}

enum PaywallSubscriptionPlan: String {
    case weekly, yearly
}

enum PaywallError {
    case productsNotAvailable
    case noInternet

    var title: String {
        switch self {
        case .productsNotAvailable: return String(localized: "Products Unavailable")
        case .noInternet: return String(localized: "No Connection")
        }
    }

    var message: String {
        switch self {
        case .productsNotAvailable: return String(localized: "Subscriptions are temporarily unavailable. Please try again later.")
        case .noInternet: return String(localized: "Please check your internet connection.")
        }
    }
}

enum PaywallConstants {
    static let weeklyProductId = "adblocker.premium.week1"
    static let yearlyProductId = "adblocker.premium.year1"
    static let termsURL = "https://adblockerpro.app/terms.html"
    static let privacyURL = "https://adblockerpro.app/privacy.html"
    static let supportEmail = "support@adblockerpro.app"
}
