import SwiftUI
import ApphudSDK
import StoreKit
import Observation

struct PaywallView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var vm: PaywallViewModel

    let placement: PaywallPlacement

    init(placement: PaywallPlacement = .onboarding) {
        self.placement = placement
        self._vm = State(wrappedValue: PaywallViewModel(placement: placement))
    }

    private let features: [(icon: String, title: String)] = [
        ("nosign", String(localized: "Block All Ads")),
        ("eye.slash.fill", String(localized: "Tracker Protection")),
        ("xmark.rectangle.fill", String(localized: "Cookie Banner Cleaner")),
        ("exclamationmark.shield.fill", String(localized: "Content Filters")),
        ("globe", String(localized: "Custom Website Lists")),
        ("key.fill", String(localized: "Secure Password Manager"))
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingL) {
                    headerSection
                    featuresSection

                    if vm.isLoadingProducts {
                        ProgressView()
                            .frame(height: 120)
                    } else if let error = vm.loadingError, !vm.hasAnyProduct {
                        errorSection(error)
                    } else {
                        plansSection
                    }

                    purchaseButton
                    footerLinks
                }
                .padding(.horizontal, AppTheme.spacingL)
                .padding(.bottom, AppTheme.spacingXL)
            }
            .background(AppTheme.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppTheme.tertiaryText)
                    }
                }
            }
        }
        .onAppear { vm.onAppear() }
        .onChange(of: vm.purchaseSuccessful) { _, success in
            if success {
                SubscriptionManager.shared.handleSuccessfulPurchase()
                dismiss()
            }
        }
        .alert("Purchase Failed", isPresented: $vm.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "Something went wrong.")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: AppTheme.spacingM) {
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: "shield.checkered")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
            }
            .padding(.top, AppTheme.spacingL)

            Text("Unlock Full Protection")
                .font(.title.bold())

            Text("Get complete Safari protection with premium features")
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(features.enumerated()), id: \.offset) { _, feature in
                HStack(spacing: AppTheme.spacingM) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.accent)
                    Text(feature.title)
                        .font(AppTheme.bodyFont)
                    Spacer()
                }
                .padding(.vertical, 10)
            }
        }
        .padding(AppTheme.spacingM)
        .background(AppTheme.secondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
    }

    // MARK: - Error

    private func errorSection(_ error: PaywallError) -> some View {
        VStack(spacing: AppTheme.spacingM) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(AppTheme.warning)
            Text(error.title)
                .font(AppTheme.headlineFont)
            Text(error.message)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
            Button("Try Again") { vm.retryLoadProducts() }
                .font(AppTheme.headlineFont)
                .tint(AppTheme.accent)
        }
        .padding(.vertical, AppTheme.spacingL)
    }

    // MARK: - Plans

    private var plansSection: some View {
        VStack(spacing: AppTheme.spacingS) {
            PaywallPlanCard(
                title: vm.weeklyTitle,
                price: vm.weeklyPriceText,
                detail: vm.isTrialEligible
                    ? String(localized: "3-day free trial, then auto-renews")
                    : String(localized: "Cancel anytime"),
                badge: vm.isTrialEligible ? String(localized: "Free Trial") : nil,
                isSelected: vm.selectedPlan == .weekly
            ) { vm.select(.weekly) }

            PaywallPlanCard(
                title: String(localized: "Yearly"),
                price: vm.yearlyPriceText,
                detail: vm.yearlyPerWeekText ?? String(localized: "Best value"),
                badge: String(localized: "Best Value"),
                isSelected: vm.selectedPlan == .yearly
            ) { vm.select(.yearly) }
        }
    }

    // MARK: - Purchase Button

    private var purchaseButton: some View {
        VStack(spacing: AppTheme.spacingS) {
            Button {
                vm.purchaseSelected()
            } label: {
                ZStack {
                    if vm.isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(vm.isTrialEligible && vm.selectedPlan == .weekly
                             ? String(localized: "Start Free Trial")
                             : String(localized: "Subscribe Now"))
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
            }
            .disabled(vm.isPurchasing || vm.isLoadingProducts || !vm.hasAnyProduct)

            HStack(spacing: AppTheme.spacingM) {
                Text("Cancel anytime")
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.secondaryText)
                Image(systemName: "checkmark.shield.fill")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Button {
                vm.restore()
            } label: {
                Text("Restore Purchases")
                    .font(AppTheme.footnoteFont)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
    }

    // MARK: - Footer

    private var footerLinks: some View {
        HStack(spacing: AppTheme.spacingM) {
            Link("Terms of Use", destination: URL(string: PaywallConstants.termsURL)!)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.tertiaryText)
            Text("•").foregroundStyle(AppTheme.tertiaryText)
            Link("Privacy Policy", destination: URL(string: PaywallConstants.privacyURL)!)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.tertiaryText)
        }
    }
}

// MARK: - Plan Card

private struct PaywallPlanCard: View {
    let title: String
    let price: String?
    let detail: String
    let badge: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(AppTheme.headlineFont)
                            .foregroundStyle(AppTheme.primaryText)
                        if let badge {
                            Text(badge)
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppTheme.accent)
                                .clipShape(Capsule())
                        }
                    }
                    Text(detail)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                if let price {
                    Text(price)
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(AppTheme.primaryText)
                }
            }
            .padding(AppTheme.spacingM)
            .background(AppTheme.secondaryGroupedBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM)
                    .stroke(isSelected ? AppTheme.accent : .clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - ViewModel

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
        guard let p = weeklyProduct?.skProduct else { return nil }
        let price = formatPrice(p)
        return isTrialEligible ? "then \(price)/wk" : "\(price)/wk"
    }

    var yearlyPriceText: String? {
        guard let p = yearlyProduct?.skProduct else { return nil }
        return "\(formatPrice(p))/yr"
    }

    var yearlyPerWeekText: String? {
        guard let p = yearlyProduct?.skProduct else { return nil }
        let weekly = (p.price as Decimal) / 52
        return "\(formatDecimal(weekly, locale: p.priceLocale))/week"
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
            showErr("Unable to load subscription. Please check your connection.")
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
                    self.showErr("No active subscription found.")
                }
            }
        }
    }

    // MARK: - Private

    private func loadProducts() {
        isLoadingProducts = true
        loadingError = nil

        Apphud.fetchPlacements { [weak self] placements, error in
            guard let self else { return }
            Task { @MainActor in
                self.isLoadingProducts = false

                guard let found = placements.first(where: { $0.identifier == self.placement.identifier }),
                      let paywall = found.paywall else {
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

                self.checkTrialEligibility()
            }
        }
    }

    private func checkTrialEligibility() {
        guard let skProduct = weeklyProduct?.skProduct else {
            isTrialEligible = false
            return
        }
        Apphud.checkEligibilityForIntroductoryOffer(product: skProduct) { [weak self] eligible in
            Task { @MainActor in self?.isTrialEligible = eligible }
        }
    }

    private func showErr(_ msg: String) {
        errorMessage = msg
        showError = true
    }

    private func friendlyError(_ error: Error?) -> String {
        guard let error else { return "Purchase could not be completed." }
        let code = (error as NSError).code
        switch code {
        case 2: return "Purchase was cancelled."
        case 4: return "Purchases are not allowed on this device."
        case 7: return "Could not connect to the App Store. Check your internet."
        default:
            if (error as NSError).domain == NSURLErrorDomain {
                return "No internet connection."
            }
            return "Purchase failed. Please try again."
        }
    }

    private func formatPrice(_ product: SKProduct) -> String {
        formatDecimal(product.price as Decimal, locale: product.priceLocale)
    }

    private func formatDecimal(_ value: Decimal, locale: Locale) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }
}

// MARK: - Types

enum PaywallSubscriptionPlan: String {
    case weekly, yearly
}

enum PaywallError {
    case productsNotAvailable
    case noInternet

    var title: String {
        switch self {
        case .productsNotAvailable: return "Products Unavailable"
        case .noInternet: return "No Connection"
        }
    }

    var message: String {
        switch self {
        case .productsNotAvailable: return "Subscriptions are temporarily unavailable. Please try again later."
        case .noInternet: return "Please check your internet connection."
        }
    }
}

// MARK: - Constants

enum PaywallConstants {
    static let weeklyProductId = "adblocker.premium.week1"
    static let yearlyProductId = "adblocker.premium.year1"

    static let termsURL = "https://example.com/terms"
    static let privacyURL = "https://example.com/privacy"
}

#Preview {
    PaywallView(placement: .onboarding)
}
