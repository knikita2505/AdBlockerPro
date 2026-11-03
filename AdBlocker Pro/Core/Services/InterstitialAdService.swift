import Foundation
import GoogleMobileAds
import UIKit
import UserMessagingPlatform

enum InterstitialShowResult {
    case dismissed
    case failed
    case notReady
}

@MainActor
final class InterstitialAdService: NSObject {
    static let shared = InterstitialAdService()

    private var interstitialAd: InterstitialAd?
    private var isLoading = false
    private var presenter: InterstitialAdPresenter?

    private override init() {
        super.init()
    }

    func preload() {
        guard !SubscriptionManager.shared.isPremium else { return }
        guard ConsentInformation.shared.canRequestAds else { return }
        guard interstitialAd == nil, !isLoading else { return }
        isLoading = true

        InterstitialAd.load(with: AdMobConfig.interstitialAdUnitID, request: Request()) { [weak self] ad, error in
            let failureMessage = error?.localizedDescription
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isLoading = false
                if let failureMessage {
                    print("AdMob interstitial load failed: \(failureMessage)")
                    self.interstitialAd = nil
                    return
                }
                self.interstitialAd = ad
            }
        }
    }

    func show() async -> InterstitialShowResult {
        await ConsentService.shared.prepareAdsIfNeeded()
        guard let ad = await loadAdIfNeeded() else {
            print("AdMob interstitial not ready")
            return .notReady
        }
        try? await Task.sleep(for: .milliseconds(350))
        guard let viewController = UIViewController.topMost else {
            return .failed
        }

        interstitialAd = nil
        let presenter = InterstitialAdPresenter()
        self.presenter = presenter
        ad.fullScreenContentDelegate = presenter

        return await withCheckedContinuation { continuation in
            presenter.finish = { [weak self] result in
                Task { @MainActor [weak self] in
                    self?.presenter = nil
                    self?.preload()
                    continuation.resume(returning: result)
                }
            }

            ad.present(from: viewController)
        }
    }

    private func loadAdIfNeeded() async -> InterstitialAd? {
        if let interstitialAd { return interstitialAd }
        for attempt in 0..<2 {
            preload()
            let deadline = Date().addingTimeInterval(8)
            while Date() < deadline {
                if let interstitialAd { return interstitialAd }
                if !isLoading { break }
                try? await Task.sleep(for: .milliseconds(200))
            }
            if attempt == 0, interstitialAd == nil {
                try? await Task.sleep(for: .milliseconds(400))
            }
        }
        return interstitialAd
    }
}

private final class InterstitialAdPresenter: NSObject, FullScreenContentDelegate {
    var finish: ((InterstitialShowResult) -> Void)?
    private var didFinish = false

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        complete(.failed)
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        complete(.dismissed)
    }

    private func complete(_ result: InterstitialShowResult) {
        guard !didFinish else { return }
        didFinish = true
        finish?(result)
    }
}

extension UIViewController {
    static var topMost: UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let window = scenes
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
            ?? scenes.first?.windows.first
        guard let root = window?.rootViewController else { return nil }
        return topMost(from: root)
    }

    private static func topMost(from controller: UIViewController) -> UIViewController {
        if let presented = controller.presentedViewController {
            return topMost(from: presented)
        }
        if let navigation = controller as? UINavigationController, let visible = navigation.visibleViewController {
            return topMost(from: visible)
        }
        if let tab = controller as? UITabBarController, let selected = tab.selectedViewController {
            return topMost(from: selected)
        }
        return controller
    }
}
