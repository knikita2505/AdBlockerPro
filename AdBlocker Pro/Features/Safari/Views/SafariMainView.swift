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

                    Spacer(minLength: 40)
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
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "Protection"))
                    .font(AppTheme.titleFont)
                    .foregroundStyle(AppTheme.primaryText)

                Text(String(localized: "Safari content blocking"))
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer()

            HStack(spacing: AppTheme.spacingS) {
                headerButton(icon: "book") {
                    showGuides = true
                }
                headerButton(icon: "gearshape") {
                    showSettings = true
                }
            }
        }
    }

    private func headerButton(icon: String, action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.impact(.light)
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.secondaryText)
                .frame(width: 40, height: 40)
                .background(AppTheme.surface)
                .clipShape(Circle())
                .shadow(color: AppTheme.shadowSoft, radius: 8, y: 2)
        }
        .buttonStyle(.plain)
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
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(AppTheme.warning)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

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
            .padding(.horizontal, AppTheme.spacingM)
            .padding(.vertical, 14)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
            .shadow(color: AppTheme.shadowSoft, radius: 10, y: 3)
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
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        contentBlocker.toggleProtection()
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(
                            contentBlocker.isProtectionActive
                            ? AppTheme.accent.opacity(0.16)
                            : Color.black.opacity(0.04),
                            lineWidth: 10
                        )
                        .frame(width: 156, height: 156)

                    Circle()
                        .fill(
                            contentBlocker.isProtectionActive
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
                            color: contentBlocker.isProtectionActive
                            ? AppTheme.accent.opacity(0.32)
                            : Color.black.opacity(0.08),
                            radius: contentBlocker.isProtectionActive ? 22 : 10,
                            y: 8
                        )

                    Image(systemName: contentBlocker.isProtectionActive
                          ? "checkmark.shield.fill"
                          : "shield")
                        .font(.system(size: 46, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.symbolEffect(.replace))
                }
            }
            .buttonStyle(PressedStyle())
            .accessibilityLabel(String(localized: "Ad Blocking"))
            .accessibilityValue(contentBlocker.isProtectionActive
                                ? String(localized: "ON")
                                : String(localized: "OFF"))

            VStack(spacing: 4) {
                Text(contentBlocker.isProtectionActive
                     ? String(localized: "Protection On")
                     : String(localized: "Protection Off"))
                    .font(AppTheme.titleSmall)
                    .foregroundStyle(AppTheme.primaryText)

                Text(heroSubtitle)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(contentBlocker.isProtectionActive
                                     ? AppTheme.accent
                                     : AppTheme.tertiaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.spacingS)
    }

    private var heroSubtitle: String {
        if contentBlocker.isProtectionActive {
            return "\(activeFilterCount) " + String(localized: "filters active")
        }
        return String(localized: "Tap the shield to start blocking")
    }

    // MARK: - Filters Section

    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            Text(String(localized: "Filters"))
                .font(AppTheme.captionMedium)
                .foregroundStyle(AppTheme.secondaryText)
                .textCase(.uppercase)
                .tracking(0.6)
                .padding(.leading, AppTheme.spacingS)

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
                        viewModel.toggleFilter(category, isOn: newValue)
                    }

                    if index < FilterCategory.allCases.count - 1 {
                        Divider()
                            .padding(.leading, 62)
                    }
                }
            }
            .cardStyle(padding: 0)
        }
    }

    // MARK: - Website Lists

    private var websiteListsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            Text(String(localized: "Website Lists"))
                .font(AppTheme.captionMedium)
                .foregroundStyle(AppTheme.secondaryText)
                .textCase(.uppercase)
                .tracking(0.6)
                .padding(.leading, AppTheme.spacingS)

            VStack(spacing: 0) {
                NavigationLink {
                    AllowedWebsitesView()
                } label: {
                    WebsiteListRow(
                        icon: "checkmark",
                        iconColor: AppTheme.accent,
                        title: String(localized: "Approved List"),
                        subtitle: String(localized: "Not block this websites"),
                        count: contentBlocker.allowedWebsites.count
                    )
                }

                Divider()
                    .padding(.leading, 62)

                NavigationLink {
                    BlockedWebsitesView()
                } label: {
                    WebsiteListRow(
                        icon: "xmark",
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
                Image(systemName: category.icon)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(category.iconColor)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            }
            .buttonStyle(.plain)

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

            Toggle(category.title, isOn: Binding(
                get: { isOn },
                set: { onToggle($0) }
            ))
            .tint(AppTheme.accent)
            .labelsHidden()
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.vertical, 12)
        .sheet(isPresented: $showTooltip) {
            FilterTooltipSheet(category: category)
        }
    }
}

// MARK: - Filter Tooltip Sheet

private struct FilterTooltipSheet: View {
    let category: FilterCategory
    @Environment(\.dismiss) private var dismiss
    @State private var sheetHeight: CGFloat = 240

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(category.iconColor)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

                Text(category.title)
                    .font(AppTheme.titleSmall)
                    .foregroundStyle(AppTheme.primaryText)

                Spacer()
            }

            Text(category.tooltip)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                dismiss()
            } label: {
                Text(String(localized: "Got It"))
                    .font(AppTheme.bodyMedium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(AppTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusM, style: .continuous))
            }
            .pressable()
            .padding(.top, 4)
        }
        .padding(.horizontal, AppTheme.spacingL)
        .padding(.top, AppTheme.spacingM)
        .padding(.bottom, AppTheme.spacingL)
        .background {
            GeometryReader { geo in
                Color.clear.preference(key: FilterSheetHeightKey.self, value: geo.size.height)
            }
        }
        .onPreferenceChange(FilterSheetHeightKey.self) { newHeight in
            if newHeight > 0 {
                sheetHeight = newHeight
            }
        }
        .presentationDetents([.height(sheetHeight)])
        .presentationDragIndicator(.visible)
        .presentationBackground(AppTheme.surface)
        .presentationCornerRadius(24)
    }
}

private struct FilterSheetHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
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
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(iconColor)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

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
        .padding(.vertical, 12)
    }
}

#Preview {
    SafariMainView()
}
