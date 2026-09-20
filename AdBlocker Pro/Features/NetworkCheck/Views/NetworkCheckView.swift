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

                    if service.isScanning {
                        scanProgressBar
                    }

                    if service.scanComplete {
                        summaryCard
                        resultsSection
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.top, AppTheme.spacingS)
            }
            .background(GradientBackground())
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "Network Privacy"))
                    .font(AppTheme.titleFont)
                    .foregroundStyle(AppTheme.primaryText)

                Text(String(localized: "Analyze your connection security"))
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer()
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: AppTheme.spacingM) {
            Button {
                guard !service.isScanning else { return }
                HapticManager.impact(.medium)
                ringRotation = 0
                withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                    service.startScan()
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(
                            heroIsHighlighted
                            ? AppTheme.accent.opacity(0.16)
                            : Color.black.opacity(0.04),
                            lineWidth: 10
                        )
                        .frame(width: 156, height: 156)

                    Circle()
                        .fill(
                            heroIsHighlighted
                            ? LinearGradient(
                                colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color(hex: "E8ECF0"), Color(hex: "D5DBE2")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(
                            color: heroIsHighlighted
                            ? AppTheme.accent.opacity(0.32)
                            : Color.black.opacity(0.08),
                            radius: heroIsHighlighted ? 22 : 10,
                            y: 8
                        )

                    Image(systemName: heroIcon)
                        .font(.system(size: 46, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.symbolEffect(.replace))

                    if service.isScanning {
                        Circle()
                            .trim(from: 0, to: 0.28)
                            .stroke(
                                Color.white.opacity(0.9),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .frame(width: 148, height: 148)
                            .rotationEffect(.degrees(ringRotation))
                            .onAppear {
                                withAnimation(
                                    .linear(duration: 1.2)
                                    .repeatForever(autoreverses: false)
                                ) {
                                    ringRotation = 360
                                }
                            }
                    }
                }
            }
            .buttonStyle(PressedStyle())
            .accessibilityLabel(String(localized: "Start Scan"))
            .disabled(service.isScanning)

            VStack(spacing: 4) {
                Text(statusTitle)
                    .font(AppTheme.titleSmall)
                    .foregroundStyle(AppTheme.primaryText)

                Text(statusSubtitle)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(heroIsHighlighted ? AppTheme.accent : AppTheme.tertiaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.spacingS)
    }

    private var heroIsHighlighted: Bool {
        service.isScanning || service.scanComplete
    }

    // MARK: - Progress

    private var scanProgressBar: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.surfaceSecondary)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geo.size.width * service.scanProgress))
                        .animation(.easeInOut(duration: 0.3), value: service.scanProgress)
                }
            }
            .frame(height: 6)

            Text("\(Int(service.scanProgress * 100))%")
                .font(AppTheme.captionMedium)
                .foregroundStyle(AppTheme.accent)
        }
        .padding(.horizontal, AppTheme.spacingXL)
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
                color: Color(hex: "3B82F6")
            )
        }
        .cardStyle()
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
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            Text(String(localized: "Checks"))
                .font(AppTheme.captionMedium)
                .foregroundStyle(AppTheme.secondaryText)
                .textCase(.uppercase)
                .tracking(0.6)
                .padding(.leading, AppTheme.spacingS)

            VStack(spacing: 0) {
                ForEach(Array(service.checks.enumerated()), id: \.element.id) { index, check in
                    NetworkCheckRow(check: check)

                    if index < service.checks.count - 1 {
                        Divider()
                            .padding(.leading, 62)
                    }
                }
            }
            .cardStyle(padding: 0)
        }
    }

    // MARK: - Computed

    private var heroIcon: String {
        if service.isScanning { return "wifi" }
        if !service.scanComplete { return "wifi" }
        let warnings = service.checks.filter { $0.status == .warning }.count
        return warnings > 0 ? "wifi.exclamationmark" : "checkmark.shield.fill"
    }

    private var statusTitle: String {
        if service.isScanning { return String(localized: "Scanning Network") }
        if !service.scanComplete { return String(localized: "Ready to Scan") }
        let warnings = service.checks.filter { $0.status == .warning }.count
        if warnings > 1 { return String(localized: "Improvements Suggested") }
        if warnings == 1 { return String(localized: "Mostly Secure") }
        return String(localized: "Network is Secure")
    }

    private var statusSubtitle: String {
        if service.isScanning { return String(localized: "Checking Wi-Fi, VPN, DNS and internet…") }
        if !service.scanComplete { return String(localized: "Tap the button to check this network") }
        let warnings = service.checks.filter { $0.status == .warning }.count
        if warnings > 0 {
            return String(localized: "\(warnings) potential issue(s) found")
        }
        return String(localized: "All checks passed successfully")
    }
}

// MARK: - Row

private struct NetworkCheckRow: View {
    let check: PrivacyCheck
    @State private var showTooltip = false

    var body: some View {
        HStack(alignment: .center, spacing: AppTheme.spacingM) {
            Image(systemName: check.icon)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(check.status.color)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(check.title)
                    .font(AppTheme.bodyMedium)
                    .foregroundStyle(AppTheme.primaryText)

                Text(check.subtitle)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.secondaryText)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                showTooltip = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.tertiaryText)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Image(systemName: check.status.iconName)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(check.status.color)
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.vertical, 12)
        .sheet(isPresented: $showTooltip) {
            InfoTipSheet(
                icon: check.icon,
                iconColor: check.status.color,
                title: check.title,
                message: check.tooltip
            )
        }
    }
}

#Preview {
    NetworkCheckView()
}
