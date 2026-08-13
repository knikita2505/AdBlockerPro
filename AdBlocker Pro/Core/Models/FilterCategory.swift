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
        case .trackers: return String(localized: "Prevent activity tracking")
        case .adultContent: return String(localized: "Make browsing safe for kids")
        case .imageBlocking: return String(localized: "Save data by skipping images")
        case .gambling: return String(localized: "Block betting & casino sites")
        }
    }

    var tooltip: String {
        switch self {
        case .ads: return String(localized: "Blocks banners, pop-ups and video ads from 80+ ad networks including Google Ads, Facebook Ads, Taboola, Outbrain and others. Pages load faster and look cleaner.")
        case .cookieBanners: return String(localized: "Hides annoying cookie consent pop-ups and GDPR banners that appear on almost every website. The scripts that show them are blocked, and the banner elements are hidden via CSS.")
        case .trackers: return String(localized: "Prevents websites from tracking your behavior. Blocks analytics services like Google Analytics, Facebook Pixel, Yandex Metrica, Hotjar and 50+ other tracking tools.")
        case .adultContent: return String(localized: "Blocks loading of 70+ adult websites by domain — including pornhub.com, eporner.com and their regional mirrors. Safari will show a content blocker message instead of the page.")
        case .imageBlocking: return String(localized: "Prevents all images from loading on any website. Significantly reduces data usage on mobile networks. Text content remains accessible.")
        case .gambling: return String(localized: "Blocks loading of 60+ gambling and betting sites by domain — casinos, sportsbooks and poker rooms. Works across all regional domains (.com, .ru, etc.).")
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
