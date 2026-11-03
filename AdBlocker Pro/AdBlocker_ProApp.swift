import SwiftUI
import ApphudSDK
import AppTrackingTransparency

@main
struct AdBlocker_ProApp: App {

    @State private var appState = AppState.shared
    @State private var subscriptionManager = SubscriptionManager.shared
    @State private var didHandleLaunch = false
    @State private var launchStage: LaunchStage

    init() {
        #if DEBUG
        Apphud.enableDebugLogs()
        #endif
        Apphud.start(apiKey: SDKConfig.apphudAPIKey)
        AppsFlyerService.shared.configure()
        AppMetricaService.shared.activate()

        let needsOnboarding = !AppState.shared.hasCompletedOnboarding && !Apphud.hasActiveSubscription()
        _launchStage = State(initialValue: needsOnboarding ? .onboarding : .main)
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                switch launchStage {
                case .onboarding:
                    OnboardingView {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            launchStage = .offer
                        }
                    }
                    .transition(.opacity)
                case .offer:
                    LaunchOfferView {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            launchStage = .main
                        }
                        Task { await finishLaunchPaywall() }
                    }
                    .transition(.opacity)
                case .main:
                    MainTabView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.35), value: launchStage)
            .environment(appState)
            .environment(subscriptionManager)
            .preferredColorScheme(.light)
            .task {
                await handleColdStart()
            }
        }
    }

    private func handleColdStart() async {
        guard !didHandleLaunch else { return }
        didHandleLaunch = true
        subscriptionManager.checkSubscriptionStatus()

        if subscriptionManager.isPremium {
            launchStage = .main
            await appState.presentSafariSetupIfNeeded()
            return
        }

        if !appState.hasCompletedOnboarding {
            launchStage = .onboarding
            return
        }

        await continueAfterOnboarding()
    }

    private func continueAfterOnboarding() async {
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            try? await Task.sleep(for: .milliseconds(500))
            _ = await AppsFlyerService.shared.requestATTPermission()
        }
        subscriptionManager.checkSubscriptionStatus()

        if subscriptionManager.isPremium {
            await appState.presentSafariSetupIfNeeded()
            return
        }

        appState.pendingSafariSetupAfterPaywall = !appState.hasShownSafariSetupAfterOnboarding
        subscriptionManager.showPaywall(for: .launch)
    }

    private func finishLaunchPaywall() async {
        try? await Task.sleep(for: .milliseconds(350))
        subscriptionManager.checkSubscriptionStatus()
        if !subscriptionManager.isPremium {
            await AdPresentationService.shared.showAfterPaywallIfNeeded()
        }
        await appState.presentSafariSetupIfNeeded()
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

private enum LaunchStage {
    case onboarding
    case offer
    case main
}
