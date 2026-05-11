import SwiftUI

struct SafariMainView: View {

    @State private var viewModel = SafariViewModel()
    var contentBlocker = ContentBlockerManager.shared
    var subscriptionManager = SubscriptionManager.shared

    @State private var showSettings = false
    @State private var showGuides = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    heroSection
                        .padding(.bottom, AppTheme.spacingL)

                    filtersSection
                        .padding(.bottom, AppTheme.spacingL)

                    websiteListsSection
                        .padding(.bottom, AppTheme.spacingL)

                    guidesSection
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.vertical, AppTheme.spacingM)
            }
            .background(AppTheme.groupedBackground)
            .navigationTitle(String(localized: "Protection"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(AppTheme.primaryText)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    premiumBadge
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showGuides) {
                PrivacyGuidesView()
            }
        }
    }

    // MARK: - Premium Badge

    private var premiumBadge: some View {
        Button {
            if !subscriptionManager.isPremium {
                subscriptionManager.showPaywall(for: .premiumFeature)
            }
        } label: {
            HStack(spacing: 4) {
                Text("Pro")
                    .font(.system(size: 13, weight: .bold))
                Image(systemName: "shield.checkered")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(AppTheme.accent)
            .clipShape(Capsule())
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: AppTheme.spacingM) {
            ZStack {
                Circle()
                    .fill(
                        activeFilterCount > 0
                        ? AppTheme.accent.opacity(0.12)
                        : Color(red: 0.92, green: 0.92, blue: 0.94)
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: activeFilterCount > 0 ? "checkmark.shield.fill" : "shield.slash")
                    .font(.system(size: 52, weight: .medium))
                    .foregroundStyle(
                        activeFilterCount > 0 ? AppTheme.accent : AppTheme.tertiaryText
                    )
            }

            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Text(String(localized: "Ad Blocking is"))
                        .font(.system(size: 20, weight: .semibold))
                    Text(activeFilterCount > 0
                         ? String(localized: "ON")
                         : String(localized: "OFF"))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(activeFilterCount > 0 ? AppTheme.accent : .red)
                }
            }

            if contentBlocker.isReloading {
                ProgressView()
                    .tint(AppTheme.accent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.spacingL)
    }

    // MARK: - Filters

    private var filtersSection: some View {
        VStack(spacing: AppTheme.spacingS) {
            ForEach(FilterCategory.allCases) { category in
                FilterToggleCard(
                    category: category,
                    isOn: viewModel.isFilterEnabled(category),
                    isLocked: !subscriptionManager.isPremium
                ) { newValue in
                    viewModel.toggleFilter(category, isOn: newValue)
                }
            }
        }
    }

    // MARK: - Website Lists

    private var websiteListsSection: some View {
        VStack(spacing: AppTheme.spacingS) {
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

            NavigationLink {
                BlockedWebsitesView()
            } label: {
                WebsiteListRow(
                    icon: "xmark.square.fill",
                    iconColor: .red,
                    title: String(localized: "Block List"),
                    subtitle: String(localized: "Block access to this websites"),
                    count: contentBlocker.blockedWebsites.count
                )
            }
        }
    }

    // MARK: - Guides

    private var guidesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(String(localized: "Guides"))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppTheme.secondaryText)
                .textCase(.uppercase)
                .padding(.leading, 4)
                .padding(.bottom, AppTheme.spacingS)

            VStack(spacing: 0) {
                guideRow(icon: "lock.fill", title: String(localized: "Two-factor authentication"), isLast: false)
                guideRow(icon: "antenna.radiowaves.left.and.right.slash", title: String(localized: "Disable tracking"), isLast: false)
                guideRow(icon: "location.slash.fill", title: String(localized: "Review location services"), isLast: false)
                guideRow(icon: "bell.slash.fill", title: String(localized: "Disable notification"), isLast: true)
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
        }
    }

    private func guideRow(icon: String, title: String, isLast: Bool) -> some View {
        Button { showGuides = true } label: {
            VStack(spacing: 0) {
                HStack(spacing: AppTheme.spacingM) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(AppTheme.primaryText)
                        .frame(width: 24)
                    Text(title)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.primaryText)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.tertiaryText)
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.vertical, 14)

                if !isLast {
                    Divider()
                        .padding(.leading, 56)
                }
            }
        }
    }

    private var activeFilterCount: Int {
        contentBlocker.enabledFilters.count
    }
}

// MARK: - Filter Toggle Card

private struct FilterToggleCard: View {
    let category: FilterCategory
    let isOn: Bool
    let isLocked: Bool
    let onToggle: (Bool) -> Void

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(category.iconColor.opacity(0.12))
                    .frame(width: 42, height: 42)
                Image(systemName: category.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(category.iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(category.title)
                    .font(.system(size: 15, weight: .medium))
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
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
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
                .font(.system(size: 22))
                .foregroundStyle(iconColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.primaryText)
                Text(subtitle)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer()

            Text("\(count)")
                .font(.system(size: 15))
                .foregroundStyle(AppTheme.secondaryText)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.tertiaryText)
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.vertical, 14)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
    }
}

#Preview {
    SafariMainView()
}
