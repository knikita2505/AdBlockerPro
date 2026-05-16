import SwiftUI

struct PrivacyGuidesView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.spacingM) {
                        headerCard

                        ForEach(PrivacyGuide.allGuides) { guide in
                            NavigationLink {
                                PrivacyGuideDetailView(guide: guide)
                            } label: {
                                GuideListCard(guide: guide)
                            }
                            .pressable()
                        }

                        Spacer(minLength: AppTheme.spacingL)
                    }
                    .padding(.horizontal, AppTheme.spacingM)
                    .padding(.top, AppTheme.spacingM)
                }
            }
            .navigationTitle(String(localized: "Privacy Guides"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Done")) { dismiss() }
                        .font(AppTheme.bodyMedium)
                        .foregroundColor(AppTheme.accent)
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(spacing: AppTheme.spacingM) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.accentSoft, AppTheme.accent.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            Text(String(localized: "Protect Your Privacy"))
                .font(AppTheme.titleMedium)
                .foregroundStyle(AppTheme.primaryText)

            Text(String(localized: "Step-by-step guides to improve your device security"))
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.spacingL)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.spacingL)
        .cardStyle()
    }
}

// MARK: - Guide List Card

private struct GuideListCard: View {
    let guide: PrivacyGuide

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous)
                    .fill(guide.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: guide.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(guide.color)
            }

            VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                Text(guide.title)
                    .font(AppTheme.bodyMedium)
                    .foregroundStyle(AppTheme.primaryText)
                    .lineLimit(1)

                Text(guide.subtitle)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "list.number")
                        .font(.system(size: 10))
                    Text("\(guide.steps.count) \(String(localized: "steps"))")
                        .font(AppTheme.captionSmall)
                }
                .foregroundStyle(guide.color)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.tertiaryText)
        }
        .cardStyle()
    }
}

// MARK: - Detail View

struct PrivacyGuideDetailView: View {

    let guide: PrivacyGuide
    @State private var completedSteps: Set<Int> = []

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingL) {
                detailHeader
                stepsCard
            }
            .padding(.horizontal, AppTheme.spacingM)
            .padding(.vertical, AppTheme.spacingM)
        }
        .background(AppTheme.background)
        .navigationTitle(guide.shortTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var detailHeader: some View {
        VStack(spacing: AppTheme.spacingM) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [guide.color.opacity(0.2), guide.color.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: guide.icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(guide.color)
            }
            .shadow(color: guide.color.opacity(0.15), radius: 20)

            Text(guide.title)
                .font(AppTheme.titleMedium)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.primaryText)

            Text(guide.subtitle)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)

            progressBar
        }
        .frame(maxWidth: .infinity)
        .cardStyle(padding: AppTheme.spacingL)
    }

    private var progressBar: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(guide.color.opacity(0.12))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(guide.color)
                        .frame(width: geo.size.width * progress, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 8)

            Text("\(completedSteps.count)/\(guide.steps.count) \(String(localized: "completed"))")
                .font(AppTheme.captionSmall)
                .foregroundStyle(AppTheme.secondaryText)
        }
    }

    private var progress: Double {
        guard !guide.steps.isEmpty else { return 0 }
        return Double(completedSteps.count) / Double(guide.steps.count)
    }

    private var stepsCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(guide.steps.enumerated()), id: \.offset) { index, step in
                stepRow(index: index, text: step, isLast: index == guide.steps.count - 1)
            }
        }
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        .shadow(color: AppTheme.shadowSoft, radius: 8, x: 0, y: 2)
        .shadow(color: AppTheme.shadowMedium, radius: 1, x: 0, y: 1)
    }

    private func stepRow(index: Int, text: String, isLast: Bool) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if completedSteps.contains(index) {
                    completedSteps.remove(index)
                } else {
                    completedSteps.insert(index)
                    HapticManager.impact(.light)
                }
            }
        } label: {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: AppTheme.spacingM) {
                    ZStack {
                        Circle()
                            .fill(completedSteps.contains(index)
                                  ? guide.color
                                  : guide.color.opacity(0.12))
                            .frame(width: 32, height: 32)

                        if completedSteps.contains(index) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        } else {
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(guide.color)
                        }
                    }

                    Text(text)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(completedSteps.contains(index)
                                         ? AppTheme.secondaryText
                                         : AppTheme.primaryText)
                        .strikethrough(completedSteps.contains(index))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 5)
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.vertical, 14)

                if !isLast {
                    Divider().padding(.leading, 60)
                }
            }
        }
    }
}

// MARK: - Guide Model

struct PrivacyGuide: Identifiable, Hashable {
    let id: String
    let icon: String
    let color: Color
    let title: String
    let shortTitle: String
    let subtitle: String
    let steps: [String]

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: PrivacyGuide, rhs: PrivacyGuide) -> Bool { lhs.id == rhs.id }

    static let allGuides: [PrivacyGuide] = [
        PrivacyGuide(
            id: "content-blocker",
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
            id: "app-tracking",
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
            id: "location",
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
            id: "notifications",
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
            id: "two-factor",
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
            id: "safari-privacy",
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
