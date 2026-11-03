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
        .fullScreenCover(isPresented: $subscriptionManager.showPaywall, onDismiss: {
            Task { await handlePaywallDismissed() }
        }) {
            if subscriptionManager.currentPlacement == .launch {
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
        await appState.presentSafariSetupIfNeeded()
    }
}

#Preview {
    MainTabView()
}
