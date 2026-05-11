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
            .preferredColorScheme(.light)
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
        tabBarAppearance.backgroundColor = .white
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        navBarAppearance.backgroundColor = .white
        navBarAppearance.shadowColor = UIColor(white: 0.92, alpha: 1)
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        #endif
    }
}
