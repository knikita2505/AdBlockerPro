import SwiftUI
import ApphudSDK

@main
struct AdBlocker_ProApp: App {

    @State private var appState = AppState.shared
    @State private var subscriptionManager = SubscriptionManager.shared
    @State private var showLaunchSetup = true

    init() {
        #if DEBUG
        Apphud.enableDebugLogs()
        #endif
        Apphud.start(apiKey: SDKConfig.apphudAPIKey)
        AppsFlyerService.shared.configure()
        AppMetricaService.shared.activate()
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()

                if showLaunchSetup, !subscriptionManager.isPremium {
                    LaunchSetupView {
                        finishLaunchSetup()
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .environment(appState)
            .environment(subscriptionManager)
            .preferredColorScheme(.light)
            .onAppear {
                subscriptionManager.checkSubscriptionStatus()
                if subscriptionManager.isPremium {
                    showLaunchSetup = false
                }
            }
        }
    }

    private func finishLaunchSetup() {
        subscriptionManager.checkSubscriptionStatus()
        withAnimation(.easeOut(duration: 0.25)) {
            showLaunchSetup = false
        }

        if !subscriptionManager.isPremium {
            appState.pendingSafariSetupAfterPaywall = !appState.hasShownSafariSetupAfterOnboarding
            subscriptionManager.showPaywall(for: .launch)
        } else {
            Task { await appState.presentSafariSetupIfNeeded() }
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
