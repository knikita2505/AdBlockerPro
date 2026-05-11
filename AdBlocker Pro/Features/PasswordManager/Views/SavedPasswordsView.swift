import SwiftUI

struct SavedPasswordsSection: View {

    var storage = PasswordStorageService.shared
    @State private var showAddSheet = false

    var body: some View {
        Section {
            if storage.entries.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: AppTheme.spacingS) {
                        Image(systemName: "key")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.secondaryText)
                        Text("No saved passwords")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.secondaryText)
                        Text("Tap + to add your first entry")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.tertiaryText)
                    }
                    .padding(.vertical, AppTheme.spacingXL)
                    Spacer()
                }
            } else {
                ForEach(storage.entries) { entry in
                    NavigationLink {
                        PasswordDetailView(entry: entry)
                    } label: {
                        HStack(spacing: AppTheme.spacingM) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppTheme.accent.opacity(0.12))
                                    .frame(width: 40, height: 40)
                                Text(entry.title.prefix(1).uppercased())
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.accent)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.title)
                                    .font(AppTheme.bodyFont)
                                Text(entry.username)
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.secondaryText)
                            }
                        }
                    }
                }
                .onDelete { offsets in
                    storage.deleteEntries(at: offsets)
                }
            }
        } header: {
            HStack {
                Text("Saved Passwords (\(storage.entries.count))")
                Spacer()
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppTheme.accent)
                }
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
                Section("Details") {
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

                Section("Password") {
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
            .navigationTitle(isEditing ? "Edit Password" : "Add Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
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
        List {
            SavedPasswordsSection()
        }
        .listStyle(.insetGrouped)
    }
}
