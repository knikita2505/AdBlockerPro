import SwiftUI

struct PrivacyGuidesView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingS) {
                    Text(String(localized: "Step-by-step guides to improve your device security"))
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, AppTheme.spacingS)

                    VStack(spacing: 0) {
                        ForEach(Array(PrivacyGuide.allGuides.enumerated()), id: \.element.id) { index, guide in
                            NavigationLink {
                                PrivacyGuideDetailView(guide: guide)
                            } label: {
                                GuideListCard(guide: guide)
                            }
                            .buttonStyle(.plain)

                            if index < PrivacyGuide.allGuides.count - 1 {
                                Divider()
                                    .padding(.leading, 62)
                            }
                        }
                    }
                    .cardStyle(padding: 0)
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.top, AppTheme.spacingM)
                .padding(.bottom, AppTheme.spacingL)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle(String(localized: "Privacy Guides"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Done")) { dismiss() }
                        .font(AppTheme.bodyMedium)
                        .foregroundStyle(AppTheme.accent)
                }
            }
        }
    }
}

// MARK: - Guide List Card

private struct GuideListCard: View {
    let guide: PrivacyGuide
    var progressStore = GuideProgressStore.shared

    private var completedCount: Int {
        min(progressStore.completedCount(for: guide.id), guide.steps.count)
    }

    private var isComplete: Bool {
        progressStore.isComplete(guideId: guide.id, total: guide.steps.count)
    }

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.spacingM) {
            Image(systemName: isComplete ? "checkmark" : guide.icon)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(isComplete ? AppTheme.accent : guide.color)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 5) {
                Text(guide.title)
                    .font(AppTheme.bodyMedium)
                    .foregroundStyle(AppTheme.primaryText)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(guide.subtitle)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: AppTheme.spacingS) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(guide.color.opacity(0.12))
                            Capsule()
                                .fill(isComplete ? AppTheme.accent : guide.color)
                                .frame(width: geo.size.width * progress)
                        }
                    }
                    .frame(height: 4)

                    Text("\(completedCount)/\(guide.steps.count)")
                        .font(AppTheme.captionMedium)
                        .foregroundStyle(isComplete ? AppTheme.accent : AppTheme.tertiaryText)
                        .monospacedDigit()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.tertiaryText)
                .padding(.top, 8)
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.vertical, 14)
    }

    private var progress: CGFloat {
        guard !guide.steps.isEmpty else { return 0 }
        return CGFloat(completedCount) / CGFloat(guide.steps.count)
    }
}

// MARK: - Detail View

struct PrivacyGuideDetailView: View {

    let guide: PrivacyGuide
    var progressStore = GuideProgressStore.shared

    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0

    private var isLastStep: Bool {
        currentStep >= guide.steps.count - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            TabView(selection: $currentStep) {
                ForEach(guide.steps.indices, id: \.self) { index in
                    GuideStepCard(
                        guide: guide,
                        stepIndex: index,
                        stepText: guide.steps[index],
                        isCompleted: progressStore.completedSteps(for: guide.id).contains(index)
                    )
                    .padding(.horizontal, AppTheme.spacingM)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 340)

            pageDots
                .padding(.top, AppTheme.spacingS)

            Spacer(minLength: AppTheme.spacingM)

            if currentStep > 0 {
                Button {
                    HapticManager.impact(.light)
                    withAnimation(.easeInOut(duration: 0.25)) {
                        currentStep = 0
                    }
                } label: {
                    Label(String(localized: "Start Over"), systemImage: "arrow.counterclockwise")
                        .font(AppTheme.captionMedium)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .padding(.bottom, AppTheme.spacingS)
            }

            controls
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.bottom, AppTheme.spacingL)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle(guide.shortTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let saved = progressStore.currentPage(for: guide.id)
            currentStep = min(max(saved, 0), guide.steps.count - 1)
        }
        .onDisappear {
            progressStore.setPage(currentStep, guideId: guide.id)
            progressStore.markStep(currentStep, guideId: guide.id)
        }
        .onChange(of: currentStep) { oldValue, newValue in
            progressStore.setPage(newValue, guideId: guide.id)
            if newValue > oldValue {
                progressStore.markCompleted(upTo: oldValue, guideId: guide.id)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(guide.title)
                .font(AppTheme.titleSmall)
                .foregroundStyle(AppTheme.primaryText)
                .multilineTextAlignment(.center)

            Text(String(localized: "Step \(currentStep + 1) of \(guide.steps.count)"))
                .font(AppTheme.captionMedium)
                .foregroundStyle(guide.color)
        }
        .padding(.horizontal, AppTheme.spacingL)
        .padding(.top, AppTheme.spacingM)
        .padding(.bottom, AppTheme.spacingS)
    }

    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(guide.steps.indices, id: \.self) { index in
                Capsule()
                    .fill(index == currentStep ? guide.color : guide.color.opacity(0.2))
                    .frame(width: index == currentStep ? 16 : 6, height: 6)
                    .animation(.easeInOut(duration: 0.2), value: currentStep)
            }
        }
    }

    private var controls: some View {
        HStack(spacing: AppTheme.spacingS) {
            if currentStep > 0 {
                Button {
                    HapticManager.impact(.light)
                    withAnimation(.easeInOut(duration: 0.25)) {
                        currentStep -= 1
                    }
                } label: {
                    Text(String(localized: "Back"))
                        .font(AppTheme.bodyMedium)
                        .foregroundStyle(AppTheme.primaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
                        .shadow(color: AppTheme.shadowSoft, radius: 8, y: 2)
                }
                .buttonStyle(.plain)
            }

            Button {
                HapticManager.impact(.medium)
                progressStore.markStep(currentStep, guideId: guide.id)
                if isLastStep {
                    progressStore.markCompleted(upTo: currentStep, guideId: guide.id)
                    dismiss()
                } else {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        currentStep += 1
                    }
                }
            } label: {
                Text(isLastStep ? String(localized: "Done") : String(localized: "Next"))
                    .font(AppTheme.bodyMedium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(guide.color)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Step Card

private struct GuideStepCard: View {
    let guide: PrivacyGuide
    let stepIndex: Int
    let stepText: String
    let isCompleted: Bool

    private var showsSettingsAction: Bool {
        guide.id == "content-blocker" && stepIndex == 3
    }

    var body: some View {
        VStack(spacing: AppTheme.spacingL) {
            ZStack {
                Circle()
                    .fill(guide.color.opacity(0.12))
                    .frame(width: 72, height: 72)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(guide.color)
                } else {
                    Text("\(stepIndex + 1)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(guide.color)
                }
            }

            Text(stepText)
                .font(AppTheme.bodyLarge)
                .foregroundStyle(AppTheme.primaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if showsSettingsAction {
                Button {
                    #if os(iOS)
                    if let url = URL(string: "App-prefs:SAFARI&path=WEB_EXTENSIONS") {
                        UIApplication.shared.open(url)
                    }
                    #endif
                } label: {
                    Text(String(localized: "Open Settings"))
                        .font(AppTheme.captionMedium)
                        .foregroundStyle(guide.color)
                }
            }
        }
        .padding(AppTheme.spacingL)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusXL, style: .continuous))
        .shadow(color: AppTheme.shadowSoft, radius: 14, y: 6)
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
                String(localized: "Open Settings on your device"),
                String(localized: "Go to Apps, then tap Safari"),
                String(localized: "Tap Extensions"),
                String(localized: "Find AdBlocker Pro and turn it on"),
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
