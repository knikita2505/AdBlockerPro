import Foundation
import GoogleMobileAds
import UIKit
import UserMessagingPlatform

@MainActor
final class ConsentService {
    static let shared = ConsentService()

    private var didStartMobileAds = false
    private var isPreparing = false

    private init() {}

    func prepareAdsIfNeeded() async {
        guard !SubscriptionManager.shared.isPremium else { return }
        if isPreparing {
            while isPreparing {
                try? await Task.sleep(for: .milliseconds(100))
            }
            if didStartMobileAds { return }
        }
        guard !isPreparing else { return }
        isPreparing = true
        defer { isPreparing = false }

        do {
            let parameters = RequestParameters()
            parameters.isTaggedForUnderAgeOfConsent = false
            try await ConsentInformation.shared.requestConsentInfoUpdate(with: parameters)
            if let viewController = UIViewController.topMost {
                try await ConsentForm.loadAndPresentIfRequired(from: viewController)
            }
        } catch {
            print("UMP consent error: \(error.localizedDescription)")
        }

        startMobileAdsIfAllowed()
    }

    func startMobileAdsIfAllowed() {
        guard ConsentInformation.shared.canRequestAds else {
            print("AdMob skipped: UMP canRequestAds = false")
            return
        }
        guard !didStartMobileAds else {
            InterstitialAdService.shared.preload()
            return
        }
        didStartMobileAds = true
        MobileAds.shared.start { _ in
            Task { @MainActor in
                InterstitialAdService.shared.preload()
            }
        }
    }
}
