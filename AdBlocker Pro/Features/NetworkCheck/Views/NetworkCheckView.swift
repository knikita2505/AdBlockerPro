import SwiftUI

struct NetworkCheckView: View {

    @State private var service = NetworkPrivacyService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingL) {
                    statusCard
                    if service.scanComplete {
                        resultsSection
                        recommendationsSection
                    }
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.top, AppTheme.spacingM)
            }
            .background(AppTheme.groupedBackground)
            .navigationTitle("Network")
        }
    }

    // MARK: - Status Card

    private var statusCard: some View {
        VStack(spacing: AppTheme.spacingM) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.12))
                    .frame(width: 100, height: 100)

                if service.isScanning {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(AppTheme.accent)
                } else {
                    Image(systemName: statusIcon)
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(statusColor)
                }
            }

            Text(statusTitle)
                .font(AppTheme.titleFont)

            Text(statusSubtitle)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)

            if service.isScanning {
                ProgressView(value: service.scanProgress)
                    .tint(AppTheme.accent)
                    .padding(.horizontal, AppTheme.spacingXL)
            }

            Button {
                service.startScan()
            } label: {
                Text(service.scanComplete
                     ? String(localized: "Scan Again")
                     : String(localized: "Start Privacy Check"))
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
            }
            .disabled(service.isScanning)
        }
        .padding(AppTheme.spacingL)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusL))
    }

    // MARK: - Results

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            Text("Results")
                .font(AppTheme.headlineFont)
                .padding(.horizontal, AppTheme.spacingXS)

            VStack(spacing: 1) {
                ForEach(service.checks) { check in
                    HStack(spacing: AppTheme.spacingM) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(check.status.color.opacity(0.12))
                                .frame(width: 40, height: 40)
                            Image(systemName: check.icon)
                                .font(.system(size: 18))
                                .foregroundStyle(check.status.color)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(check.title)
                                .font(AppTheme.bodyFont)
                            Text(check.subtitle)
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.secondaryText)
                        }

                        Spacer()

                        Image(systemName: check.status.iconName)
                            .foregroundStyle(check.status.color)
                    }
                    .padding(AppTheme.spacingM)
                }
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
        }
    }

    // MARK: - Recommendations

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            Text("Recommendations")
                .font(AppTheme.headlineFont)
                .padding(.horizontal, AppTheme.spacingXS)

            VStack(alignment: .leading, spacing: AppTheme.spacingM) {
                RecommendationRow(
                    icon: "lock.shield.fill",
                    title: String(localized: "Use a VPN"),
                    subtitle: String(localized: "Encrypt your internet traffic, especially on public Wi-Fi networks")
                )
                RecommendationRow(
                    icon: "safari",
                    title: String(localized: "Enable Content Blocking"),
                    subtitle: String(localized: "Block ads and trackers in Safari for better privacy")
                )
                RecommendationRow(
                    icon: "key.fill",
                    title: String(localized: "Use Strong Passwords"),
                    subtitle: String(localized: "Generate unique passwords for each website")
                )
            }
            .padding(AppTheme.spacingM)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
        }
    }

    // MARK: - Computed

    private var statusColor: Color {
        if service.isScanning { return AppTheme.accent }
        if !service.scanComplete { return .gray }
        let warnings = service.checks.filter { $0.status == .warning }.count
        return warnings > 1 ? .orange : .green
    }

    private var statusIcon: String {
        if !service.scanComplete { return "wifi.shield" }
        let warnings = service.checks.filter { $0.status == .warning }.count
        return warnings > 1 ? "exclamationmark.shield.fill" : "checkmark.shield.fill"
    }

    private var statusTitle: String {
        if service.isScanning { return String(localized: "Checking Network...") }
        if !service.scanComplete { return String(localized: "Network Privacy Check") }
        let warnings = service.checks.filter { $0.status == .warning }.count
        if warnings > 1 { return String(localized: "Improvements Suggested") }
        return String(localized: "Looking Good")
    }

    private var statusSubtitle: String {
        if service.isScanning { return String(localized: "Analyzing your network privacy settings") }
        if !service.scanComplete { return String(localized: "Check your current network connection for privacy risks") }
        return String(localized: "Your network privacy check is complete")
    }
}

// MARK: - Recommendation Row

private struct RecommendationRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.spacingM) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(AppTheme.accent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.bodyFont)
                Text(subtitle)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
    }
}

#Preview {
    NetworkCheckView()
}
