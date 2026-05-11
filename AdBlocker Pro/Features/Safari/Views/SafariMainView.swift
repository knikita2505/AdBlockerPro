import SwiftUI

struct SafariMainView: View {

    @State private var viewModel = SafariViewModel()
    var contentBlocker = ContentBlockerManager.shared
    var subscriptionManager = SubscriptionManager.shared

    @State private var showSettings = false
    @State private var showGuides = false

    var body: some View {
        NavigationStack {
            List {
                protectionStatusSection
                filtersSection
                websiteListsSection
                safariSetupSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Protection")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showGuides = true } label: {
                        Image(systemName: "book.fill")
                    }
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

    // MARK: - Protection Status

    private var protectionStatusSection: some View {
        Section {
            HStack(spacing: AppTheme.spacingM) {
                ZStack {
                    Circle()
                        .fill(activeFilterCount > 0 ? AppTheme.accent.opacity(0.15) : Color.gray.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: activeFilterCount > 0 ? "checkmark.shield.fill" : "shield.slash")
                        .font(.title2)
                        .foregroundStyle(activeFilterCount > 0 ? AppTheme.accent : .gray)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(activeFilterCount > 0
                         ? String(localized: "Protection Active")
                         : String(localized: "Protection Inactive"))
                        .font(AppTheme.headlineFont)
                    Text(activeFilterCount > 0
                         ? String(localized: "\(activeFilterCount) filters enabled")
                         : String(localized: "Enable filters to protect your browsing"))
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.secondaryText)
                }

                Spacer()

                if contentBlocker.isReloading {
                    ProgressView()
                }
            }
            .padding(.vertical, AppTheme.spacingXS)
        }
    }

    // MARK: - Filters

    private var filtersSection: some View {
        Section {
            ForEach(FilterCategory.allCases) { category in
                FilterToggleRow(
                    category: category,
                    isOn: viewModel.isFilterEnabled(category),
                    isPremium: !subscriptionManager.isPremium
                ) { newValue in
                    viewModel.toggleFilter(category, isOn: newValue)
                }
            }
        } header: {
            Text("Safari Filters")
        } footer: {
            if !subscriptionManager.isPremium {
                Text("Subscribe to enable protection filters")
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
    }

    // MARK: - Website Lists

    private var websiteListsSection: some View {
        Section("Website Lists") {
            NavigationLink {
                AllowedWebsitesView()
            } label: {
                HStack {
                    Label("Allowed Websites", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.primaryText)
                    Spacer()
                    Text("\(contentBlocker.allowedWebsites.count)")
                        .foregroundStyle(AppTheme.secondaryText)
                        .font(AppTheme.captionFont)
                }
            }

            NavigationLink {
                BlockedWebsitesView()
            } label: {
                HStack {
                    Label("Blocked Websites", systemImage: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.primaryText)
                    Spacer()
                    Text("\(contentBlocker.blockedWebsites.count)")
                        .foregroundStyle(AppTheme.secondaryText)
                        .font(AppTheme.captionFont)
                }
            }
        }
    }

    // MARK: - Safari Setup

    private var safariSetupSection: some View {
        Section {
            NavigationLink {
                SafariSetupGuideView()
            } label: {
                Label("Safari Extension Setup", systemImage: "safari")
            }
        } footer: {
            Text("Follow the guide to enable the content blocker in Safari")
                .foregroundStyle(AppTheme.secondaryText)
        }
    }

    private var activeFilterCount: Int {
        contentBlocker.enabledFilters.count
    }
}

// MARK: - Filter Toggle Row

struct FilterToggleRow: View {
    let category: FilterCategory
    let isOn: Bool
    let isPremium: Bool
    let onToggle: (Bool) -> Void

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(category.iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: category.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(category.iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(category.title)
                        .font(AppTheme.bodyFont)
                    if isPremium {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.secondaryText)
                    }
                }
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
        .padding(.vertical, 2)
    }
}

#Preview {
    SafariMainView()
}
