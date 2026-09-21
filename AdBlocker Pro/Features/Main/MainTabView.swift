import SwiftUI

struct MainTabView: View {

    @Bindable var appState = AppState.shared
    @Bindable var subscriptionManager = SubscriptionManager.shared

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            Tab(AppTab.network.title, systemImage: AppTab.network.icon, value: AppTab.network) {
                NetworkCheckView()
            }

            Tab(AppTab.safari.title, systemImage: AppTab.safari.icon, value: AppTab.safari) {
                SafariMainView()
            }

            Tab(AppTab.passwords.title, systemImage: AppTab.passwords.icon, value: AppTab.passwords) {
                PasswordManagerView()
            }
        }
        .tint(AppTheme.accent)
        .task {
            await ConsentService.shared.prepareAdsAfterTrackingDecision()
        }
        .fullScreenCover(isPresented: $subscriptionManager.showPaywall, onDismiss: {
            Task { await handlePaywallDismissed() }
        }) {
            if subscriptionManager.currentPlacement == .onboarding {
                PaywallView(placement: subscriptionManager.currentPlacement)
            } else {
                PremiumPaywallView(placement: subscriptionManager.currentPlacement)
            }
        }
        .fullScreenCover(isPresented: $appState.showSafariSetupGuide) {
            SafariSetupGuideView()
        }
    }

    private func handlePaywallDismissed() async {
        await AdPresentationService.shared.showAfterPaywallIfNeeded()
        guard appState.pendingSafariSetupAfterPaywall else { return }
        appState.pendingSafariSetupAfterPaywall = false
        if !appState.hasShownSafariSetupAfterOnboarding {
            appState.hasShownSafariSetupAfterOnboarding = true
            try? await Task.sleep(nanoseconds: 400_000_000)
            appState.showSafariSetupGuide = true
        }
    }
}

#Preview {
    MainTabView()
}
