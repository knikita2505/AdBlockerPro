import Foundation
import UIKit
import Combine
import AppsFlyerLib
import AppTrackingTransparency
import AdSupport
import ApphudSDK

@MainActor
final class AppsFlyerService: NSObject, ObservableObject {

    static let shared = AppsFlyerService()

    private let devKey = SDKConfig.appsFlyerDevKey
    private let appID = SDKConfig.appsFlyerAppleAppID

    @Published private(set) var isInitialized = false
    @Published private(set) var attStatus: ATTrackingManager.AuthorizationStatus = .notDetermined
    @Published private(set) var hasRequestedATT = false

    private var isConfigured = false

    private override init() {
        super.init()
    }

    func configure() {
        guard !isConfigured else { return }
        guard devKey != "YOUR_APPSFLYER_DEV_KEY", appID != "YOUR_APPLE_APP_ID" else {
            print("📊 [AppsFlyer] Placeholder keys — skip configure until SDKConfig is filled")
            return
        }

        AppsFlyerLib.shared().appsFlyerDevKey = devKey
        AppsFlyerLib.shared().appleAppID = appID
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)

        let apphudUserID = Apphud.userID()
        AppsFlyerLib.shared().customerUserID = apphudUserID

        #if DEBUG
        AppsFlyerLib.shared().isDebug = true
        #endif

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        setDeviceIdentifiersToApphud()

        isConfigured = true
        isInitialized = true
    }

    func setDeviceIdentifiersToApphud() {
        let idfv = UIDevice.current.identifierForVendor?.uuidString
        var idfa: String?

        if ATTrackingManager.trackingAuthorizationStatus == .authorized {
            idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            if idfa == "00000000-0000-0000-0000-000000000000" {
                idfa = nil
            }
        }

        Apphud.setDeviceIdentifiers(idfa: idfa, idfv: idfv)
    }

    func requestATTPermission() async -> ATTrackingManager.AuthorizationStatus {
        guard !hasRequestedATT else { return attStatus }

        let currentStatus = ATTrackingManager.trackingAuthorizationStatus
        if currentStatus != .notDetermined {
            hasRequestedATT = true
            attStatus = currentStatus
            return currentStatus
        }

        return await withCheckedContinuation { continuation in
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                Task { @MainActor in
                    self?.hasRequestedATT = true
                    self?.attStatus = status
                    if status == .authorized {
                        self?.setDeviceIdentifiersToApphud()
                    }
                    continuation.resume(returning: status)
                }
            }
        }
    }

    @objc private func didBecomeActive() {
        guard isConfigured else { return }
        AppsFlyerLib.shared().start()
    }
}

extension AppsFlyerService: AppsFlyerLibDelegate {

    nonisolated func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        let appsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID()
        Apphud.setAttribution(
            data: ApphudAttributionData(rawData: conversionInfo),
            from: .appsFlyer,
            identifer: appsFlyerUID,
            callback: nil
        )
    }

    nonisolated func onConversionDataFail(_ error: Error) {
        let appsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID()
        Apphud.setAttribution(
            data: ApphudAttributionData(rawData: ["error": error.localizedDescription]),
            from: .appsFlyer,
            identifer: appsFlyerUID,
            callback: nil
        )
    }

    nonisolated func onAppOpenAttribution(_ attributionData: [AnyHashable: Any]) {}

    nonisolated func onAppOpenAttributionFailure(_ error: Error) {}
}
