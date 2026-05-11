import SwiftUI

struct SavedPasswordsSection: View {

    var storage = PasswordStorageService.shared
    @State private var showAddSheet = false

    var body: some View {
        VStack(spacing: AppTheme.spacingM) {
            HStack {
                Text(String(localized: "Saved Passwords (\(storage.entries.count))"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.secondaryText)
                    .textCase(.uppercase)
                Spacer()
                Button { showAddSheet = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .padding(.horizontal, 4)

            if storage.entries.isEmpty {
                VStack(spacing: AppTheme.spacingS) {
                    Image(systemName: "key")
                        .font(.system(size: 36))
                        .foregroundStyle(AppTheme.tertiaryText)
                    Text(String(localized: "No saved passwords"))
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.secondaryText)
                    Text(String(localized: "Tap + to add your first entry"))
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.tertiaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.spacingXL)
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(storage.entries.enumerated()), id: \.element.id) { index, entry in
                        NavigationLink {
                            PasswordDetailView(entry: entry)
                        } label: {
                            HStack(spacing: AppTheme.spacingM) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(AppTheme.accent.opacity(0.10))
                                        .frame(width: 42, height: 42)
                                    Text(entry.title.prefix(1).uppercased())
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(AppTheme.accent)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.title)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(AppTheme.primaryText)
                                    Text(entry.username)
                                        .font(AppTheme.captionFont)
                                        .foregroundStyle(AppTheme.secondaryText)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
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
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))
            }
        }
        .sheet(isPresented: $showAddSheet) {
            PasswordEditView(mode: .add)
        }
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
            Form {
                Section(String(localized: "Details")) {
                    TextField("Title (e.g. Google)", text: $title)
                    TextField("Website (e.g. google.com)", text: $website)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    TextField("Username / Email", text: $username)
                        .textContentType(.username)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                Section(String(localized: "Password")) {
                    HStack {
                        if showPassword {
                            TextField("Password", text: $password)
                                .textContentType(.password)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        } else {
                            SecureField("Password", text: $password)
                        }

                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.groupedBackground)
            .navigationTitle(isEditing ? String(localized: "Edit Password") : String(localized: "Add Password"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) { save() }
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
        .background(AppTheme.groupedBackground)
    }
}
