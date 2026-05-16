import SwiftUI

enum FilterCategory: String, CaseIterable, Identifiable, Codable {
    case ads = "ads"
    case cookieBanners = "cookie_banners"
    case trackers = "trackers"
    case adultContent = "adult_content"
    case imageBlocking = "image_blocking"
    case gambling = "gambling"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ads: return String(localized: "General Ads")
        case .cookieBanners: return String(localized: "Hide Cookie Prompts")
        case .trackers: return String(localized: "Stop Tracking")
        case .adultContent: return String(localized: "Block Adult Content")
        case .imageBlocking: return String(localized: "Don't Load Images")
        case .gambling: return String(localized: "Block Gambling")
        }
    }

    var subtitle: String {
        switch self {
        case .ads: return String(localized: "Block intrusive ads")
        case .cookieBanners: return String(localized: "Remove obtrusive banners")
        case .trackers: return String(localized: "Block surveillance ads")
        case .adultContent: return String(localized: "Make browsing safe for kids")
        case .imageBlocking: return String(localized: "Significant data saving")
        case .gambling: return String(localized: "Gambling detectors")
        }
    }

    var icon: String {
        switch self {
        case .ads: return "flame.fill"
        case .cookieBanners: return "star.fill"
        case .trackers: return "antenna.radiowaves.left.and.right.slash"
        case .adultContent: return "18.square.fill"
        case .imageBlocking: return "photo.fill"
        case .gambling: return "ladybug.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .ads: return .red
        case .cookieBanners: return .orange
        case .trackers: return .blue
        case .adultContent: return .pink
        case .imageBlocking: return .purple
        case .gambling: return .red
        }
    }

    var rulesFileName: String {
        switch self {
        case .ads: return "ads_rules"
        case .trackers: return "tracker_rules"
        case .cookieBanners: return "cookie_rules"
        case .adultContent: return "adult_rules"
        case .gambling: return "gambling_rules"
        case .imageBlocking: return "image_rules"
        }
    }

    var premiumFeature: PremiumFeature {
        switch self {
        case .ads: return .adBlocking
        case .trackers: return .trackerProtection
        case .cookieBanners: return .cookieBannerCleaner
        case .adultContent: return .adultContentFilter
        case .gambling: return .gamblingFilter
        case .imageBlocking: return .imageBlocking
        }
    }
}
