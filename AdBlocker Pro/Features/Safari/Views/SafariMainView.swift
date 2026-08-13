import SwiftUI

struct SafariMainView: View {

    @State private var viewModel = SafariViewModel()
    var contentBlocker = ContentBlockerManager.shared
    var subscriptionManager = SubscriptionManager.shared

    @State private var showSettings = false
    @State private var showGuides = false
    @State private var showExtensionAlert = false

    private var activeFilterCount: Int {
        FilterCategory.allCases.filter { viewModel.isFilterEnabled($0) }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingL) {
                    headerSection

                    if !contentBlocker.isExtensionEnabled {
                        extensionBanner
                    }

                    heroSection

                    filtersSection

                    websiteListsSection

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.top, AppTheme.spacingS)
            }
            .background(GradientBackground())
            .navigationBarHidden(true)
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .presentationBackground(AppTheme.background)
            }
            .sheet(isPresented: $showGuides) {
                PrivacyGuidesView()
                    .presentationBackground(AppTheme.background)
            }
            .onAppear {
                Task { await contentBlocker.checkExtensionStatus() }
            }
            .alert(String(localized: "Extension Not Enabled"), isPresented: $showExtensionAlert) {
                Button(String(localized: "Open Settings")) {
                    #if os(iOS)
                    if let url = URL(string: "App-prefs:SAFARI&path=WEB_EXTENSIONS") {
                        UIApplication.shared.open(url)
                    }
                    #endif
                }
                Button(String(localized: "Cancel"), role: .cancel) {}
            } message: {
                Text(String(localized: "Enable the AdBlocker Pro extension in Settings → Apps → Safari → Extensions to start blocking ads."))
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                Text(String(localized: "Protection"))
                    .font(AppTheme.titleFont)
                    .foregroundStyle(AppTheme.primaryText)

                Text(String(localized: "Safari content blocking"))
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer()

            HStack(spacing: AppTheme.spacingS) {
                Button {
                    HapticManager.impact(.light)
                    showGuides = true
                } label: {
                    Image(systemName: "book.fill")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.secondaryText)
                        .frame(width: 42, height: 42)
                        .background(AppTheme.surface)
                        .clipShape(Circle())
                        .shadow(color: AppTheme.shadowSoft, radius: 8, x: 0, y: 2)
                        .shadow(color: AppTheme.shadowMedium, radius: 1, x: 0, y: 1)
                }
                .pressable()

                Button {
                    HapticManager.impact(.light)
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.secondaryText)
                        .frame(width: 42, height: 42)
                        .background(AppTheme.surface)
                        .clipShape(Circle())
                        .shadow(color: AppTheme.shadowSoft, radius: 8, x: 0, y: 2)
                        .shadow(color: AppTheme.shadowMedium, radius: 1, x: 0, y: 1)
                }
                .pressable()
            }
        }
        .padding(.top, AppTheme.spacingS)
    }

    // MARK: - Extension Banner

    private var extensionBanner: some View {
        Button {
            HapticManager.impact(.light)
            #if os(iOS)
            if let url = URL(string: "App-prefs:SAFARI&path=WEB_EXTENSIONS") {
                UIApplication.shared.open(url)
            }
            #endif
        } label: {
            HStack(spacing: AppTheme.spacingM) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous)
                        .fill(AppTheme.warning.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.warning)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "Extension Disabled"))
                        .font(AppTheme.bodyMedium)
                        .foregroundStyle(AppTheme.primaryText)
                    Text(String(localized: "Settings → Apps → Safari → Extensions"))
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.secondaryText)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.tertiaryText)
            }
            .padding(AppTheme.spacingM)
            .background(AppTheme.warning.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous)
                    .stroke(AppTheme.warning.opacity(0.2), lineWidth: 1)
            )
        }
        .pressable()
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: AppTheme.spacingM) {
            Button {
                HapticManager.impact(.medium)
                if !contentBlocker.isExtensionEnabled {
                    showExtensionAlert = true
                } else {
                    contentBlocker.toggleProtection()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            contentBlocker.isProtectionActive
                            ? LinearGradient(
                                colors: [AppTheme.gradientStart.opacity(0.15), AppTheme.gradientEnd.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [AppTheme.surfaceSecondary, AppTheme.surfaceSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: contentBlocker.isProtectionActive
                          ? "checkmark.shield.fill" : "shield.slash")
                        .font(.system(size: 52, weight: .medium, design: .rounded))
                        .foregroundStyle(
                            contentBlocker.isProtectionActive
                            ? LinearGradient(
                                colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [AppTheme.tertiaryText, AppTheme.tertiaryText],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .contentTransition(.symbolEffect(.replace))
                }
            }
            .buttonStyle(.plain)

            VStack(spacing: AppTheme.spacingXS) {
                HStack(spacing: 6) {
                    Text(String(localized: "Ad Blocking is"))
                        .font(AppTheme.titleMedium)
                        .foregroundStyle(AppTheme.primaryText)
                    Text(contentBlocker.isProtectionActive
                         ? String(localized: "ON")
                         : String(localized: "OFF"))
                        .font(AppTheme.titleMedium)
                        .foregroundStyle(contentBlocker.isProtectionActive
                                         ? AppTheme.accent : AppTheme.destructive)
                }

                Text("\(activeFilterCount) " + String(localized: "filters active"))
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.tertiaryText)
            }

        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.spacingL)
        .cardStyle()
    }

    // MARK: - Filters Section

    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            Text(String(localized: "Filters"))
                .font(AppTheme.titleSmall)
                .foregroundStyle(AppTheme.primaryText)
                .padding(.leading, AppTheme.spacingXS)

            VStack(spacing: 0) {
                ForEach(Array(FilterCategory.allCases.enumerated()), id: \.element.id) { index, category in
                    FilterToggleCard(
                        category: category,
                        isOn: viewModel.isFilterEnabled(category),
                        isLocked: !subscriptionManager.isPremium
                    ) { newValue in
                        if newValue && !contentBlocker.isExtensionEnabled {
                            showExtensionAlert = true
                            return
                        }
                        HapticManager.impact(.light)
                        viewModel.toggleFilter(category, isOn: newValue)
                    }

                    if index < FilterCategory.allCases.count - 1 {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
            .cardStyle(padding: 0)
        }
    }

    // MARK: - Website Lists

    private var websiteListsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            Text(String(localized: "Website Lists"))
                .font(AppTheme.titleSmall)
                .foregroundStyle(AppTheme.primaryText)
                .padding(.leading, AppTheme.spacingXS)

            VStack(spacing: 0) {
                NavigationLink {
                    AllowedWebsitesView()
                } label: {
                    WebsiteListRow(
                        icon: "checkmark.square.fill",
                        iconColor: AppTheme.accent,
                        title: String(localized: "Approved List"),
                        subtitle: String(localized: "Not block this websites"),
                        count: contentBlocker.allowedWebsites.count
                    )
                }

                Divider()
                    .padding(.leading, 60)

                NavigationLink {
                    BlockedWebsitesView()
                } label: {
                    WebsiteListRow(
                        icon: "xmark.square.fill",
                        iconColor: AppTheme.destructive,
                        title: String(localized: "Block List"),
                        subtitle: String(localized: "Block access to this websites"),
                        count: contentBlocker.blockedWebsites.count
                    )
                }
            }
            .cardStyle(padding: 0)
        }
    }
}

// MARK: - Filter Toggle Card

private struct FilterToggleCard: View {
    let category: FilterCategory
    let isOn: Bool
    let isLocked: Bool
    let onToggle: (Bool) -> Void

    @State private var showTooltip = false

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            Button {
                showTooltip = true
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous)
                        .fill(category.iconColor.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: category.icon)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(category.iconColor)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(category.title)
                    .font(AppTheme.bodyMedium)
                    .foregroundStyle(AppTheme.primaryText)
                Text(category.subtitle)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineLimit(1)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { isOn },
                set: { onToggle($0) }
            ))
            .tint(AppTheme.accent)
            .labelsHidden()
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.vertical, AppTheme.spacingM - 2)
        .sheet(isPresented: $showTooltip) {
            FilterTooltipSheet(category: category)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(AppTheme.background)
        }
    }
}

// MARK: - Filter Tooltip Sheet

private struct FilterTooltipSheet: View {
    let category: FilterCategory
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: AppTheme.spacingL) {
            ZStack {
                Circle()
                    .fill(category.iconColor.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: category.icon)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundStyle(category.iconColor)
            }
            .padding(.top, AppTheme.spacingL)

            Text(category.title)
                .font(AppTheme.titleMedium)
                .foregroundStyle(AppTheme.primaryText)

            Text(category.tooltip)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, AppTheme.spacingL)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text(String(localized: "Got It"))
                    .font(AppTheme.bodyMedium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
            }
            .pressable()
            .padding(.horizontal, AppTheme.spacingL)
            .padding(.bottom, AppTheme.spacingL)
        }
    }
}

// MARK: - Website List Row

private struct WebsiteListRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let count: Int

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.bodyMedium)
                    .foregroundStyle(AppTheme.primaryText)
                Text(subtitle)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer()

            if count > 0 {
                Text("\(count)")
                    .font(AppTheme.captionMedium)
                    .foregroundStyle(AppTheme.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.accentSoft)
                    .clipShape(Capsule())
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.tertiaryText)
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.vertical, AppTheme.spacingM - 2)
    }
}

#Preview {
    SafariMainView()
}
