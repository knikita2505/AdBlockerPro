import Foundation

enum SDKConfig {
    static let apphudAPIKey = "app_8861UZSwNCVX4Q2BGRXtDD6PKobhSA"

    /// Replace with AppsFlyer Dev Key before release.
    static let appsFlyerDevKey = "YOUR_APPSFLYER_DEV_KEY"
    /// Apple App ID without the "id" prefix. Replace when the App Store listing exists.
    static let appsFlyerAppleAppID = "YOUR_APPLE_APP_ID"

    /// Replace with AppMetrica API key before release.
    static let appMetricaAPIKey = "YOUR_APPMETRICA_API_KEY"
}

enum AdMobConfig {
    static let applicationID = "ca-app-pub-3940256099942544~1458002511"
    static let productionRewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"
    static let testRewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"
    static let rewardedAdUnitID = testRewardedAdUnitID
}
