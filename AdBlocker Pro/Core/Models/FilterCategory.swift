import SwiftUI

enum FilterCategory: String, CaseIterable, Identifiable, Codable {
    case ads = "ads"
    case trackers = "trackers"
    case cookieBanners = "cookie_banners"
    case adultContent = "adult_content"
    case gambling = "gambling"
    case imageBlocking = "image_blocking"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ads: return String(localized: "Ad Blocking")
        case .trackers: return String(localized: "Tracker Protection")
        case .cookieBanners: return String(localized: "Cookie Banner Cleaner")
        case .adultContent: return String(localized: "Adult Content Filter")
        case .gambling: return String(localized: "Gambling Filter")
        case .imageBlocking: return String(localized: "Image Blocking Mode")
        }
    }

    var subtitle: String {
        switch self {
        case .ads: return String(localized: "Block ads and promotional content in Safari")
        case .trackers: return String(localized: "Block tracking scripts and analytics")
        case .cookieBanners: return String(localized: "Hide cookie consent banners")
        case .adultContent: return String(localized: "Filter adult websites")
        case .gambling: return String(localized: "Filter gambling websites")
        case .imageBlocking: return String(localized: "Save bandwidth by blocking images")
        }
    }

    var icon: String {
        switch self {
        case .ads: return "nosign"
        case .trackers: return "eye.slash.fill"
        case .cookieBanners: return "xmark.rectangle.fill"
        case .adultContent: return "exclamationmark.shield.fill"
        case .gambling: return "suit.club.fill"
        case .imageBlocking: return "photo.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .ads: return .red
        case .trackers: return .blue
        case .cookieBanners: return .orange
        case .adultContent: return .purple
        case .gambling: return .pink
        case .imageBlocking: return .gray
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
