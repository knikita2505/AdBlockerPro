import SwiftUI

struct PasswordDetailView: View {

    let entry: PasswordEntry

    var storage = PasswordStorageService.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showPassword = false
    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    @State private var copiedField: String?

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingM) {
                headerCard
                detailsCard
                datesCard
                deleteButton

                Spacer(minLength: 100)
            }
            .padding(.horizontal, AppTheme.spacingM)
            .padding(.vertical, AppTheme.spacingM)
        }
        .background(GradientBackground())
        .navigationTitle(String(localized: "Details"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    HapticManager.impact(.light)
                    showEditSheet = true
                } label: {
                    Text(String(localized: "Edit"))
                        .font(AppTheme.bodyMedium)
                        .foregroundStyle(AppTheme.accent)
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            PasswordEditView(mode: .edit(entry))
        }
        .confirmationDialog(
            String(localized: "Delete Password?"),
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(String(localized: "Delete"), role: .destructive) {
                storage.deleteEntry(entry)
                dismiss()
            }
        } message: {
            Text(String(localized: "This action cannot be undone."))
        }
        .overlay(alignment: .bottom) {
            copiedToast
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        VStack(spacing: AppTheme.spacingM) {
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.15))
                    .frame(width: 80, height: 80)
                Text(entry.title.prefix(1).uppercased())
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.accent)
            }

            VStack(spacing: AppTheme.spacingXS) {
                Text(entry.title)
                    .font(AppTheme.titleMedium)
                    .foregroundStyle(AppTheme.primaryText)

                if !entry.website.isEmpty {
                    Text(entry.website)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.spacingL)
        .cardStyle()
    }

    // MARK: - Details

    private var detailsCard: some View {
        VStack(spacing: 0) {
            sectionHeader(String(localized: "Credentials"), icon: "person.badge.key.fill")

            detailRow(
                icon: "globe",
                label: String(localized: "Website"),
                value: entry.website
            )
            Divider().padding(.leading, 56)

            detailRow(
                icon: "person.fill",
                label: String(localized: "Username"),
                value: entry.username
            )
            Divider().padding(.leading, 56)

            passwordRow
        }
        .cardStyle(padding: 0)
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: AppTheme.spacingS) {
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.15))
                    .frame(width: 28, height: 28)
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)
            }
            Text(title)
                .font(AppTheme.captionMedium)
                .foregroundStyle(AppTheme.secondaryText)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.top, AppTheme.spacingM)
        .padding(.bottom, AppTheme.spacingS)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: AppTheme.spacingS) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.tertiaryText)
                Text(value.isEmpty ? "—" : value)
                    .font(AppTheme.bodyFont)
                    .foregroundStyle(AppTheme.primaryText)
            }

            Spacer()

            if !value.isEmpty {
                Button {
                    copyToClipboard(value, field: label)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.accent)
                        .frame(width: 32, height: 32)
                        .background(AppTheme.accentSoft)
                        .clipShape(Circle())
                }
                .pressable()
            }
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.vertical, 12)
    }

    private var passwordRow: some View {
        HStack(spacing: AppTheme.spacingS) {
            Image(systemName: "lock.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "Password"))
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.tertiaryText)
                Text(showPassword
                     ? entry.password
                     : String(repeating: "•", count: min(entry.password.count, 12)))
                    .font(.system(size: 15, weight: .regular, design: .monospaced))
                    .foregroundStyle(AppTheme.primaryText)
            }

            Spacer()

            Button {
                showPassword.toggle()
                HapticManager.impact(.light)
            } label: {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.secondaryText)
                    .frame(width: 32, height: 32)
                    .background(AppTheme.surfaceSecondary)
                    .clipShape(Circle())
            }
            .pressable()

            Button {
                copyToClipboard(entry.password, field: String(localized: "Password"))
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 32, height: 32)
                    .background(AppTheme.accentSoft)
                    .clipShape(Circle())
            }
            .pressable()
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.vertical, 12)
    }

    // MARK: - Dates

    private var datesCard: some View {
        VStack(spacing: 0) {
            sectionHeader(String(localized: "Info"), icon: "clock.fill")

            dateRow(
                label: String(localized: "Created"),
                date: entry.createdAt
            )
            Divider().padding(.leading, 56)
            dateRow(
                label: String(localized: "Updated"),
                date: entry.updatedAt
            )
        }
        .cardStyle(padding: 0)
    }

    private func dateRow(label: String, date: Date) -> some View {
        HStack {
            Text(label)
                .font(AppTheme.bodyFont)
                .foregroundStyle(AppTheme.secondaryText)
            Spacer()
            Text(date.formatted(date: .abbreviated, time: .shortened))
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.tertiaryText)
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.vertical, 12)
    }

    // MARK: - Delete

    private var deleteButton: some View {
        Button {
            HapticManager.impact(.light)
            showDeleteConfirmation = true
        } label: {
            HStack(spacing: AppTheme.spacingS) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .semibold))
                Text(String(localized: "Delete Password"))
                    .font(AppTheme.bodyMedium)
            }
            .foregroundStyle(AppTheme.destructive)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppTheme.destructive.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusL, style: .continuous))
        }
        .pressable()
    }

    // MARK: - Toast

    @ViewBuilder
    private var copiedToast: some View {
        if let copiedField {
            HStack(spacing: AppTheme.spacingS) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(AppTheme.accent)
                Text("\(copiedField) copied")
                    .font(AppTheme.captionMedium)
                    .foregroundStyle(AppTheme.accent)
            }
            .padding(.horizontal, AppTheme.spacingL)
            .padding(.vertical, 12)
            .background(AppTheme.accentSoft)
            .clipShape(Capsule())
            .shadow(color: AppTheme.shadowMedium, radius: 12, y: 4)
            .padding(.bottom, AppTheme.spacingL)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Logic

    private func copyToClipboard(_ value: String, field: String) {
        #if os(iOS)
        UIPasteboard.general.string = value
        #endif
        HapticManager.notification(.success)
        withAnimation(.spring(response: 0.3)) { copiedField = field }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.spring(response: 0.3)) { copiedField = nil }
        }
    }
}

#Preview {
    NavigationStack {
        PasswordDetailView(entry: PasswordEntry(
            title: "Google",
            website: "google.com",
            username: "user@gmail.com",
            password: "SuperSecret123!"
        ))
    }
}
