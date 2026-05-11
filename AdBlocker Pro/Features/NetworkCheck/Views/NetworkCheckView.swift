import SwiftUI

struct NetworkCheckView: View {

    @State private var service = NetworkPrivacyService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingL) {
                    heroSection

                    if service.isScanning {
                        scanningCard
                    }

                    if service.scanComplete {
                        resultsSection
                    }
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.vertical, AppTheme.spacingM)
            }
            .background(AppTheme.groupedBackground)
            .navigationTitle(String(localized: "Wi-Fi Security"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: AppTheme.spacingM) {
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.10))
                    .frame(width: 140, height: 140)

                Circle()
                    .fill(AppTheme.accent.opacity(0.20))
                    .frame(width: 110, height: 110)

                ZStack {
                    Circle()
                        .fill(AppTheme.accent)
                        .frame(width: 80, height: 80)
                    Image(systemName: service.isScanning ? "wifi" : statusIcon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            .padding(.top, AppTheme.spacingM)

            VStack(spacing: 6) {
                Text(statusTitle)
                    .font(.system(size: 20, weight: .semibold))

                Text(statusSubtitle)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }

            if !service.isScanning {
                Button {
                    service.startScan()
                } label: {
                    Text(service.scanComplete
                         ? String(localized: "Scan Again")
                         : String(localized: "Scanning network"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(AppTheme.accent)
                        .clipShape(Capsule())
                }
            } else {
                Text(String(localized: "Scanning network"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(AppTheme.accent)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, AppTheme.spacingS)
    }

    // MARK: - Scanning Card

    private var scanningCard: some View {
        HStack(spacing: AppTheme.spacingM) {
            Text(String(localized: "Wi-Fi Information"))
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.primaryText)

            Spacer()

            ProgressView()
                .tint(AppTheme.accent)
        }
        .padding(AppTheme.spacingM)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
    }

    // MARK: - Results

    private var resultsSection: some View {
        VStack(spacing: AppTheme.spacingS) {
            ForEach(service.checks) { check in
                HStack(spacing: AppTheme.spacingM) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(check.status.color.opacity(0.10))
                            .frame(width: 42, height: 42)
                        Image(systemName: check.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(check.status.color)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(check.title)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(AppTheme.primaryText)
                        Text(check.subtitle)
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.secondaryText)
                            .lineLimit(2)
                    }

                    Spacer()

                    Image(systemName: check.status.iconName)
                        .font(.system(size: 18))
                        .foregroundStyle(check.status.color)
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.vertical, 12)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
            }
        }
    }

    // MARK: - Computed

    private var statusIcon: String {
        if !service.scanComplete { return "wifi" }
        let warnings = service.checks.filter { $0.status == .warning }.count
        return warnings > 1 ? "wifi.exclamationmark" : "checkmark.shield.fill"
    }

    private var statusTitle: String {
        if service.isScanning { return String(localized: "Checking Wi-Fi Network") }
        if !service.scanComplete { return String(localized: "Wi-Fi Security") }
        let warnings = service.checks.filter { $0.status == .warning }.count
        if warnings > 1 { return String(localized: "Improvements Suggested") }
        return String(localized: "Network is Secure")
    }

    private var statusSubtitle: String {
        if service.isScanning { return String(localized: "Name network Unknown") }
        if !service.scanComplete { return String(localized: "Check your Wi-Fi connection security") }
        return String(localized: "Your network privacy check is complete")
    }
}

#Preview {
    NetworkCheckView()
}
