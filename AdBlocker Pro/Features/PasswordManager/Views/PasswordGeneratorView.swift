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
        VStack(spacing: AppTheme.spacingM) {
            // Password Display
            VStack(spacing: AppTheme.spacingM) {
                Text(generatedPassword.isEmpty ? "Tap Generate" : generatedPassword)
                    .font(.system(size: 18, weight: .medium, design: .monospaced))
                    .foregroundStyle(generatedPassword.isEmpty ? AppTheme.tertiaryText : AppTheme.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(AppTheme.spacingM)
                    .background(AppTheme.groupedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS))
                    .textSelection(.enabled)

                HStack(spacing: AppTheme.spacingS) {
                    Button {
                        generatePassword()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                            Text(String(localized: "Generate"))
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS))
                    }

                    Button {
                        copyPassword()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.on.doc")
                            Text(String(localized: "Copy"))
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.accent.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS))
                    }
                    .disabled(generatedPassword.isEmpty)
                }
            }
            .padding(AppTheme.spacingM)
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))

            // Options
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(String(localized: "Length"))
                            .font(AppTheme.bodyFont)
                        Spacer()
                        Text("\(Int(passwordLength))")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppTheme.accent)
                    }
                    Slider(value: $passwordLength, in: 8...40, step: 1)
                        .tint(AppTheme.accent)
                }
                .padding(.horizontal, AppTheme.spacingM)
                .padding(.vertical, 12)

                Divider().padding(.leading, AppTheme.spacingM)

                toggleRow(String(localized: "Uppercase (A-Z)"), isOn: $includeUppercase)
                Divider().padding(.leading, AppTheme.spacingM)
                toggleRow(String(localized: "Lowercase (a-z)"), isOn: $includeLowercase)
                Divider().padding(.leading, AppTheme.spacingM)
                toggleRow(String(localized: "Numbers (0-9)"), isOn: $includeNumbers)
                Divider().padding(.leading, AppTheme.spacingM)
                toggleRow(String(localized: "Special (!@#$%)"), isOn: $includeSpecialChars)
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusM))

            if showCopiedToast {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.accent)
                    Text(String(localized: "Password copied to clipboard"))
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.accent)
                }
                .padding(AppTheme.spacingM)
                .frame(maxWidth: .infinity)
                .background(AppTheme.accent.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusS))
                .transition(.opacity)
            }
        }
    }

    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(AppTheme.bodyFont)
        }
        .tint(AppTheme.accent)
        .padding(.horizontal, AppTheme.spacingM)
        .padding(.vertical, 10)
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
    ScrollView {
        PasswordGeneratorSection()
            .padding()
    }
    .background(AppTheme.groupedBackground)
}
