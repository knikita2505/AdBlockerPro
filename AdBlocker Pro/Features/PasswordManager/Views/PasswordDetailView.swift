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
        List {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: AppTheme.spacingS) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.accent.opacity(0.12))
                                .frame(width: 64, height: 64)
                            Text(entry.title.prefix(1).uppercased())
                                .font(.largeTitle.bold())
                                .foregroundStyle(AppTheme.accent)
                        }
                        Text(entry.title)
                            .font(AppTheme.titleFont)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            Section("Details") {
                detailRow("Website", value: entry.website, icon: "globe")
                detailRow("Username", value: entry.username, icon: "person.fill")

                HStack {
                    Label {
                        Text("Password")
                            .foregroundStyle(AppTheme.secondaryText)
                    } icon: {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(AppTheme.accent)
                    }

                    Spacer()

                    Text(showPassword ? entry.password : String(repeating: "•", count: min(entry.password.count, 12)))
                        .font(.system(.body, design: .monospaced))

                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundStyle(AppTheme.secondaryText)
                    }

                    Button {
                        copyToClipboard(entry.password, field: "Password")
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .foregroundStyle(AppTheme.accent)
                    }
                }
            }

            Section {
                HStack {
                    Text("Created")
                        .foregroundStyle(AppTheme.secondaryText)
                    Spacer()
                    Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(AppTheme.captionFont)
                }
                HStack {
                    Text("Updated")
                        .foregroundStyle(AppTheme.secondaryText)
                    Spacer()
                    Text(entry.updatedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(AppTheme.captionFont)
                }
            }

            Section {
                Button {
                    showDeleteConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Label("Delete", systemImage: "trash")
                            .foregroundStyle(AppTheme.destructive)
                        Spacer()
                    }
                }
            }

            if let copiedField {
                Section {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppTheme.accent)
                        Text("\(copiedField) copied")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.accent)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showEditSheet = true }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            PasswordEditView(mode: .edit(entry))
        }
        .confirmationDialog("Delete Password?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                storage.deleteEntry(entry)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func detailRow(_ label: String, value: String, icon: String) -> some View {
        HStack {
            Label {
                Text(label)
                    .foregroundStyle(AppTheme.secondaryText)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(AppTheme.accent)
            }

            Spacer()

            Text(value.isEmpty ? "—" : value)
                .font(AppTheme.bodyFont)

            if !value.isEmpty {
                Button {
                    copyToClipboard(value, field: label)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .foregroundStyle(AppTheme.accent)
                }
            }
        }
    }

    private func copyToClipboard(_ value: String, field: String) {
        #if os(iOS)
        UIPasteboard.general.string = value
        #endif
        HapticManager.notification(.success)
        withAnimation { copiedField = field }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { copiedField = nil }
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
