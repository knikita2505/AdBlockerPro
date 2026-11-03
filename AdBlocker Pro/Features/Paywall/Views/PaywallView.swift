import SwiftUI
import ApphudSDK
import StoreKit
import Observation

struct PaywallView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var vm: PaywallViewModel
    @State private var pulse = false

    let placement: PaywallPlacement
    private let onDismissed: (() -> Void)?

    init(
        placement: PaywallPlacement = .launch,
        viewModel: PaywallViewModel? = nil,
        onDismissed: (() -> Void)? = nil
    ) {
        self.placement = placement
        self.onDismissed = onDismissed
        self._vm = State(wrappedValue: viewModel ?? PaywallViewModel(placement: placement))
    }

    private let features: [(color: Color, icon: String, title: String, subtitle: String)] = [
        (
            Color(hex: "3B82F6"),
            "hand.raised.fill",
            String(localized: "Block ads and speed up page loading"),
            String(localized: "Block annoying ads and enjoy faster browsing")
        ),
        (
            Color(hex: "F59E0B"),
            "eye.slash.fill",
            String(localized: "Stop trackers in Safari"),
            String(localized: "Prevent websites from tracking your activity")
        ),
        (
            Color(hex: "10B981"),
            "wifi",
            String(localized: "Check your Wi-Fi privacy"),
            String(localized: "Scan the network you are connected to")
        ),
        (
            Color(hex: "A78BFA"),
            "lock.fill",
            String(localized: "Save strong passwords"),
            String(localized: "Keep logins in a protected vault")
        )
    ]

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button { close() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(Color.black.opacity(0.08))
                            .frame(width: 32, height: 32)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        Image("AppShield")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 148, height: 148)
                            .padding(.top, 4)

                        Text(String(localized: "Ad blocking and Wi-Fi security is ready to protect your device"))
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.primaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)

                        if !vm.trialPriceLine.isEmpty {
                            Text(vm.trialPriceLine)
                                .font(AppTheme.bodyFont)
                                .foregroundStyle(AppTheme.tertiaryText)
                                .multilineTextAlignment(.center)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(Array(features.enumerated()), id: \.offset) { _, item in
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(item.color.opacity(0.15))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: item.icon)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(item.color)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.title)
                                            .font(AppTheme.bodyMedium)
                                            .foregroundStyle(AppTheme.primaryText)
                                        Text(item.subtitle)
                                            .font(AppTheme.captionFont)
                                            .foregroundStyle(AppTheme.secondaryText)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding(.bottom, 12)
                }

                Spacer(minLength: 8)

                Button {
                    vm.select(.weekly)
                    vm.purchaseSelected()
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accent.opacity(0.12))
                            .frame(width: 188, height: 188)
                            .scaleEffect(pulse ? 1.08 : 1.0)
                        Circle()
                            .fill(AppTheme.accent.opacity(0.18))
                            .frame(width: 156, height: 156)
                            .scaleEffect(pulse ? 1.05 : 1.0)
                        Circle()
                            .fill(AppTheme.accent)
                            .frame(width: 124, height: 124)
                            .shadow(color: AppTheme.accent.opacity(0.35), radius: 16, y: 8)
                        if vm.isPurchasing {
                            ProgressView().tint(.white)
                        } else {
                            Text(String(localized: "START"))
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .disabled(vm.isPurchasing || vm.isLoadingProducts)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                        pulse = true
                    }
                }

                footerLinks
                    .padding(.top, 20)
                    .padding(.bottom, 16)
            }
        }
        .onAppear { vm.onAppear() }
        .onChange(of: vm.purchaseSuccessful) { _, success in
            if success {
                SubscriptionManager.shared.handleSuccessfulPurchase()
                close()
            }
        }
        .alert(String(localized: "Purchase Failed"), isPresented: $vm.showError) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? String(localized: "Something went wrong."))
        }
    }

    private func close() {
        if let onDismissed {
            onDismissed()
        } else {
            dismiss()
        }
    }

    private var footerLinks: some View {
        HStack(spacing: 16) {
            Link(String(localized: "Terms of Use"), destination: URL(string: PaywallConstants.termsURL)!)
            Button(String(localized: "Restore")) { vm.restore() }
            Link(String(localized: "Privacy Policy"), destination: URL(string: PaywallConstants.privacyURL)!)
        }
        .font(AppTheme.captionFont)
        .foregroundStyle(AppTheme.tertiaryText)
    }
}

#Preview {
    PaywallView(placement: .launch)
}
