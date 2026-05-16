import SwiftUI

struct SavedPasswordsSection: View {

    var storage = PasswordStorageService.shared
    @State private var showAddSheet = false

    var body: some View {
        VStack(spacing: AppTheme.spacingM) {
            headerRow

            if storage.entries.isEmpty {
                emptyState
            } else {
                passwordsList
            }
        }
        .sheet(isPresented: $showAddSheet) {
            PasswordEditView(mode: .add)
        }
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack {
            HStack(spacing: AppTheme.spacingS) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accent.opacity(0.15))
                        .frame(width: 28, height: 28)
                    Image(systemName: "key.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                }
                Text(String(localized: "Saved Passwords"))
                    .font(AppTheme.captionMedium)
                    .foregroundStyle(AppTheme.secondaryText)
                    .textCase(.uppercase)
                Text("\(storage.entries.count)")
                    .font(AppTheme.captionMedium)
                    .foregroundStyle(AppTheme.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(AppTheme.accentSoft)
                    .clipShape(Capsule())
            }

            Spacer()

            Button {
                HapticManager.impact(.light)
                showAddSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: AppTheme.accent.opacity(0.3), radius: 6, y: 2)
            }
            .pressable()
        }
        .padding(.horizontal, AppTheme.spacingXS)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AppTheme.spacingM) {
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.15))
                    .frame(width: 72, height: 72)
                Image(systemName: "key")
                    .font(.system(size: 30, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.accent)
            }

            VStack(spacing: AppTheme.spacingXS) {
                Text(String(localized: "No saved passwords"))
                    .font(AppTheme.bodyMedium)
                    .foregroundStyle(AppTheme.primaryText)
                Text(String(localized: "Tap + to add your first entry"))
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.tertiaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.spacingXL)
        .cardStyle()
    }

    // MARK: - List

    private var passwordsList: some View {
        VStack(spacing: 0) {
            ForEach(Array(storage.entries.enumerated()), id: \.element.id) { index, entry in
                NavigationLink {
                    PasswordDetailView(entry: entry)
                } label: {
                    HStack(spacing: AppTheme.spacingM) {
                        ZStack {
                            RoundedRectangle(cornerRadius: AppTheme.radiusS, style: .continuous)
                                .fill(AppTheme.accent.opacity(0.15))
                                .frame(width: 42, height: 42)
                            Text(entry.title.prefix(1).uppercased())
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.accent)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.title)
                                .font(AppTheme.bodyMedium)
                                .foregroundStyle(AppTheme.primaryText)
                            Text(entry.username)
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.secondaryText)
                                .lineLimit(1)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AppTheme.tertiaryText)
                    }
                    .padding(.horizontal, AppTheme.spacingM)
                    .padding(.vertical, 12)
                }

                if index < storage.entries.count - 1 {
                    Divider().padding(.leading, 72)
                }
            }
        }
        .cardStyle(padding: 0)
    }
}

// MARK: - Edit View

struct PasswordEditView: View {

    enum Mode {
        case add
        case edit(PasswordEntry)
    }

    let mode: Mode

    @Environment(\.dismiss) private var dismiss
    var storage = PasswordStorageService.shared

    @State private var title = ""
    @State private var website = ""
    @State private var username = ""
    @State private var password = ""
    @State private var showPassword = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.spacingM) {
                    detailsSection
                    passwordSection
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.vertical, AppTheme.spacingM)
            }
            .background(AppTheme.background)
            .navigationTitle(isEditing
                             ? String(localized: "Edit Password")
                             : String(localized: "Add Password"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                    .font(AppTheme.bodyMedium)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        save()
                    }
                    .font(AppTheme.bodyMedium)
                    .foregroundStyle(AppTheme.accent)
                    .disabled(title.isEmpty || password.isEmpty)
                }
            }
            .onAppear {
                if case .edit(let entry) = mode {
                    title = entry.title
                    website = entry.website
                    username = entry.username
                    password = entry.password
                }
            }
        }
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: AppTheme.spacingS) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accent.opacity(0.15))
                        .frame(width: 28, height: 28)
                    Image(systemName: "doc.text")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                }
                Text(String(localized: "Details"))
                    .font(AppTheme.captionMedium)
                    .foregroundStyle(AppTheme.secondaryText)
                    .textCase(.uppercase)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppTheme.spacingM)
            .padding(.top, AppTheme.spacingM)
            .padding(.bottom, AppTheme.spacingS)

            fieldRow(
                icon: "textformat",
                placeholder: String(localized: "Title (e.g. Google)"),
                text: $title
            )
            Divider().padding(.leading, 56)
            fieldRow(
                icon: "globe",
                placeholder: String(localized: "Website (e.g. google.com)"),
                text: $website,
                contentType: .URL,
                keyboard: .URL
            )
            Divider().padding(.leading, 56)
            fieldRow(
                icon: "person.fill",
                placeholder: String(localized: "Username / Email"),
                text: $username,
                contentType: .username
            )
        }
        .cardStyle(padding: 0)
    }

    // MARK: - Password Section

    private var passwordSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: AppTheme.spacingS) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accent.opacity(0.15))
                        .frame(width: 28, height: 28)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                }
                Text(String(localized: "Password"))
                    .font(AppTheme.captionMedium)
                    .foregroundStyle(AppTheme.secondaryText)
                    .textCase(.uppercase)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppTheme.spacingM)
            .padding(.top, AppTheme.spacingM)
            .padding(.bottom, AppTheme.spacingS)

            HStack(spacing: AppTheme.spacingS) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 24)

                if showPassword {
                    TextField(String(localized: "Password"), text: $password)
                        .font(AppTheme.bodyFont)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } else {
                    SecureField(String(localized: "Password"), text: $password)
                        .font(AppTheme.bodyFont)
                }

                Button {
                    showPassword.toggle()
                    HapticManager.impact(.light)
                } label: {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .padding(.horizontal, AppTheme.spacingM)
            .padding(.vertical, 12)
        }
        .cardStyle(padding: 0)
    }

    // MARK: - Field Row

    private func fieldRow(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        contentType: UITextContentType? = nil,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        HStack(spacing: AppTheme.spacingS) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 24)

            TextField(placeholder, text: text)
                .font(AppTheme.bodyFont)
                .textContentType(contentType)
                .keyboardType(keyboard)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.vertical, 12)
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func save() {
        switch mode {
        case .add:
            let entry = PasswordEntry(
                title: title,
                website: website,
                username: username,
                password: password
            )
            storage.addEntry(entry)
        case .edit(var entry):
            entry.title = title
            entry.website = website
            entry.username = username
            entry.password = password
            entry.updatedAt = Date()
            storage.updateEntry(entry)
        }
        HapticManager.notification(.success)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            SavedPasswordsSection()
                .padding()
        }
        .background(GradientBackground())
    }
}
