import SwiftUI
import ApphudSDK

@main
struct AdBlocker_ProApp: App {

    @State private var appState = AppState.shared
    @State private var subscriptionManager = SubscriptionManager.shared

    init() {
        Apphud.start(apiKey: SDKConfig.apphudAPIKey)
        AppsFlyerService.shared.configure()
        AppMetricaService.shared.activate()
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if !appState.hasCompletedOnboarding {
                    OnboardingView()
                } else {
                    MainTabView()
                }
            }
            .environment(appState)
            .environment(subscriptionManager)
            .preferredColorScheme(.light)
            .onAppear {
                subscriptionManager.checkSubscriptionStatus()
            }
            .onChange(of: appState.hasCompletedOnboarding) { _, completed in
                guard completed else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    startFirstLaunchPaywallIfNeeded()
                }
            }
        }
    }

    private func startFirstLaunchPaywallIfNeeded() {
        if !subscriptionManager.isPremium {
            appState.pendingSafariSetupAfterPaywall = true
            subscriptionManager.showPaywall(for: .onboarding)
        } else if !appState.hasShownSafariSetupAfterOnboarding {
            appState.hasShownSafariSetupAfterOnboarding = true
            appState.showSafariSetupGuide = true
        }
    }

    private func configureAppearance() {
        #if os(iOS)
        let bgColor = UIColor(red: 0.98, green: 0.984, blue: 0.988, alpha: 1)

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = bgColor
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        navBarAppearance.backgroundColor = bgColor
        navBarAppearance.shadowColor = .clear
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        #endif
    }
}
