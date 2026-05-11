import SwiftUI

struct OnboardingView: View {

    var appState = AppState.shared
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "shield.checkered",
            iconColor: .green,
            title: String(localized: "Block Ads in Safari"),
            subtitle: String(localized: "Remove annoying ads, banners and pop-ups from websites you visit in Safari")
        ),
        OnboardingPage(
            icon: "eye.slash.fill",
            iconColor: .blue,
            title: String(localized: "Stop Trackers"),
            subtitle: String(localized: "Prevent websites and advertisers from tracking your online activity")
        ),
        OnboardingPage(
            icon: "xmark.rectangle.fill",
            iconColor: .orange,
            title: String(localized: "Hide Cookie Banners"),
            subtitle: String(localized: "Automatically dismiss cookie consent pop-ups for a cleaner browsing experience")
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            iconColor: .green,
            title: String(localized: "Privacy Tools"),
            subtitle: String(localized: "Network privacy check, secure password generator and privacy guides — all in one app")
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    pageView(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            bottomSection
        }
        .background(AppTheme.background)
    }

    // MARK: - Page View

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: AppTheme.spacingL) {
            Spacer()

            ZStack {
                Circle()
                    .fill(page.iconColor.opacity(0.12))
                    .frame(width: 140, height: 140)
                Image(systemName: page.icon)
                    .font(.system(size: 60, weight: .medium))
                    .foregroundStyle(page.iconColor)
            }

            VStack(spacing: AppTheme.spacingM) {
                Text(page.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.spacingXL)
            }

            Spacer()
            Spacer()
        }
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
        VStack(spacing: AppTheme.spacingM) {
            pageIndicator

            Button {
                if currentPage < pages.count - 1 {
                    withAnimation { currentPage += 1 }
                } else {
                    completeOnboarding()
                }
            } label: {
                Text(currentPage < pages.count - 1
                     ? String(localized: "Continue")
                     : String(localized: "Get Started"))
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
            }

            if currentPage < pages.count - 1 {
                Button {
                    completeOnboarding()
                } label: {
                    Text("Skip")
                        .font(AppTheme.footnoteFont)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
        }
        .padding(.horizontal, AppTheme.spacingL)
        .padding(.bottom, AppTheme.spacingXL)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? AppTheme.accent : AppTheme.accent.opacity(0.25))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }

    private func completeOnboarding() {
        HapticManager.impact(.medium)
        appState.hasCompletedOnboarding = true
    }
}

// MARK: - Model

private struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
}

#Preview {
    OnboardingView()
}
