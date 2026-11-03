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
        ("list.bullet", Color(hex: "7C6BF2"), String(localized: "Allow and block lists for websites"), false),
        ("megaphone.slash.fill", Color(hex: "3B82F6"), String(localized: "No ads in the app"), false),
        ("safari", Color(hex: "3B82F6"), String(localized: "Browser with protection against phishing"), false),
        ("", Color(hex: "7C6BF2"), String(localized: "Complex passwords to protect accounts"), true)
    ]

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                ViewThatFits(in: .vertical) {
                    middle(density: .regular)
                    middle(density: .compact)
                    middle(density: .tight)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                footer
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

    private func middle(density: Density) -> some View {
        VStack(alignment: .leading, spacing: density.sectionSpacing) {
                Text(String(localized: "Ads block and wifi security tool is ready to protect your device"))
                    .font(.system(size: density.titleSize, weight: .bold))
                    .foregroundStyle(Color(hex: "1A1D21"))
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)

                hero(size: density.hero)
                    .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: density.featureSpacing) {
                    ForEach(Array(features.enumerated()), id: \.offset) { _, item in
                        featureRow(item, fontSize: density.featureFont)
                    }
                }

                VStack(spacing: density.cardSpacing) {
                    planCard(
                        title: vm.yearlyCardTitle,
                        price: vm.yearlyCardPrice,
                        plan: .yearly,
                        savePercent: vm.yearlySavePercent,
                        density: density
                    )
                    planCard(
                        title: vm.weeklyCardTitle,
                        price: vm.weeklyCardPrice,
                        plan: .weekly,
                        savePercent: nil,
                        density: density
                    )
                }
        }
        .padding(.horizontal, 22)
    }

    private var footer: some View {
        VStack(spacing: 14) {
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

            HStack(spacing: 22) {
                Link(String(localized: "Terms of Use"), destination: URL(string: PaywallConstants.termsURL)!)
                Link(String(localized: "Privacy Policy"), destination: URL(string: PaywallConstants.privacyURL)!)
            }
            .font(.system(size: 13))
            .foregroundStyle(Color(hex: "9CA3AF"))
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 12)
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

    private func hero(size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(Color(hex: "E7F8F1"))
                .frame(width: size, height: size)
                .scaleEffect(pulse ? 1.06 : 1.0)
            Circle()
                .fill(Color(hex: "D7F3E6"))
                .frame(width: size * 0.77, height: size * 0.77)
                .scaleEffect(pulse ? 1.04 : 1.0)
            Circle()
                .fill(AppTheme.accent)
                .frame(width: size * 0.55, height: size * 0.55)
            Image(systemName: "shield")
                .font(.system(size: size * 0.28, weight: .medium))
                .foregroundStyle(.white)
        }
        .frame(height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private func featureRow(_ item: (icon: String, color: Color, title: String, isAsterisk: Bool), fontSize: CGFloat) -> some View {
        HStack(spacing: 12) {
            Group {
                if item.isAsterisk {
                    Text("***")
                        .font(.system(size: fontSize, weight: .bold))
                } else {
                    Image(systemName: item.icon)
                        .font(.system(size: fontSize, weight: .semibold))
                }
            }
            .foregroundStyle(item.color)
            .frame(width: 24, alignment: .center)

            Text(item.title)
                .font(.system(size: fontSize))
                .foregroundStyle(Color(hex: "1A1D21"))
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
    }

    private func planCard(
        title: String,
        price: String?,
        plan: PaywallSubscriptionPlan,
        savePercent: Int?,
        density: Density
    ) -> some View {
        let isSelected = vm.selectedPlan == plan

        return Button {
            vm.select(plan)
        } label: {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title.isEmpty ? " " : title)
                        .font(.system(size: density.cardTitle, weight: .semibold))
                        .foregroundStyle(Color(hex: "1A1D21"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    if vm.isLoadingProducts {
                        ProgressView()
                            .controlSize(.small)
                    } else if let price {
                        Text(price)
                            .font(.system(size: density.cardPrice))
                            .foregroundStyle(Color(hex: "6B7280"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
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
            .padding(.vertical, density.cardVertical)
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

private enum Density {
    case regular, compact, tight

    var titleSize: CGFloat {
        switch self {
        case .regular: 26
        case .compact: 22
        case .tight: 18
        }
    }

    var hero: CGFloat {
        switch self {
        case .regular: 128
        case .compact: 100
        case .tight: 72
        }
    }

    var sectionSpacing: CGFloat {
        switch self {
        case .regular: 14
        case .compact: 10
        case .tight: 6
        }
    }

    var featureSpacing: CGFloat {
        switch self {
        case .regular: 12
        case .compact: 8
        case .tight: 4
        }
    }

    var featureFont: CGFloat {
        switch self {
        case .regular: 16
        case .compact: 15
        case .tight: 13
        }
    }

    var cardSpacing: CGFloat {
        switch self {
        case .regular: 10
        case .compact: 8
        case .tight: 6
        }
    }

    var cardVertical: CGFloat {
        switch self {
        case .regular: 12
        case .compact: 10
        case .tight: 8
        }
    }

    var cardTitle: CGFloat {
        switch self {
        case .regular: 17
        case .compact: 16
        case .tight: 15
        }
    }

    var cardPrice: CGFloat {
        switch self {
        case .regular: 14
        case .compact: 13
        case .tight: 12
        }
    }
}

#Preview {
    PremiumPaywallView()
}
