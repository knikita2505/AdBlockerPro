//
//  AdBlocker_ProApp.swift
//  AdBlocker Pro
//
//  Created by Nikita on 11/05/2026.
//

import SwiftUI
import ApphudSDK

@main
struct AdBlocker_ProApp: App {

    @State private var appState = AppState.shared
    @State private var subscriptionManager = SubscriptionManager.shared

    init() {
        Apphud.start(apiKey: "app_8861UZSwNCVX4Q2BGRXtDD6PKobhSA")
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
            .onAppear {
                subscriptionManager.checkSubscriptionStatus()
            }
            .onChange(of: appState.hasCompletedOnboarding) { _, completed in
                if completed {
                    subscriptionManager.currentPlacement = .onboarding
                    subscriptionManager.showPaywall = true
                }
            }
        }
    }

    private func configureAppearance() {
        #if os(iOS)
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        #endif
    }
}
