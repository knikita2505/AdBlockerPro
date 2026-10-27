import SwiftUI

struct PremiumPaywallView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var vm: PaywallViewModel
    @State private var pulse = false

    let placement: PaywallPlacement

    init(placement: PaywallPlacement = .premiumFeatures) {
        self.placement = placement
        self._vm = State(wrappedValue: PaywallViewModel(placement: placement))
    }

    private let features: [(icon: String, color: Color, title: String, isAsterisk: Bool)] = [
        ("hand.raised.fill", Color(hex: "3B82F6"), String(localized: "Block ads and speed up page loading"), false),
        ("lock.fill", Color(hex: "7C6BF2"), String(localized: "Secure space for your media and contacts"), false),
        ("safari", Color(hex: "3B82F6"), String(localized: "Browser with protection against phishing"), false),
        ("", Color(hex: "7C6BF2"), String(localized: "Complex passwords to protect accounts"), true)
    ]

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        Text(String(localized: "Ads block and wifi security tool is ready to protect your device"))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color(hex: "1A1D21"))
                            .fixedSize(horizontal: false, vertical: true)

                        hero
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)

                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(Array(features.enumerated()), id: \.offset) { _, item in
                                featureRow(item)
                            }
                        }

                        VStack(spacing: 12) {
                            planCard(
                                title: vm.yearlyCardTitle,
                                price: vm.yearlyCardPrice,
                                plan: .yearly,
                                savePercent: vm.yearlySavePercent
                            )
                            planCard(
                                title: vm.weeklyCardTitle,
                                price: vm.weeklyCardPrice,
                                plan: .weekly,
                                savePercent: nil
                            )
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 12)
                }

                Button {
                    vm.purchaseSelected()
                } label: {
                    ZStack {
                        if vm.isPurchasing {
                            ProgressView().tint(.white)
                        } else {
                            Text(String(localized: "Continue"))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.accent)
                    .clipShape(Capsule())
                }
                .disabled(vm.isPurchasing || vm.isLoadingProducts)
                .padding(.horizontal, 22)
                .padding(.top, 8)

                HStack(spacing: 22) {
                    Link(String(localized: "Terms of Use"), destination: URL(string: PaywallConstants.termsURL)!)
                    Link(String(localized: "Privacy Policy"), destination: URL(string: PaywallConstants.privacyURL)!)
                }
                .font(.system(size: 13))
                .foregroundStyle(Color(hex: "9CA3AF"))
                .padding(.top, 14)
                .padding(.bottom, 12)
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
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.black.opacity(0.08))
                    .frame(width: 32, height: 32)
            }
            Spacer()
            Button(String(localized: "Restore Purchase")) {
                vm.restore()
            }
            .font(.system(size: 15))
            .foregroundStyle(Color(hex: "9CA3AF"))
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    private var hero: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "E7F8F1"))
                .frame(width: 176, height: 176)
                .scaleEffect(pulse ? 1.08 : 1.0)
            Circle()
                .fill(Color(hex: "D7F3E6"))
                .frame(width: 136, height: 136)
                .scaleEffect(pulse ? 1.05 : 1.0)
            Circle()
                .fill(AppTheme.accent)
                .frame(width: 96, height: 96)
            Image(systemName: "shield")
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(.white)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private func featureRow(_ item: (icon: String, color: Color, title: String, isAsterisk: Bool)) -> some View {
        HStack(spacing: 14) {
            Group {
                if item.isAsterisk {
                    Text("***")
                        .font(.system(size: 15, weight: .bold))
                } else {
                    Image(systemName: item.icon)
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .foregroundStyle(item.color)
            .frame(width: 28, alignment: .center)

            Text(item.title)
                .font(.system(size: 16))
                .foregroundStyle(Color(hex: "1A1D21"))
        }
    }

    private func planCard(title: String, price: String?, plan: PaywallSubscriptionPlan, savePercent: Int?) -> some View {
        let isSelected = vm.selectedPlan == plan

        return Button {
            vm.select(plan)
        } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title.isEmpty ? " " : title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color(hex: "1A1D21"))
                    if vm.isLoadingProducts {
                        ProgressView()
                            .controlSize(.small)
                    } else if let price {
                        Text(price)
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: "6B7280"))
                    }
                }
                Spacer(minLength: 8)
                if let savePercent {
                    Text(String(localized: "SAVE \(savePercent)%"))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color(hex: "F5A524"))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? AppTheme.accent : Color.black.opacity(0.12), lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PremiumPaywallView()
}
