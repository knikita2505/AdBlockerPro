import SwiftUI

struct OnboardingView: View {

    var appState = AppState.shared
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "shield.checkered",
            color: Color(hex: "10B981"),
            title: String(localized: "Block Ads in Safari"),
            subtitle: String(localized: "Remove annoying ads, banners and pop-ups from websites you visit in Safari")
        ),
        OnboardingPage(
            icon: "eye.slash.fill",
            color: Color(hex: "6366F1"),
            title: String(localized: "Stop Trackers"),
            subtitle: String(localized: "Prevent websites and advertisers from tracking your online activity")
        ),
        OnboardingPage(
            icon: "xmark.rectangle.fill",
            color: Color(hex: "F59E0B"),
            title: String(localized: "Hide Cookie Banners"),
            subtitle: String(localized: "Automatically dismiss cookie consent pop-ups for a cleaner browsing experience")
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            color: Color(hex: "8B5CF6"),
            title: String(localized: "Privacy Tools"),
            subtitle: String(localized: "Network privacy check, secure password generator and privacy guides — all in one app")
        )
    ]

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button(String(localized: "Skip")) {
                            completeOnboarding()
                        }
                        .font(AppTheme.bodyMedium)
                        .foregroundColor(AppTheme.tertiaryText)
                        .padding()
                    }
                }

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        pageView(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                bottomSection
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                AppTheme.background,
                pages[currentPage].color.opacity(0.05),
                AppTheme.background
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: currentPage)
    }

    // MARK: - Page

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: AppTheme.spacingXL) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [page.color.opacity(0.2), page.color.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)

                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: page.icon)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [page.color, page.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .shadow(color: page.color.opacity(0.2), radius: 30)

            VStack(spacing: AppTheme.spacingM) {
                Text(page.title)
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.primaryText)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(AppTheme.bodyLarge)
                    .foregroundColor(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, AppTheme.spacingXL)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Bottom

    private var bottomSection: some View {
        VStack(spacing: AppTheme.spacingL) {
            HStack(spacing: AppTheme.spacingS) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage
                              ? AppTheme.accent
                              : AppTheme.tertiaryText.opacity(0.3))
                        .frame(width: index == currentPage ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.4), value: currentPage)
                }
            }

            Button {
                HapticManager.impact(.medium)
                if currentPage < pages.count - 1 {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentPage += 1
                    }
                } else {
                    completeOnboarding()
                }
            } label: {
                HStack(spacing: AppTheme.spacingS) {
                    Text(currentPage < pages.count - 1
                         ? String(localized: "Continue")
                         : String(localized: "Get Started"))
                        .font(AppTheme.bodyMedium)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacingM)
                .background(
                    LinearGradient(
                        colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
                .shadow(color: AppTheme.accent.opacity(0.3), radius: 15, y: 8)
            }
            .padding(.horizontal, AppTheme.spacingL)
        }
        .padding(.bottom, AppTheme.spacingXL)
    }

    private func completeOnboarding() {
        HapticManager.impact(.medium)
        appState.hasCompletedOnboarding = true
    }
}

// MARK: - Model

private struct OnboardingPage {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
}

#Preview {
    OnboardingView()
}
