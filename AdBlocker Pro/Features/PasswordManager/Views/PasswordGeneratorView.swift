import SwiftUI

struct PasswordGeneratorSection: View {

    @State private var generatedPassword = ""
    @State private var passwordLength: Double = 16
    @State private var includeUppercase = true
    @State private var includeLowercase = true
    @State private var includeNumbers = true
    @State private var includeSpecialChars = true
    @State private var showCopiedToast = false

    var body: some View {
        Section {
            VStack(spacing: AppTheme.spacingM) {
                Text(generatedPassword.isEmpty ? "Tap Generate" : generatedPassword)
                    .font(.system(size: 20, weight: .medium, design: .monospaced))
                    .foregroundStyle(generatedPassword.isEmpty ? AppTheme.tertiaryText : AppTheme.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(AppTheme.spacingM)
                    .background(AppTheme.tertiaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS))
                    .textSelection(.enabled)

                HStack(spacing: AppTheme.spacingM) {
                    Button {
                        generatePassword()
                    } label: {
                        Label("Generate", systemImage: "arrow.clockwise")
                            .font(AppTheme.headlineFont)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppTheme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS))
                    }

                    Button {
                        copyPassword()
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                            .font(AppTheme.headlineFont)
                            .foregroundStyle(AppTheme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppTheme.accent.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS))
                    }
                    .disabled(generatedPassword.isEmpty)
                }
            }
            .padding(.vertical, AppTheme.spacingXS)
        } header: {
            Text("Generated Password")
        }

        Section("Options") {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Length")
                    Spacer()
                    Text("\(Int(passwordLength))")
                        .foregroundStyle(AppTheme.accent)
                        .font(AppTheme.headlineFont)
                }
                Slider(value: $passwordLength, in: 8...40, step: 1)
                    .tint(AppTheme.accent)
            }

            Toggle("Uppercase (A-Z)", isOn: $includeUppercase)
                .tint(AppTheme.accent)
            Toggle("Lowercase (a-z)", isOn: $includeLowercase)
                .tint(AppTheme.accent)
            Toggle("Numbers (0-9)", isOn: $includeNumbers)
                .tint(AppTheme.accent)
            Toggle("Special (!@#$%)", isOn: $includeSpecialChars)
                .tint(AppTheme.accent)
        }

        if showCopiedToast {
            Section {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.accent)
                    Text("Password copied to clipboard")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.accent)
                }
            }
        }
    }

    private func generatePassword() {
        var chars = ""
        if includeUppercase { chars += "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
        if includeLowercase { chars += "abcdefghijklmnopqrstuvwxyz" }
        if includeNumbers { chars += "0123456789" }
        if includeSpecialChars { chars += "!@#$%^&*()_+-=[]{}|;:,.<>?" }

        guard !chars.isEmpty else {
            includeLowercase = true
            chars = "abcdefghijklmnopqrstuvwxyz"
            return
        }

        generatedPassword = String((0..<Int(passwordLength)).map { _ in
            chars.randomElement()!
        })

        HapticManager.impact(.light)
    }

    private func copyPassword() {
        #if os(iOS)
        UIPasteboard.general.string = generatedPassword
        #endif
        HapticManager.notification(.success)
        withAnimation { showCopiedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showCopiedToast = false }
        }
    }
}

#Preview {
    List {
        PasswordGeneratorSection()
    }
    .listStyle(.insetGrouped)
}
