import SwiftUI

struct PrivacyGuidesView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(PrivacyGuide.allGuides) { guide in
                    NavigationLink {
                        PrivacyGuideDetailView(guide: guide)
                    } label: {
                        HStack(spacing: AppTheme.spacingM) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(guide.color.opacity(0.12))
                                    .frame(width: 40, height: 40)
                                Image(systemName: guide.icon)
                                    .foregroundStyle(guide.color)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(guide.title)
                                    .font(AppTheme.bodyFont)
                                Text(guide.subtitle)
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.secondaryText)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppTheme.groupedBackground)
            .navigationTitle(String(localized: "Privacy Guides"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Detail View

struct PrivacyGuideDetailView: View {

    let guide: PrivacyGuide

    var body: some View {
        List {
            Section {
                VStack(spacing: AppTheme.spacingM) {
                    ZStack {
                        Circle()
                            .fill(guide.color.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: guide.icon)
                            .font(.system(size: 34))
                            .foregroundStyle(guide.color)
                    }
                    Text(guide.title)
                        .font(AppTheme.titleFont)
                        .multilineTextAlignment(.center)
                    Text(guide.subtitle)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacingS)
            }

            Section("Steps") {
                ForEach(Array(guide.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: AppTheme.spacingM) {
                        ZStack {
                            Circle()
                                .fill(guide.color)
                                .frame(width: 28, height: 28)
                            Text("\(index + 1)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        Text(step)
                            .font(AppTheme.bodyFont)
                    }
                    .padding(.vertical, AppTheme.spacingXS)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(guide.shortTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Guide Model

struct PrivacyGuide: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let title: String
    let shortTitle: String
    let subtitle: String
    let steps: [String]

    static let allGuides: [PrivacyGuide] = [
        PrivacyGuide(
            icon: "safari",
            color: .blue,
            title: String(localized: "Enable Safari Content Blocker"),
            shortTitle: String(localized: "Content Blocker"),
            subtitle: String(localized: "Block ads and trackers in Safari"),
            steps: [
                String(localized: "Open the Settings app on your device"),
                String(localized: "Scroll down and tap Safari"),
                String(localized: "Tap Extensions"),
                String(localized: "Find AdBlocker Pro and toggle it on"),
                String(localized: "Return to Safari — ads will now be blocked")
            ]
        ),
        PrivacyGuide(
            icon: "hand.raised.fill",
            color: .orange,
            title: String(localized: "Limit App Tracking"),
            shortTitle: String(localized: "App Tracking"),
            subtitle: String(localized: "Control how apps track your activity"),
            steps: [
                String(localized: "Open Settings"),
                String(localized: "Tap Privacy & Security"),
                String(localized: "Tap Tracking"),
                String(localized: "Turn off Allow Apps to Request to Track"),
                String(localized: "Previously granted permissions can be revoked individually")
            ]
        ),
        PrivacyGuide(
            icon: "location.fill",
            color: .green,
            title: String(localized: "Check Location Permissions"),
            shortTitle: String(localized: "Location"),
            subtitle: String(localized: "Review which apps access your location"),
            steps: [
                String(localized: "Open Settings"),
                String(localized: "Tap Privacy & Security"),
                String(localized: "Tap Location Services"),
                String(localized: "Review each app's location access"),
                String(localized: "Set apps to While Using or Never when possible"),
                String(localized: "Disable Precise Location for apps that don't need it")
            ]
        ),
        PrivacyGuide(
            icon: "bell.badge.fill",
            color: .red,
            title: String(localized: "Hide Notification Previews"),
            shortTitle: String(localized: "Notifications"),
            subtitle: String(localized: "Prevent sensitive content from showing on lock screen"),
            steps: [
                String(localized: "Open Settings"),
                String(localized: "Tap Notifications"),
                String(localized: "Tap Show Previews"),
                String(localized: "Select When Unlocked or Never"),
                String(localized: "This prevents message content from showing on the lock screen")
            ]
        ),
        PrivacyGuide(
            icon: "lock.shield.fill",
            color: .purple,
            title: String(localized: "Enable Two-Factor Authentication"),
            shortTitle: String(localized: "2FA"),
            subtitle: String(localized: "Add an extra layer of security to your Apple ID"),
            steps: [
                String(localized: "Open Settings"),
                String(localized: "Tap your name at the top"),
                String(localized: "Tap Sign-In & Security"),
                String(localized: "Tap Two-Factor Authentication"),
                String(localized: "Follow the prompts to set up 2FA"),
                String(localized: "Save your recovery key in a secure location")
            ]
        ),
        PrivacyGuide(
            icon: "safari",
            color: .teal,
            title: String(localized: "Check Safari Privacy Settings"),
            shortTitle: String(localized: "Safari Privacy"),
            subtitle: String(localized: "Optimize Safari for maximum privacy"),
            steps: [
                String(localized: "Open Settings and go to Safari"),
                String(localized: "Enable Prevent Cross-Site Tracking"),
                String(localized: "Enable Hide IP Address from Trackers"),
                String(localized: "Set Block All Cookies or ask websites not to track you"),
                String(localized: "Enable Fraudulent Website Warning"),
                String(localized: "Consider enabling Privacy Preserving Ad Measurement")
            ]
        )
    ]
}

#Preview {
    PrivacyGuidesView()
}
