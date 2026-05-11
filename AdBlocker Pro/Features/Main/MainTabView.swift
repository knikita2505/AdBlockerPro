import SwiftUI

struct MainTabView: View {

    @Bindable var appState = AppState.shared
    @Bindable var subscriptionManager = SubscriptionManager.shared

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            Tab(AppTab.safari.title, systemImage: AppTab.safari.icon, value: AppTab.safari) {
                SafariMainView()
            }

            Tab(AppTab.network.title, systemImage: AppTab.network.icon, value: AppTab.network) {
                NetworkCheckView()
            }

            Tab(AppTab.passwords.title, systemImage: AppTab.passwords.icon, value: AppTab.passwords) {
                PasswordManagerView()
            }
        }
        .tint(AppTheme.accent)
        .fullScreenCover(isPresented: $subscriptionManager.showPaywall) {
            PaywallView(placement: subscriptionManager.currentPlacement)
        }
    }
}

#Preview {
    MainTabView()
}
