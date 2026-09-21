import SwiftUI

struct PremiumPaywallView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var vm: PaywallViewModel

    let placement: PaywallPlacement

    init(placement: PaywallPlacement = .premiumFeature) {
        self.placement = placement
        self._vm = State(wrappedValue: PaywallViewModel(placement: placement))
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "ECFDF5"), Color.white],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        Text(String(localized: "Ad blocking and Wi-Fi security is ready to protect your device"))
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.primaryText)
                            .multilineTextAlignment(.center)

                        Text(vm.trialPriceLine)
                            .font(AppTheme.bodyFont)
                            .foregroundStyle(AppTheme.tertiaryText)

                        planPicker
                        trialTimeline
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }

                Spacer(minLength: 8)

                Button {
                    vm.purchaseSelected()
                } label: {
                    ZStack {
                        if vm.isPurchasing {
                            ProgressView().tint(.white)
                        } else {
                            Text(String(localized: "Continue"))
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.accent)
                    .clipShape(Capsule())
                }
                .disabled(vm.isPurchasing || vm.isLoadingProducts)
                .padding(.horizontal, 24)

                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11))
                    Text(String(localized: "Protected by Apple"))
                        .font(AppTheme.captionFont)
                }
                .foregroundStyle(AppTheme.tertiaryText)
                .padding(.top, 12)

                HStack(spacing: 16) {
                    Link(String(localized: "Terms of Use"), destination: URL(string: PaywallConstants.termsURL)!)
                    Link(String(localized: "Privacy Policy"), destination: URL(string: PaywallConstants.privacyURL)!)
                }
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.tertiaryText)
                .padding(.top, 10)
                .padding(.bottom, 16)
            }
        }
        .onAppear { vm.onAppear() }
        .onChange(of: vm.purchaseSuccessful) { _, success in
            if success {
                SubscriptionManager.shared.handleSuccessfulPurchase()
                dismiss()
            }
        }
        .alert(String(localized: "Purchase Failed"), isPresented: $vm.showError) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? String(localized: "Something went wrong."))
        }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(width: 36, height: 36)
            }
            Spacer()
            Button(String(localized: "Already Purchase?")) {
                vm.restore()
            }
            .font(AppTheme.captionFont)
            .foregroundStyle(AppTheme.tertiaryText)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 12)
        .padding(.top, 4)
    }

    private var planPicker: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 0) {
                planTab(title: String(localized: "Weekly"), plan: .weekly)
                planTab(title: String(localized: "Annual"), plan: .yearly)
            }
            .padding(4)
            .background(Color(hex: "E5E7EB"))
            .clipShape(Capsule())

            if let percent = vm.yearlySavePercent {
                Text(String(localized: "SAVE \(percent)%"))
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "FDBA74"))
                    .clipShape(Capsule())
                    .offset(x: -8, y: -12)
            }
        }
        .padding(.top, 8)
    }

    private func planTab(title: String, plan: PaywallSubscriptionPlan) -> some View {
        Button {
            vm.select(plan)
        } label: {
            Text(title)
                .font(AppTheme.bodyMedium)
                .foregroundStyle(vm.selectedPlan == plan ? AppTheme.primaryText : AppTheme.secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(vm.selectedPlan == plan ? Color.white : Color.clear)
                .clipShape(Capsule())
        }
    }

    private var trialTimeline: some View {
        VStack(alignment: .leading, spacing: 0) {
            timelineRow(
                icon: "lock.fill",
                title: String(localized: "Today"),
                subtitle: String(localized: "Enjoy unlimited access to ad blocking and Wi-Fi security.")
            )
            timelineConnector
            timelineRow(
                icon: "bell.fill",
                title: String(localized: "One day before"),
                subtitle: String(localized: "We'll remind you when your trial is about to end.")
            )
            timelineConnector
            timelineRow(
                icon: "sparkles",
                title: String(localized: "In 3 days"),
                subtitle: String(localized: "You will be charged, cancel anytime before then")
            )
        }
        .padding(.top, 8)
    }

    private var timelineConnector: some View {
        Rectangle()
            .fill(Color(hex: "93C5FD"))
            .frame(width: 3, height: 22)
            .padding(.leading, 18)
    }

    private func timelineRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: "DBEAFE"))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(hex: "3B82F6"))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.bodyMedium)
                    .foregroundStyle(AppTheme.primaryText)
                Text(subtitle)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
    }
}

#Preview {
    PremiumPaywallView()
}
