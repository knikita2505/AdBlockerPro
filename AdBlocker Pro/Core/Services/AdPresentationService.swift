import Foundation

@MainActor
final class AdPresentationService {
    static let shared = AdPresentationService()

    private init() {}

    func showAfterScanIfNeeded() async {
        guard !SubscriptionManager.shared.isPremium else { return }
        _ = await InterstitialAdService.shared.show()
    }

    func showAfterGenerateIfNeeded() async {
        guard !SubscriptionManager.shared.isPremium else { return }
        _ = await InterstitialAdService.shared.show()
    }

    func showAfterPaywallIfNeeded() async {
        guard !SubscriptionManager.shared.isPremium else { return }
        _ = await InterstitialAdService.shared.show()
    }
}
