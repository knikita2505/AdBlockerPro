import Foundation

@MainActor
final class AdPresentationService {
    static let shared = AdPresentationService()

    private var didShowGenerateAdThisSession = false

    private init() {}

    func showAfterScanIfNeeded() async {
        guard !SubscriptionManager.shared.isPremium else { return }
        _ = await RewardedAdService.shared.show()
    }

    func showAfterGenerateIfNeeded() async {
        guard !SubscriptionManager.shared.isPremium else { return }
        guard !didShowGenerateAdThisSession else { return }
        didShowGenerateAdThisSession = true
        _ = await RewardedAdService.shared.show()
    }

    func showAfterPaywallIfNeeded() async {
        guard !SubscriptionManager.shared.isPremium else { return }
        _ = await RewardedAdService.shared.show()
    }
}
