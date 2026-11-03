import Foundation
import AppMetricaCore
import AppMetricaAdSupport
import ApphudSDK

@MainActor
final class AppMetricaService {

    static let shared = AppMetricaService()

    private let apiKey = SDKConfig.appMetricaAPIKey
    private var isActivated = false

    private init() {}

    func activate() {
        guard !isActivated else { return }
        guard apiKey.contains("-"), apiKey != "YOUR_APPMETRICA_API_KEY" else {
            print("📈 [AppMetrica] Placeholder API key — skip activate until a real key is set in SDKConfig")
            return
        }
        guard let configuration = AppMetricaConfiguration(apiKey: apiKey) else { return }

        let apphudUserID = Apphud.userID()
        configuration.userProfileID = apphudUserID
        AppMetrica.activate(with: configuration)
        isActivated = true
        sendDeviceIdToApphud()
    }

    private func sendDeviceIdToApphud() {
        AppMetrica.requestStartupIdentifiers(
            for: [.deviceIDKey],
            on: .main
        ) { identifiers, error in
            if error != nil { return }
            guard let deviceID = identifiers?[.deviceIDKey] as? String else { return }
            Apphud.setAttribution(
                data: ApphudAttributionData(rawData: ["appmetrica_device_id": deviceID]),
                from: .custom,
                identifer: deviceID,
                callback: nil
            )
        }
    }
}
