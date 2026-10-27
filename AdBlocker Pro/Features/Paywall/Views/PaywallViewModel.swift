import SwiftUI
import ApphudSDK
import StoreKit
import Observation
import os

@Observable
final class PaywallViewModel {

    private static let log = Logger(subsystem: "nikita.ka.AdBlocker-Pro", category: "Paywall")

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

    init(placement: PaywallPlacement = .launch) {
        self.placement = placement
    }

    var hasAnyProduct: Bool { weeklyProduct != nil || yearlyProduct != nil }

    var yearlyCardTitle: String {
        storeDisplayName(apphud: yearlyProduct, store: yearlyStoreProduct)
    }

    var weeklyCardTitle: String {
        storeDisplayName(apphud: weeklyProduct, store: weeklyStoreProduct)
    }

    var yearlyCardPrice: String? {
        yearlyStoreProduct.map(pricePerPeriod)
    }

    var weeklyCardPrice: String? {
        guard let product = weeklyStoreProduct else { return nil }
        let price = pricePerPeriod(product)
        guard weeklyShowsTrial else { return price }
        return String(format: String(localized: "Then %@"), price)
    }

    var trialPriceLine: String {
        guard let product = weeklyStoreProduct else {
            return String(localized: "First 3 days free")
        }
        let price = pricePerPeriod(product)
        return String(format: String(localized: "First 3 days free, then %@"), price)
    }

    private var weeklyShowsTrial: Bool {
        guard isTrialEligible,
              let offer = weeklyStoreProduct?.subscription?.introductoryOffer else { return false }
        return offer.paymentMode == .freeTrial
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

        Apphud.fetchPlacements(forceRefresh: true) { [weak self] placements, error in
            let failureMessage = error?.localizedDescription
            Task { @MainActor [weak self] in
                await self?.applyPlacements(placements, errorMessage: failureMessage)
            }
        }
    }

    @MainActor
    private func applyPlacements(_ placements: [ApphudPlacement], errorMessage: String?) async {
        let summary = placements.map { item in
            let paywallID = item.paywall?.identifier ?? "nil"
            let productIDs = item.paywall?.products.map(\.productId).joined(separator: ",") ?? ""
            return "\(item.identifier) → \(paywallID) [\(productIDs)]"
        }.joined(separator: "; ")
        Self.log.info("Apphud placements: \(summary, privacy: .public)")
        if let errorMessage {
            Self.log.error("Apphud placements error: \(errorMessage, privacy: .public)")
        }

        guard let found = placements.first(where: { $0.identifier == placement.identifier }),
              let paywall = found.paywall else {
            isLoadingProducts = false
            loadingError = .productsNotAvailable
            return
        }

        if paywall.identifier != placement.paywallIdentifier {
            Self.log.error("Placement \(self.placement.identifier, privacy: .public) returned paywall \(paywall.identifier, privacy: .public), expected \(self.placement.paywallIdentifier, privacy: .public)")
        }

        currentPaywall = paywall
        Apphud.paywallShown(paywall)
        weeklyProduct = paywall.products.first { $0.productId == PaywallConstants.weeklyProductId }
        yearlyProduct = paywall.products.first { $0.productId == PaywallConstants.yearlyProductId }

        await refreshStoreKitProducts()
        await fillUnmatchedProducts(from: paywall.products)
        await updateTrialEligibility()

        if weeklyProduct == nil, yearlyProduct != nil {
            selectedPlan = .yearly
        }

        let missingWeekly = weeklyProduct == nil
        let missingYearly = placement == .premiumFeatures && yearlyProduct == nil
        if missingWeekly || missingYearly {
            let ids = paywall.products.map(\.productId).joined(separator: ", ")
            Self.log.error("Placement \(self.placement.identifier, privacy: .public) is missing expected products. Received: \(ids, privacy: .public)")
            loadingError = .productsNotAvailable
        }
        isLoadingProducts = false
    }

    @MainActor
    private func fillUnmatchedProducts(from products: [ApphudProduct]) async {
        guard weeklyProduct == nil || (placement == .premiumFeatures && yearlyProduct == nil) else { return }

        for candidate in products {
            let alreadyUsed = candidate.productId == weeklyProduct?.productId
                || candidate.productId == yearlyProduct?.productId
            if alreadyUsed { continue }

            guard let store = try? await candidate.product(),
                  let period = store.subscription?.subscriptionPeriod else { continue }

            switch (period.unit, period.value) {
            case (.week, _), (.day, 7):
                if weeklyProduct == nil {
                    weeklyProduct = candidate
                    weeklyStoreProduct = store
                }
            case (.year, _):
                if yearlyProduct == nil {
                    yearlyProduct = candidate
                    yearlyStoreProduct = store
                }
            default:
                break
            }
        }
    }

    @MainActor
    private func refreshStoreKitProducts() async {
        weeklyStoreProduct = await fetchStoreProduct(weeklyProduct)
        yearlyStoreProduct = await fetchStoreProduct(yearlyProduct)
    }

    @MainActor
    private func fetchStoreProduct(_ apphudProduct: ApphudProduct?) async -> Product? {
        guard let apphudProduct else { return nil }
        let productId = apphudProduct.productId
        if let product = try? await apphudProduct.product() {
            return product
        }
        do {
            let loaded = try await Product.products(for: [productId])
            if let product = loaded.first(where: { $0.id == productId }) {
                return product
            }
            Self.log.error("StoreKit omitted \(productId, privacy: .public). Apple did not return this id for nikita.ka.AdBlocker-Pro.")
            return nil
        } catch {
            Self.log.error("StoreKit failed for \(productId, privacy: .public): \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    private func updateTrialEligibility() async {
        guard let product = weeklyStoreProduct,
              product.subscription?.introductoryOffer != nil else {
            isTrialEligible = false
            return
        }
        isTrialEligible = await product.subscription?.isEligibleForIntroOffer ?? false
    }

    private func storeDisplayName(apphud: ApphudProduct?, store: Product?) -> String {
        if let displayName = store?.displayName.trimmingCharacters(in: .whitespacesAndNewlines), !displayName.isEmpty {
            return displayName
        }
        return apphud?.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private func pricePerPeriod(_ product: Product) -> String {
        let price = product.displayPrice
        guard let period = product.subscription?.subscriptionPeriod else { return price }
        let unit = unitWord(period)
        guard !unit.isEmpty else { return price }
        return "\(price)/\(unit)"
    }

    private func unitWord(_ period: Product.SubscriptionPeriod) -> String {
        switch period.unit {
        case .day:
            return period.value == 7 ? String(localized: "week") : String(localized: "day")
        case .week:
            return String(localized: "week")
        case .month:
            return String(localized: "month")
        case .year:
            return String(localized: "year")
        @unknown default:
            return ""
        }
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
    static let weeklyProductId = "safeguard_premium_week"
    static let yearlyProductId = "safeguard_premium_year"
    static let termsURL = "https://adblockerpro.app/terms.html"
    static let privacyURL = "https://adblockerpro.app/privacy.html"
    static let supportEmail = "support@adblockerpro.app"
}
