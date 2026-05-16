import SwiftUI
import LocalAuthentication

struct SettingsView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    var subscriptionManager = SubscriptionManager.shared
    @Bindable var passcodeService = PasscodeService.shared

    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.spacingM) {
                        subscriptionCard
                        safariCard
                        securityCard
                        dataCard
                        linksCard
                        aboutCard

                        Spacer(minLength: AppTheme.spacingL)
                    }
                    .padding(.horizontal, AppTheme.spacingM)
                    .padding(.top, AppTheme.spacingM)
                }
            }
            .navigationTitle(String(localized: "Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Done")) { dismiss() }
                        .font(AppTheme.bodyMedium)
                        .foregroundColor(AppTheme.accent)
                }
            }
        }
    }

    // MARK: - Subscription

    private var subscriptionCard: some View {
        Button {
            if !subscriptionManager.isPremium {
                HapticManager.impact(.light)
                subscriptionManager.showPaywall(for: .premiumFeature)
            }
        } label: {
            HStack(spacing: AppTheme.spacingM) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.radiusS, style: .continuous)
                        .fill(subscriptionManager.isPremium
                              ? AppTheme.accent.opacity(0.15)
                              : Color.orange.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: subscriptionManager.isPremium ? "crown.fill" : "crown")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(subscriptionManager.isPremium ? AppTheme.accent : .orange)
                }

                VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                    Text(subscriptionManager.isPremium
                         ? String(localized: "Premium Active")
                         : String(localized: "Free Plan"))
                        .font(AppTheme.bodyMedium)
                        .foregroundStyle(AppTheme.primaryText)
                    Text(subscriptionManager.isPremium
                         ? String(localized: "All features unlocked")
                         : String(localized: "Tap to upgrade"))
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer()

                if !subscriptionManager.isPremium {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.tertiaryText)
                }
            }
            .cardStyle()
        }
        .pressable()
    }

    // MARK: - Safari

    private var safariCard: some View {
        NavigationLink {
            SafariSetupGuideView()
        } label: {
            settingsRow(
                icon: "safari",
                title: String(localized: "Safari Extension Setup"),
                color: .blue
            )
        }
        .pressable()
    }

    // MARK: - Security

    private var securityCard: some View {
        VStack(spacing: 0) {
            if passcodeService.hasPasscode {
                HStack(spacing: AppTheme.spacingM) {
                    settingsIcon(name: "lock.fill", color: AppTheme.accent)
                    Text(String(localized: "Passcode"))
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.primaryText)
                    Spacer()
                    Text(String(localized: "Enabled"))
                        .font(AppTheme.captionMedium)
                        .foregroundStyle(AppTheme.accent)
                }
                .padding(AppTheme.spacingM)

                if passcodeService.canUseBiometrics {
                    Divider().padding(.leading, 56)

                    HStack(spacing: AppTheme.spacingM) {
                        settingsIcon(
                            name: passcodeService.biometricType == .faceID ? "faceid" : "touchid",
                            color: .purple
                        )
                        Text(passcodeService.biometricName)
                            .font(AppTheme.bodyFont)
                            .foregroundStyle(AppTheme.primaryText)
                        Spacer()
                        Toggle("", isOn: $passcodeService.isBiometricsEnabled)
                            .tint(AppTheme.accent)
                            .labelsHidden()
                    }
                    .padding(AppTheme.spacingM)
                }

                Divider().padding(.leading, 56)

                Button {
                    passcodeService.removePasscode()
                    HapticManager.notification(.success)
                } label: {
                    HStack(spacing: AppTheme.spacingM) {
                        settingsIcon(name: "lock.slash", color: AppTheme.destructive)
                        Text(String(localized: "Remove Passcode"))
                            .font(AppTheme.bodyFont)
                            .foregroundStyle(AppTheme.destructive)
                        Spacer()
                    }
                    .padding(AppTheme.spacingM)
                }
            } else {
                HStack(spacing: AppTheme.spacingM) {
                    settingsIcon(name: "lock.open.fill", color: AppTheme.tertiaryText)
                    Text(String(localized: "Passcode"))
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.primaryText)
                    Spacer()
                    Text(String(localized: "Not Set"))
                        .font(AppTheme.captionMedium)
                        .foregroundStyle(AppTheme.tertiaryText)
                }
                .padding(AppTheme.spacingM)
            }
        }
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        .shadow(color: AppTheme.shadowSoft, radius: 8, x: 0, y: 2)
        .shadow(color: AppTheme.shadowMedium, radius: 1, x: 0, y: 1)
    }

    // MARK: - Data

    private var dataCard: some View {
        Button {
            showResetConfirmation = true
        } label: {
            settingsRow(
                icon: "arrow.counterclockwise",
                title: String(localized: "Reset Protection Rules"),
                color: AppTheme.destructive
            )
        }
        .pressable()
        .confirmationDialog(
            String(localized: "Reset All Rules?"),
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Reset"), role: .destructive) {
                ContentBlockerManager.shared.resetAllRules()
                HapticManager.notification(.success)
            }
        } message: {
            Text(String(localized: "This will disable all filters and clear your website lists. This action cannot be undone."))
        }
    }

    // MARK: - Links

    private var linksCard: some View {
        VStack(spacing: 0) {
            Button {
                if let url = URL(string: "mailto:support@example.com") {
                    openURL(url)
                }
            } label: {
                HStack(spacing: AppTheme.spacingM) {
                    settingsIcon(name: "envelope.fill", color: AppTheme.accent)
                    Text(String(localized: "Contact Support"))
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.primaryText)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.tertiaryText)
                }
                .padding(AppTheme.spacingM)
            }

            Divider().padding(.leading, 56)

            linkRow(icon: "hand.raised.fill", title: String(localized: "Privacy Policy"), color: AppTheme.success, urlString: PaywallConstants.privacyURL)

            Divider().padding(.leading, 56)

            linkRow(icon: "doc.text.fill", title: String(localized: "Terms of Use"), color: AppTheme.warning, urlString: PaywallConstants.termsURL)
        }
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        .shadow(color: AppTheme.shadowSoft, radius: 8, x: 0, y: 2)
        .shadow(color: AppTheme.shadowMedium, radius: 1, x: 0, y: 1)
    }

    // MARK: - About

    private var aboutCard: some View {
        VStack(spacing: AppTheme.spacingXS) {
            Text("AdBlocker Pro")
                .font(AppTheme.captionMedium)
                .foregroundStyle(AppTheme.secondaryText)
            Text("Version \(appVersion)")
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.tertiaryText)
        }
        .padding(.top, AppTheme.spacingM)
    }

    // MARK: - Helpers

    private func settingsRow(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: AppTheme.spacingM) {
            settingsIcon(name: icon, color: color)
            Text(title)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.primaryText)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.tertiaryText)
        }
        .cardStyle()
    }

    private func settingsIcon(name: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.radiusS, style: .continuous)
                .fill(color.opacity(0.15))
                .frame(width: 32, height: 32)
            Image(systemName: name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
        }
    }

    private func linkRow(icon: String, title: String, color: Color, urlString: String) -> some View {
        Button {
            if let url = URL(string: urlString) {
                openURL(url)
            }
        } label: {
            HStack(spacing: AppTheme.spacingM) {
                settingsIcon(name: icon, color: color)
                Text(title)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.primaryText)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.tertiaryText)
            }
            .padding(AppTheme.spacingM)
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    SettingsView()
}
