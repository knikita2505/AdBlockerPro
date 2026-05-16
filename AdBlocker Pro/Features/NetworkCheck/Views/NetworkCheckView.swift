import SwiftUI

struct NetworkCheckView: View {

    @State private var service = NetworkPrivacyService()
    @State private var ringRotation: Double = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingL) {
                    headerSection

                    heroSection

                    if !service.isScanning {
                        scanButton
                    }

                    if service.isScanning {
                        scanProgressCard
                    }

                    if service.scanComplete {
                        summaryCard
                        resultsSection
                    }

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.vertical, AppTheme.spacingM)
            }
            .background(GradientBackground())
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: AppTheme.spacingXS) {
            Text(String(localized: "Network Privacy"))
                .font(AppTheme.titleFont)
                .foregroundStyle(AppTheme.primaryText)

            Text(String(localized: "Analyze your connection security"))
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppTheme.spacingS)
    }

    // MARK: - Hero

    @ViewBuilder
    private var heroSection: some View {
        ZStack {
            Circle()
                .stroke(
                    AppTheme.accent.opacity(0.06),
                    lineWidth: 2
                )
                .frame(width: 200, height: 200)

            Circle()
                .stroke(
                    AppTheme.accent.opacity(0.10),
                    lineWidth: 3
                )
                .frame(width: 160, height: 160)

            Circle()
                .stroke(
                    AppTheme.accent.opacity(0.15),
                    lineWidth: 4
                )
                .frame(width: 120, height: 120)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 88, height: 88)
                .shadow(color: AppTheme.accent.opacity(0.3), radius: 16, y: 6)

            Image(systemName: heroIcon)
                .font(.system(size: 36, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.symbolEffect(.replace))

            if service.isScanning {
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(
                        AppTheme.accentLight.opacity(0.5),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(ringRotation))
                    .onAppear {
                        withAnimation(
                            .linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                        ) {
                            ringRotation = 360
                        }
                    }
                    .onDisappear {
                        ringRotation = 0
                    }
            }
        }
        .padding(.vertical, AppTheme.spacingS)

        VStack(spacing: 6) {
            Text(statusTitle)
                .font(AppTheme.titleMedium)
                .foregroundStyle(AppTheme.primaryText)

            Text(statusSubtitle)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.spacingM)
        }
    }

    // MARK: - Scan Button

    private var scanButton: some View {
        Button {
            HapticManager.impact(.medium)
            service.startScan()
        } label: {
            Text(service.scanComplete
                 ? String(localized: "Scan Again")
                 : String(localized: "Start Scan"))
                .font(AppTheme.bodyMedium)
                .foregroundStyle(.white)
                .padding(.horizontal, AppTheme.spacingXL)
                .padding(.vertical, AppTheme.spacingM - 2)
                .background(
                    LinearGradient(
                        colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: AppTheme.accent.opacity(0.25), radius: 8, y: 4)
        }
        .pressable()
    }

    // MARK: - Scan Progress

    private var scanProgressCard: some View {
        VStack(spacing: AppTheme.spacingM - 4) {
            HStack {
                HStack(spacing: AppTheme.spacingS) {
                    ProgressView()
                        .tint(AppTheme.accent)
                        .scaleEffect(0.8)

                    Text(String(localized: "Analyzing network..."))
                        .font(AppTheme.bodyMedium)
                        .foregroundStyle(AppTheme.primaryText)
                }

                Spacer()

                Text("\(Int(service.scanProgress * 100))%")
                    .font(AppTheme.captionMedium)
                    .foregroundStyle(AppTheme.accent)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: AppTheme.radiusFull)
                        .fill(AppTheme.surfaceSecondary)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: AppTheme.radiusFull)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geo.size.width * service.scanProgress,
                            height: 6
                        )
                        .animation(.easeInOut(duration: 0.3), value: service.scanProgress)
                }
            }
            .frame(height: 6)
        }
        .cardStyle()
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    // MARK: - Summary

    private var summaryCard: some View {
        HStack(spacing: 0) {
            summaryColumn(
                count: service.checks.filter { $0.status == .good }.count,
                label: String(localized: "Passed"),
                color: AppTheme.success
            )
            summaryColumn(
                count: service.checks.filter { $0.status == .warning }.count,
                label: String(localized: "Warnings"),
                color: AppTheme.warning
            )
            summaryColumn(
                count: service.checks.filter { $0.status == .info }.count,
                label: String(localized: "Info"),
                color: .blue
            )
        }
        .cardStyle()
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private func summaryColumn(count: Int, label: String, color: Color) -> some View {
        VStack(spacing: AppTheme.spacingXS) {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)

                Text("\(count)")
                    .font(AppTheme.titleMedium)
                    .foregroundStyle(AppTheme.primaryText)
            }

            Text(label)
                .font(AppTheme.captionMedium)
                .foregroundStyle(AppTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Results

    private var resultsSection: some View {
        VStack(spacing: AppTheme.spacingS) {
            ForEach(service.checks) { check in
                checkRow(check)
            }
        }
        .transition(.opacity)
    }

    private func checkRow(_ check: PrivacyCheck) -> some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous)
                    .fill(check.status.color.opacity(0.10))
                    .frame(width: 44, height: 44)

                Image(systemName: check.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(check.status.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(check.title)
                    .font(AppTheme.bodyMedium)
                    .foregroundStyle(AppTheme.primaryText)

                Text(check.subtitle)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: check.status.iconName)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(check.status.color)
        }
        .cardStyle()
    }

    // MARK: - Computed

    private var heroIcon: String {
        if service.isScanning { return "wifi" }
        if !service.scanComplete { return "wifi" }
        let warnings = service.checks.filter { $0.status == .warning }.count
        return warnings > 1 ? "wifi.exclamationmark" : "checkmark.shield.fill"
    }

    private var statusTitle: String {
        if service.isScanning { return String(localized: "Scanning Network") }
        if !service.scanComplete { return String(localized: "Network Privacy") }
        let warnings = service.checks.filter { $0.status == .warning }.count
        if warnings > 1 { return String(localized: "Improvements Suggested") }
        if warnings == 1 { return String(localized: "Mostly Secure") }
        return String(localized: "Network is Secure")
    }

    private var statusSubtitle: String {
        if service.isScanning { return String(localized: "Checking connection, VPN, DNS, HTTPS...") }
        if !service.scanComplete { return String(localized: "Analyze your network privacy and security") }
        let warnings = service.checks.filter { $0.status == .warning }.count
        if warnings > 0 {
            return String(localized: "\(warnings) potential issue(s) found")
        }
        return String(localized: "All checks passed successfully")
    }
}

#Preview {
    NetworkCheckView()
}
