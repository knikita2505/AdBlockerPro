import Foundation

enum SDKConfig {
    static let apphudAPIKey = "app_8861UZSwNCVX4Q2BGRXtDD6PKobhSA"

    /// Replace with AppsFlyer Dev Key before release.
    static let appsFlyerDevKey = "w2UscaGb7uRH4EtJUmWBj9"
    /// Apple App ID without the "id" prefix. Replace when the App Store listing exists.
    static let appsFlyerAppleAppID = "6768447310"

    /// Replace with AppMetrica API key before release.
    static let appMetricaAPIKey = "dbd81196-97c9-4c8a-afa9-8fc2a6509c5f"
}

enum AdMobConfig {
    static let applicationID = "ca-app-pub-5315661113522929~5505354919"
    static let productionInterstitialAdUnitID = "ca-app-pub-5315661113522929/4905307853"
    static let interstitialAdUnitID = productionInterstitialAdUnitID
}
