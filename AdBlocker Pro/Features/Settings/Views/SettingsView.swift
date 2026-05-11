import SwiftUI
import LocalAuthentication

struct SettingsView: View {

    @Environment(\.dismiss) private var dismiss
    var subscriptionManager = SubscriptionManager.shared
    @Bindable var passcodeService = PasscodeService.shared

    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                subscriptionSection
                safariSection
                passcodeSection
                dataSection
                supportSection
                legalSection
                aboutSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Subscription

    private var subscriptionSection: some View {
        Section {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(subscriptionManager.isPremium ? AppTheme.accent.opacity(0.12) : Color.orange.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: subscriptionManager.isPremium ? "crown.fill" : "crown")
                        .foregroundStyle(subscriptionManager.isPremium ? AppTheme.accent : .orange)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(subscriptionManager.isPremium
                         ? String(localized: "Premium Active")
                         : String(localized: "Free Plan"))
                        .font(AppTheme.headlineFont)
                    Text(subscriptionManager.isPremium
                         ? String(localized: "All features unlocked")
                         : String(localized: "Tap to upgrade"))
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Spacer()
                if !subscriptionManager.isPremium {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppTheme.tertiaryText)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if !subscriptionManager.isPremium {
                    subscriptionManager.showPaywall(for: .premiumFeature)
                }
            }
        }
    }

    // MARK: - Safari

    private var safariSection: some View {
        Section("Safari") {
            NavigationLink {
                SafariSetupGuideView()
            } label: {
                Label("Safari Extension Setup", systemImage: "safari")
            }
        }
    }

    // MARK: - Passcode

    private var passcodeSection: some View {
        Section("Password Manager Security") {
            if passcodeService.hasPasscode {
                HStack {
                    Label("Passcode", systemImage: "lock.fill")
                    Spacer()
                    Text("Enabled")
                        .foregroundStyle(AppTheme.accent)
                        .font(AppTheme.captionFont)
                }

                if passcodeService.canUseBiometrics {
                    Toggle(isOn: $passcodeService.isBiometricsEnabled) {
                        Label(passcodeService.biometricName, systemImage: passcodeService.biometricType == .faceID ? "faceid" : "touchid")
                    }
                    .tint(AppTheme.accent)
                }

                Button(role: .destructive) {
                    passcodeService.removePasscode()
                    HapticManager.notification(.success)
                } label: {
                    Label("Remove Passcode", systemImage: "lock.slash")
                        .foregroundStyle(AppTheme.destructive)
                }
            } else {
                HStack {
                    Label("Passcode", systemImage: "lock.open.fill")
                    Spacer()
                    Text("Not Set")
                        .foregroundStyle(AppTheme.secondaryText)
                        .font(AppTheme.captionFont)
                }
            }
        }
    }

    // MARK: - Data

    private var dataSection: some View {
        Section("Data") {
            Button {
                showResetConfirmation = true
            } label: {
                Label("Reset Protection Rules", systemImage: "arrow.counterclockwise")
                    .foregroundStyle(AppTheme.destructive)
            }
            .confirmationDialog("Reset All Rules?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                Button("Reset", role: .destructive) {
                    ContentBlockerManager.shared.resetAllRules()
                    HapticManager.notification(.success)
                }
            } message: {
                Text("This will disable all filters and clear your website lists. This action cannot be undone.")
            }
        }
    }

    // MARK: - Support

    private var supportSection: some View {
        Section("Support") {
            // TODO: Replace with real support email
            Link(destination: URL(string: "mailto:support@example.com")!) {
                Label("Contact Support", systemImage: "envelope")
                    .foregroundStyle(AppTheme.primaryText)
            }
        }
    }

    // MARK: - Legal

    private var legalSection: some View {
        Section("Legal") {
            Link(destination: URL(string: PaywallConstants.privacyURL)!) {
                HStack {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                        .foregroundStyle(AppTheme.primaryText)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(AppTheme.tertiaryText)
                }
            }
            Link(destination: URL(string: PaywallConstants.termsURL)!) {
                HStack {
                    Label("Terms of Use", systemImage: "doc.text")
                        .foregroundStyle(AppTheme.primaryText)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(AppTheme.tertiaryText)
                }
            }
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                    .foregroundStyle(AppTheme.secondaryText)
                Spacer()
                Text(appVersion)
                    .foregroundStyle(AppTheme.tertiaryText)
                    .font(AppTheme.captionFont)
            }
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
