import SwiftUI

struct ProBadgeButton: View {

    var subscriptionManager = SubscriptionManager.shared

    var body: some View {
        if !subscriptionManager.isPremium {
            Button {
                HapticManager.impact(.light)
                subscriptionManager.showPaywall(for: .premiumFeatures)
            } label: {
                Text("PRO")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("PRO")
        }
    }
}
